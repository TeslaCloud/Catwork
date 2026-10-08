--- Server-side part of the `cw.player` library, which holds most of the framework's player and character logic.
--
-- It creates, loads, saves and deletes characters and player data in the database, and manages flags, whitelists,
-- cash, property and doors, recognition and names, weapons and ammo, gear, ragdolling, timed actions and
-- notifications. It also adds `Player:GiveCash` and `Player:Notify`.

if !cw.player then include('sh_player.lua') end
if !cw.database then include('sv_database.lua') end
if !chatbox then include('sv_chatbox.lua') end
if !cw.hint then include('sv_hint.lua') end

local cwHint = cw.hint
local cwDatabase = cw.database

local plyProperty = cw.player.property or {}
cw.player.property = plyProperty

--- Networks a player's loaded player data and fills in defaults for missing keys.
--
-- Every key in `data` is sent through `cw.player:UpdatePlayerData`; keys
-- registered with `cw.player:AddPlayerData` that are missing from `data` are
-- set to their default with `Player:SetData`.
-- @param player [Player The player whose data was loaded]
-- @param data [Map The player's data, keyed by name]
-- @warning [Internal] Called by `GM:PlayerRestoreData`.
function cw.player:RestoreData(player, data)
  for k, v in pairs(data) do
    self:UpdatePlayerData(player, k, v)
  end

  for k, v in pairs(self.playerData) do
    if data[k] == nil then
      player:SetData(k, v.default)
    end
  end
end

--- Networks a character's loaded data and fills in defaults for missing keys.
--
-- Every key in `data` is sent through `cw.player:UpdateCharacterData`; keys
-- registered with `cw.player:AddCharacterData` that are missing from `data`
-- are set to their default with `Player:SetCharacterData`.
-- @param player [Player The player whose character was loaded]
-- @param data [Map The character's data, keyed by name]
-- @warning [Internal] Called by `GM:PlayerRestoreCharacterData`.
function cw.player:RestoreCharacterData(player, data)
  for k, v in pairs(data) do
    self:UpdateCharacterData(player, k, v)
  end

  for k, v in pairs(self.characterData) do
    if data[k] == nil then
      player:SetCharacterData(k, v.default)
    end
  end
end

--- Networks a character data value registered with `cw.player:AddCharacterData`.
--
-- The value is passed through the registered callback first. `PhysDesc` is
-- sent as a DT string; every other key becomes a net var on the player. Keys
-- that are not registered are not networked.
-- @param player [Player The player the data belongs to]
-- @param key [String Name of the character data]
-- @param value [Any The new value]
-- @warning [Internal] Called by `Player:SetCharacterData`.
function cw.player:UpdateCharacterData(player, key, value)
  local characterData = self.characterData

  if characterData[key] then
    if characterData[key].callback then
      value = characterData[key].callback(player, value)
    end

    if key == 'PhysDesc' then
      player:SetDTString(STRING_PHYSDESC, value)

      return
    end

    player:SetNetVar(key, value)
  end
end

--- Networks a player data value registered with `cw.player:AddPlayerData`.
--
-- The value is passed through the registered callback first and set as a net
-- var on the player. Keys that are not registered are not networked.
-- @param player [Player The player the data belongs to]
-- @param key [String Name of the player data]
-- @param value [Any The new value]
-- @warning [Internal] Called by `Player:SetData`.
function cw.player:UpdatePlayerData(player, key, value)
  local playerData = self.playerData

  if playerData[key] then
    if playerData[key].callback then
      value = playerData[key].callback(player, value)
    end

    player:SetNetVar(key, value)
  end
end

--- Runs an inventory action, such as using or dropping an item, as if the player had requested it.
--
-- Runs the `InvAction` command on behalf of the player.
-- @param player [Player The player performing the action]
-- @param itemTable [Item The item instance to act on]
-- @param action [String Name of the action, such as `'use'` or `'drop'`]
-- @return [Any The result of `cw.command:ConsoleCommand`]
function cw.player:InventoryAction(player, itemTable, action)
  return self:RunClockworkCommand(player, 'InvAction', action, itemTable.uniqueID, tostring(itemTable.itemID))
end

--- Returns one of the player's gear entities.
-- @param player [Player The player]
-- @param gearClass [String The gear slot, as passed to `cw.player:CreateGear`]
-- @return [Entity The `cw_gear` entity, or `nil` if there is none in that slot]
function cw.player:GetGear(player, gearClass)
  if player.cwGearTab and IsValid(player.cwGearTab[gearClass]) then
    return player.cwGearTab[gearClass]
  end
end

--- Validates a character creation request and creates the character.
--
-- Checks the faction, class, attributes, name, physical description, model,
-- gender, whitelist, faction limit and free character slots, and calls the
-- faction's `GetName`, `GetModel` and `OnCreation` and the
-- `PlayerAdjustCharacterCreationInfo` hook (returning `false` or a string
-- there rejects the character). The name must also be unused in the
-- database. Any failure is sent to the client with
-- `cw.player:SetCreateFault`. On success the character is created with
-- `cw.player:LoadCharacter` and used right away if it is the player's only
-- one. A request that arrives while an earlier one is still being saved is
-- ignored.
--
-- Of the client's `plugin` table, only the custom choices that the
-- `GetPersuasionChoices` hook returns on the server become character data,
-- and only with a value the choice allows.
-- @param player [Player The player creating the character]
-- @param data [Map The creation request from the client: `faction`, `gender`, `model`, `class`, `attributes`,
-- `forename` and `surname` or `fullName`, `physDesc` and `plugin` (values of the custom choices)]
-- @return [Nil Nothing; the result is sent to the client]
-- @warning [Internal] Called by the `CreateCharacter` netstream receiver.
function cw.player:CreateCharacterFromData(player, data)
  if !istable(data) or !player:GetCharacters() then return end

  if player.cwIsCreatingChar and player.cwIsCreatingChar > CurTime() then
    return
  end

  local minimumPhysDesc = config.Get('minimum_physdesc'):Get()
  local attributesTable = cw.attribute:GetAll()
  local factionTable = (isstring(data.faction) or isnumber(data.faction)) and faction.FindByID(data.faction)
  local attributes = nil
  local info = {}

  if table.Count(attributesTable) > 0 then
    for k, v in pairs(attributesTable) do
      if v.isOnCharScreen then
        attributes = true
        break
      end
    end
  end

  if !factionTable then
    return self:SetCreateFault(
      player, L'InvalidFaction'
    )
  end

  info.attributes = {}
  info.traits = { positive = {}, negative = {} }
  info.faction = factionTable.name
  info.gender = data.gender
  info.model = data.model
  info.data = {}

  if istable(data.plugin) then
    local customChoices = {}

    hook.Run('GetPersuasionChoices', customChoices)

    for k, v in pairs(customChoices) do
      local value = data.plugin[v.name]

      if isstring(value) and value != '' then
        local bIsValid = string.utf8len(value) <= 256

        if !v.type or string.lower(v.type) == 'combobox' then
          bIsValid = istable(v.choices) and table.HasValue(v.choices, value)
        elseif v.isNumber then
          local number = tonumber(value)

          bIsValid = number != nil and number == number and (!v.max or number <= v.max) and (!v.min or number >= v.min)
        end

        if !bIsValid then
          return self:SetCreateFault(
            player, L('CharFault_CreationError')
          )
        end

        info.data[v.name] = value
      end
    end
  end

  local classes = false

  for k, v in pairs(cw.class:GetAll()) do
    if v.isOnCharScreen and (v.factions
    and table.HasValue(v.factions, factionTable.name)) then
      classes = true
    end
  end

  if classes then
    local classTable = (isstring(data.class) or isnumber(data.class)) and cw.class:FindByID(data.class)

    if !classTable or !classTable.isOnCharScreen
    or !classTable.factions or !table.HasValue(classTable.factions, factionTable.name) then
      return self:SetCreateFault(
        player, L'InvalidClass'
      )
    else
      info.data['class'] = classTable.name
    end
  end

  if attributes and type(data.attributes) == 'table' then
    local maximumPoints = config.Get('default_attribute_points'):Get()
    local pointsSpent = 0

    if factionTable.attributePointsScale then
      maximumPoints = math.Round(maximumPoints * factionTable.attributePointsScale)
    end

    if factionTable.maximumAttributePoints then
      maximumPoints = factionTable.maximumAttributePoints
    end

    for k, v in pairs(data.attributes) do
      local attributeTable = (isstring(k) or isnumber(k)) and cw.attribute:FindByID(k)
      local amount = tonumber(v)

      -- NaN would pass the comparison with the maximum below.
      if attributeTable and attributeTable.isOnCharScreen and amount and amount == amount then
        local uniqueID = attributeTable.uniqueID

        amount = math.Clamp(amount, 0, attributeTable.maximum)

        info.attributes[uniqueID] = {
          amount = amount,
          progress = 0
        }

        pointsSpent = pointsSpent + amount
      end
    end

    if pointsSpent > maximumPoints then
      return self:SetCreateFault(
        player, L'TooManyAtts'
      )
    end
  elseif attributes then
    return self:SetCreateFault(
      player, L'AttribError'
    )
  end

  if !factionTable.GetName then
    if !factionTable.useFullName then
      if isstring(data.forename) and isstring(data.surname) then
        data.forename = string.gsub(data.forename, '^.', string.upper)
        data.surname = string.gsub(data.surname, '^.', string.upper)

        if string.find(data.forename, '[%p%s%d]') or string.find(data.surname, '[%p%s%d]') then
          return self:SetCreateFault(
            player, L('CharCreation_Appearance_ErrorMessage2')
          )
        end

        if !string.find(data.forename, '[aeiou]') or !string.find(data.surname, '[aeiou]') then
          return self:SetCreateFault(
            player, L('CharCreation_Appearance_ErrorMessage3')
          )
        end

        if string.utf8len(data.forename) < 2 or string.utf8len(data.surname) < 2 then
          return self:SetCreateFault(
            player, L('CharCreation_Appearance_ErrorMessage4')
          )
        end

        if string.utf8len(data.forename) > 16 or string.utf8len(data.surname) > 16 then
          return self:SetCreateFault(
            player, L('CharCreation_Appearance_ErrorMessage5')
          )
        end
      else
        return self:SetCreateFault(
          player, L('CharCreation_Appearance_ErrorMessage1')
        )
      end
    else
      if isstring(data.fullName) then
        data.fullName = string.Trim(data.fullName)
      end

      if !isstring(data.fullName) or data.fullName == '' or string.find(data.fullName, '%c')
      or string.utf8len(data.fullName) > 64 then
        return self:SetCreateFault(
          player, L('CharCreation_Appearance_ErrorMessage1')
        )
      end
    end
  end

  if cw.command:FindByID('CharPhysDesc') != nil then
    if type(data.physDesc) != 'string' then
      return self:SetCreateFault(
        player, L('CharFault_NoPhysDesc')
      )
    elseif string.utf8len(data.physDesc) < minimumPhysDesc then
      return self:SetCreateFault(
        player, L('CharCreation_Appearance_ErrorMessage7', minimumPhysDesc)
      )
    end

    info.data['PhysDesc'] = cw.core:ModifyPhysDesc(data.physDesc)
  end

  if !factionTable.GetModel and !info.model then
    return self:SetCreateFault(
      player, L('CharCreation_Appearance_ErrorMessage6')
    )
  end

  if !faction.IsGenderValid(info.faction, info.gender) then
    return self:SetCreateFault(
      player, L('CharFault_InvalidGender')
    )
  end

  if factionTable.whitelist and !self:IsWhitelisted(player, info.faction) then
    return self:SetCreateFault(
      player, L('CharFault_NotWhitelisted', info.faction)
    )
  elseif _faction.IsModelValid(factionTable.name, info.gender, info.model)
  or (factionTable.GetModel and !info.model) then
    local charactersTable = config.Get('mysql_characters_table'):Get()
    local schemaFolder = cw.core:GetSchemaFolder()
    local characterID = nil
    local characters = player:GetCharacters()

    if _faction.HasReachedMaximum(player, factionTable.name) then
      return self:SetCreateFault(
        player, L('CharFault_FactionCharLimit')
      )
    end

    for i = 1, self:GetMaximumCharacters(player) do
      if !characters[i] then
        characterID = i
        break
      end
    end

    if characterID then
      if factionTable.GetName then
        info.name = factionTable:GetName(player, info, data)
      elseif !factionTable.useFullName then
        info.name = data.forename..' '..data.surname
      else
        info.name = data.fullName
      end

      if factionTable.GetModel then
        info.model = factionTable:GetModel(player, info, data)
      else
        info.model = data.model
      end

      if factionTable.OnCreation then
        local fault = factionTable:OnCreation(player, info)

        if fault == false or type(fault) == 'string' then
          return self:SetCreateFault(
            player, fault or L('CharFault_CreationError')
          )
        end
      end

      for k, v in pairs(characters) do
        if v.name == info.name then
          return self:SetCreateFault(
            player, L('CharFault_NameOwned').." '"..info.name.."'!"
          )
        end
      end

      local fault = hook.Run('PlayerAdjustCharacterCreationInfo', player, info, data)

      if fault == false or type(fault) == 'string' then
        return self:SetCreateFault(
          player, fault or L('CharFault_CreationError')
        )
      end

      -- Covers the name check and the insert that follows. It expires by itself, as neither query calls back when
      -- it fails.
      player.cwIsCreatingChar = CurTime() + 10

      local queryObj = cwDatabase:Select(charactersTable)
        queryObj:Where('_Schema', schemaFolder)
        queryObj:Where('_Name', info.name)
        queryObj:Callback(function(result)
          if !IsValid(player) then return end

          if cwDatabase:IsResult(result) then
            self:SetCreateFault(
              player, L('CharFault_NameTaken').." '"..info.name.."'."
            )
            player.cwIsCreatingChar = nil
          else
            self:LoadCharacter(player, characterID,
              {
                attributes = info.attributes,
                traits = info.traits,
                faction = info.faction,
                gender = info.gender,
                model = info.model,
                name = info.name,
                data = info.data
              },
              function()
                cw.core:PrintLog(LOGTYPE_MINOR,
                  player:SteamName()..' has created a '..info.faction.." character called '"..info.name.."'."
                )

                netstream.Start(player, 'CharacterFinish', { bSuccess = true })

                player.cwIsCreatingChar = nil

                local characters = player:GetCharacters()

                if table.Count(characters) == 1 then
                  self:UseCharacter(player, characterID)
                end
              end
            )
          end
        end)

      queryObj:Execute()
    else
      return self:SetCreateFault(player, L('CharCreation_CannotCreateMoreChars'))
    end
  else
    return self:SetCreateFault(
      player, L('CharCreation_Appearance_ErrorMessage6')
    )
  end
end

--- Opens the character menu for a player who has initialized.
-- @param player [Player The player]
-- @param bReset=false [Boolean Also kill the player silently and mark the menu as reset, so they respawn when
-- they pick a character]
function cw.player:SetCharacterMenuOpen(player, bReset)
  if player:HasInitialized() then
    netstream.Start(player, 'CharacterOpen', (bReset == true))

    if bReset then
      player.cwCharMenuReset = true
      player:KillSilent()
    end
  end
end

--- Starts playing a sound on the player's client under an identifier.
--
-- Does nothing if the same sound is already playing under that identifier.
-- @param player [Player The player]
-- @param uniqueID [String Identifier used to stop the sound later]
-- @param sound [String Path of the sound file]
-- @param fVolume=0.75 [Number Volume from `0` to `1`]
-- @see cw.player:StopSound
function cw.player:StartSound(player, uniqueID, sound, fVolume)
  if !player.cwSoundsPlaying then
    player.cwSoundsPlaying = {}
  end

  if !player.cwSoundsPlaying[uniqueID]
  or player.cwSoundsPlaying[uniqueID] != sound then
    player.cwSoundsPlaying[uniqueID] = sound

    netstream.Start(player, 'StartSound', {
      uniqueID = uniqueID, sound = sound, volume = (fVolume or 0.75)
    })
  end
end

--- Stops a sound started with `cw.player:StartSound`.
-- @param player [Player The player]
-- @param uniqueID [String Identifier the sound was started under]
-- @param iFadeOut=0 [Number Fade-out time in seconds]
function cw.player:StopSound(player, uniqueID, iFadeOut)
  if !player.cwSoundsPlaying then
    player.cwSoundsPlaying = {}
  end

  if player.cwSoundsPlaying[uniqueID] then
    player.cwSoundsPlaying[uniqueID] = nil

    netstream.Start(player, 'StopSound', {
      uniqueID = uniqueID, fadeOut = (iFadeOut or 0)
    })
  end
end

--- Removes the gear entity in one of the player's gear slots.
-- @param player [Player The player]
-- @param gearClass [String The gear slot]
function cw.player:RemoveGear(player, gearClass)
  if player.cwGearTab and IsValid(player.cwGearTab[gearClass]) then
    player.cwGearTab[gearClass]:Remove()
    player.cwGearTab[gearClass] = nil
  end
end

--- Removes all of the player's gear entities.
-- @param player [Player The player]
function cw.player:StripGear(player)
  if !player.cwGearTab then return end

  for k, v in pairs(player.cwGearTab) do
    if IsValid(v) then v:Remove() end
  end

  player.cwGearTab = {}
end

--- Attaches an item's model to the player as a `cw_gear` entity.
--
-- Replaces any gear in the same slot. Does nothing unless the item has
-- `isAttachment` set. Uses the item's `attachmentModel` (or `model`),
-- `attachmentMaterial` and `attachmentColor`.
-- @param player [Player The player to attach the gear to]
-- @param gearClass [String The gear slot, usually the item's unique ID]
-- @param itemTable [Item The item the gear represents]
-- @param bMustHave=nil [Boolean Remove the gear when the player no longer has the item]
-- @see cw.player:RemoveGear
function cw.player:CreateGear(player, gearClass, itemTable, bMustHave)
  if !player.cwGearTab then
    player.cwGearTab = {}
  end

  if IsValid(player.cwGearTab[gearClass]) then
    player.cwGearTab[gearClass]:Remove()
  end

  if itemTable.isAttachment then
    local position = player:GetPos()
    local angles = player:GetAngles()
    local model = itemTable.attachmentModel or itemTable.model

    player.cwGearTab[gearClass] = ents.Create('cw_gear')
    player.cwGearTab[gearClass]:SetParent(player)
    player.cwGearTab[gearClass]:SetAngles(angles)
    player.cwGearTab[gearClass]:SetModel(model)
    player.cwGearTab[gearClass]:SetPos(position)
    player.cwGearTab[gearClass]:Spawn()

    if itemTable.attachmentMaterial then
      player.cwGearTab[gearClass]:SetMaterial(itemTable.attachmentMaterial)
    end

    if itemTable.attachmentColor then
      player.cwGearTab[gearClass]:SetColor(
        cw.core:UnpackColor(itemTable.attachmentColor)
      )
    else
      player.cwGearTab[gearClass]:SetColor(Color(255, 255, 255, 255))
    end

    if IsValid(player.cwGearTab[gearClass]) then
      player.cwGearTab[gearClass]:SetOwner(player)
      player.cwGearTab[gearClass]:SetMustHave(bMustHave)
      player.cwGearTab[gearClass]:SetItemTable(gearClass, itemTable)
    end
  end
end

--- Returns whether the player is noclipping outside a vehicle.
-- @param player [Player The player]
-- @return [Boolean `true` if noclipping, otherwise `nil`]
function cw.player:IsNoClipping(player)
  if player:GetMoveType() == MOVETYPE_NOCLIP
  and !player:InVehicle() then
    return true
  end
end

--- Returns whether the player has the `o` (operator) flag.
-- @param player [Player The player]
-- @return [Boolean `true` if they have the flag, otherwise `nil`]
-- @see cw.player:HasFlags
function cw.player:IsAdmin(player)
  if self:HasFlags(player, 'o') then
    return true
  end
end

--- Returns whether a player can hear another player.
--
-- Always `true` unless the `messages_must_see_player` config is on, in which
-- case the player must be able to see the target.
-- @param player [Player The listening player]
-- @param target [Player The speaking player]
-- @param iAllowance=0.5 [Number Trace fraction that counts as visible, see `cw.player:CanSeePosition`]
-- @return [Boolean Whether the player can hear the target]
function cw.player:CanHearPlayer(player, target, iAllowance)
  if config.Get('messages_must_see_player'):Get() then
    return self:CanSeePlayer(player, target, (iAllowance or 0.5), true)
  else
    return true
  end
end

--- Returns every entity owned as property, removing entries that are no longer valid.
-- @return [Map<Entity> Owned entities keyed by entity index]
function cw.player:GetAllProperty()
  for k, v in pairs(plyProperty) do
    if !IsValid(v) then
      plyProperty[k] = nil
    end
  end

  return plyProperty
end

--- Starts a timed action on the player, shown as a progress bar.
--
-- An action only replaces a running one with a priority if its own priority
-- is higher, or if it has the same name. Passing an empty or non-string
-- `action` clears the current action; passing a `duration` of `false` or `0`
-- clears it only if `action` is the current one. The action is networked
-- through the `StartActTime`, `ActDuration` and `ActName` net vars.
--
-- ```
-- cw.player:SetAction(player, 'lockpick', 5, 3, function()
--   if IsValid(door) then
--     door:Fire('unlock', '', 0)
--   end
-- end)
-- ```
--
-- @param player [Player The player]
-- @param action [String Name of the action, or a non-string to clear it]
-- @param duration [Number Duration in seconds; `false` or `0` stops `action` if it is running]
-- @param priority=nil [Number Priority of the action against other actions]
-- @param Callback=nil [Function Called without arguments when the duration has passed]
-- @return [Boolean `false` if asked to stop an action that is not running, otherwise `nil`]
-- @see cw.player:GetAction
function cw.player:SetAction(player, action, duration, priority, Callback)
  local currentAction = self:GetAction(player)

  if type(action) != 'string' or action == '' then
    timer.Remove('Action'..player:UniqueID())

    player:SetNetVar('StartActTime', 0)
    player:SetNetVar('ActDuration', 0)
    player:SetNetVar('ActName', '')

    return
  elseif duration == false or duration == 0 then
    if currentAction == action then
      return self:SetAction(player, false)
    else
      return false
    end
  end

  if player.cwAction then
    if (priority and priority > player.cwAction[2])
    or currentAction == '' or action == player.cwAction[1] then
      player.cwAction = nil
    end
  end

  if !player.cwAction then
    local curTime = CurTime()

    player:SetNetVar('StartActTime', curTime)
    player:SetNetVar('ActDuration', duration)
    player:SetNetVar('ActName', action)

    if priority then
      player.cwAction = { action, priority }
    else
      player.cwAction = nil
    end

    timer.Create('Action'..player:UniqueID(), duration, 1, function()
      if Callback then
        Callback()
      end
    end)
  end
end

--- Sends a character menu state to the player's client.
-- @param player [Player The player]
-- @param state [Number One of the `CHARACTER_MENU_*` values]
function cw.player:SetCharacterMenuState(player, state)
  netstream.Start(player, 'CharacterMenu', state)
end

--- Returns the player's current action.
--
-- Without `percentage`, returns the action name, its duration in seconds and
-- the `CurTime` it started at. With `percentage`, returns the action name and
-- how far it has progressed, from `0` to `100`. Returns `''`, `0`, `0` when no
-- action is running.
-- @param player [Player The player]
-- @param percentage=nil [Boolean Return the progress instead of the duration and start time]
-- @return [String The action, or `''` if there is none, Number The duration, or the progress with `percentage`,
-- Number The start time; not returned with `percentage`]
-- @see cw.player:SetAction
function cw.player:GetAction(player, percentage)
  local startActionTime = player:GetNetVar('StartActTime') or 0
  local actionDuration = player:GetNetVar('ActDuration') or 0
  local curTime = CurTime()
  local action = player:GetNetVar('ActName') or 'Unknown'

  if startActionTime and curTime < startActionTime + actionDuration then
    if percentage then
      return action, (100 / actionDuration) * (actionDuration - ((startActionTime + actionDuration) - curTime))
    else
      return action, actionDuration, startActionTime
    end
  else
    return '', 0, 0
  end
end

--- Runs a Catwork command as if the player had typed it.
--
-- ```
-- cw.player:RunClockworkCommand(player, 'CharFallOver')
-- ```
--
-- @param player [Player The player running the command]
-- @param command [String Name of the command]
-- @param ... [Any The command's arguments]
-- @return [Any The result of `cw.command:ConsoleCommand`]
function cw.player:RunClockworkCommand(player, command, ...)
  return cw.command:ConsoleCommand(player, 'cwCmd', { command, ... })
end

--- Returns what the player's wages are called, from their class or the `wages_name` config.
-- @param player [Player The player]
-- @return [String The wages name]
function cw.player:GetWagesName(player)
  return cw.class:Query(player:Team(), 'wagesName', config.Get('wages_name'):Get())
end

--- Returns whether the player can see an entity.
--
-- The entity is visible when the player is looking straight at it, or when
-- `cw.player:CanSeePosition` succeeds for its center.
-- @param player [Player The player]
-- @param target [Entity The entity to check]
-- @param iAllowance=0.75 [Number Trace fraction that counts as visible]
-- @param tIgnoreEnts=nil [List<Entity> Entities the trace ignores, or `true` to ignore every entity]
-- @return [Boolean `true` if the entity is visible, otherwise `nil`]
-- @alias [cw.player.CanSeePlayer]
-- @alias [cw.player.CanSeeNPC]
function cw.player:CanSeeEntity(player, target, iAllowance, tIgnoreEnts)
  if player:GetEyeTraceNoCursor().Entity != target then
    return self:CanSeePosition(player, target:LocalToWorld(target:OBBCenter()), iAllowance, tIgnoreEnts, target)
  else
    return true
  end
end

--[[
  Duplicate functions, keeping them like this for backward compatiblity.
--]]
cw.player.CanSeePlayer = cw.player.CanSeeEntity
cw.player.CanSeeNPC = cw.player.CanSeeEntity

--- Returns whether the player can see a position.
--
-- Traces from the player's shoot position and succeeds when the trace gets
-- at least `iAllowance` of the way there.
-- @param player [Player The player]
-- @param position [Vector The position to check]
-- @param iAllowance=0.75 [Number Trace fraction that counts as visible]
-- @param tIgnoreEnts=nil [List<Entity> Entities the trace ignores, or `true` to ignore every entity]
-- @param targetEnt=nil [Entity An entity the trace also ignores, usually the one being looked for]
-- @return [Boolean `true` if the position is visible, otherwise `nil`]
function cw.player:CanSeePosition(player, position, iAllowance, tIgnoreEnts, targetEnt)
  local trace = {}

  trace.mask =
    CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER
  trace.start = player:GetShootPos()
  trace.endpos = position
  trace.filter = { player, targetEnt }

  if tIgnoreEnts then
    if type(tIgnoreEnts) == 'table' then
      table.Add(trace.filter, tIgnoreEnts)
    else
      -- Every entity, which includes the player and the target.
      trace.filter = ents.GetAll()
    end
  end

  trace = util.TraceLine(trace)

  if trace.Fraction >= (iAllowance or 0.75) then
    return true
  end
end

--- Returns whether the player's weapon is raised.
-- @param player [Player The player]
-- @param bIsCached=nil [Boolean Unused]
-- @return [Boolean Whether the weapon is raised]
-- @see Player:IsWeaponRaised
function cw.player:GetWeaponRaised(player, bIsCached)
  return player:IsWeaponRaised()
end

--- Raises the player's weapon if it is lowered, and lowers it otherwise.
-- @param player [Player The player]
function cw.player:ToggleWeaponRaised(player)
  player:ToggleWeaponRaised()
end

--- Raises or lowers the player's weapon.
-- @param player [Player The player]
-- @param bIsRaised [Boolean Whether the weapon should be raised]
-- @return [Any The result of `Player:SetWeaponRaised`]
function cw.player:SetWeaponRaised(player, bIsRaised)
  return player:SetWeaponRaised(bIsRaised)
end

--- Starts the removal timers of the player's property that has a remove delay.
-- @param player [Player The player whose property should be removed]
-- @param bAllCharacters=nil [Boolean Include property of all the player's characters, not just the current one]
function cw.player:SetupRemovePropertyDelays(player, bAllCharacters)
  local uniqueID = player:UniqueID()
  local key = player:GetCharacterKey()

  for k, v in pairs(self:GetAllProperty()) do
    local removeDelay = cw.entity:QueryProperty(v, 'removeDelay')

    if IsValid(v) and removeDelay then
      if uniqueID == cw.entity:QueryProperty(v, 'uniqueID')
      and (bAllCharacters or key == cw.entity:QueryProperty(v, 'key')) then
        timer.Create('RemoveDelay'..v:EntIndex(), removeDelay, 1, function()
          if IsValid(v) then
            v:Remove()
          end
        end)
      end
    end
  end
end

--- Clears the owner of the player's property while keeping it registered to them.
--
-- The entities lose their owner entity and owned state, but keep the owner's
-- unique ID and character key, so `cw.player:ReturnProperty` can give them back.
-- @param player [Player The player whose property is disabled]
-- @param bCharacterOnly=nil [Boolean Only disable property of the player's current character]
function cw.player:DisableProperty(player, bCharacterOnly)
  local uniqueID = player:UniqueID()
  local key = player:GetCharacterKey()

  for k, v in pairs(self:GetAllProperty()) do
    if IsValid(v) and uniqueID == cw.entity:QueryProperty(v, 'uniqueID')
    and (!bCharacterOnly or key == cw.entity:QueryProperty(v, 'key')) then
      cw.entity:SetPropertyVar(v, 'owner', NULL)

      if cw.entity:QueryProperty(v, 'networked') then
        v:SetNWEntity('Owner', NULL)
      end

      v:SetOwnerKey(nil)
      v:SetNWBool('Owned', false)
      v:SetNWInt('Key', 0)

      if v.SetPlayer then
        v:SetVar('Founder', NULL)
        v:SetVar('FounderIndex', 0)
        v:SetNWString('FounderName', '')
      end
    end
  end
end

--- Makes an entity the property of the player's current character.
--
-- Clears any previous ownership and cancels a pending remove delay. Fires
-- `PlayerPropertyGiven`.
-- @param player [Player The new owner]
-- @param entity [Entity The entity]
-- @param networked=nil [Boolean Also set the `Owner` networked entity for clients]
-- @param removeDelay=nil [Number Seconds after the owner leaves before the entity is removed]
-- @see cw.player:TakeProperty
function cw.player:GiveProperty(player, entity, networked, removeDelay)
  timer.Remove('RemoveDelay'..entity:EntIndex())
  cw.entity:ClearProperty(entity)

  entity.cwPropertyTab = {
    key = player:GetCharacterKey(),
    owner = player,
    owned = true,
    uniqueID = player:UniqueID(),
    networked = networked,
    removeDelay = removeDelay
  }

  if entity.SetPlayer then
    entity:SetPlayer(player)
  end

  if networked then
    entity:SetNWEntity('Owner', player)
  end

  entity:SetOwnerKey(player:GetCharacterKey())
  entity:SetNWBool('Owned', true)

  if tonumber(entity.cwPropertyTab.key) then
    entity:SetNWInt('Key', entity.cwPropertyTab.key)
  end

  plyProperty[entity:EntIndex()] = entity
  hook.Run('PlayerPropertyGiven', player, entity, networked, removeDelay)
end

--- Makes an entity the property of a character, whether or not its player is online.
--
-- If the player is online with that character, this calls
-- `cw.player:GiveProperty`. Otherwise the entity is registered to the key and
-- unique ID and `PlayerPropertyGivenOffline` fires. Does nothing without a key
-- and unique ID.
-- @param key [Number The character key]
-- @param uniqueID [String The owner's `Player:UniqueID`]
-- @param entity [Entity The entity]
-- @param networked=nil [Boolean Also set the `Owner` networked entity for clients]
-- @param removeDelay=nil [Number Seconds after the owner leaves before the entity is removed]
function cw.player:GivePropertyOffline(key, uniqueID, entity, networked, removeDelay)
  cw.entity:ClearProperty(entity)

  if key and uniqueID then
    local owner = player.GetByUniqueID(uniqueID)

    if IsValid(owner) and owner:GetCharacterKey() == key then
      self:GiveProperty(owner, entity, networked, removeDelay)
      return
    else
      owner = nil
    end

    timer.Remove('RemoveDelay'..entity:EntIndex())

    entity.cwPropertyTab = {
      key = key,
      owner = owner,
      owned = true,
      uniqueID = uniqueID,
      networked = networked,
      removeDelay = removeDelay
    }

    if IsValid(entity.cwPropertyTab.owner) then
      if entity.SetPlayer then
        entity:SetPlayer(entity.cwPropertyTab.owner)
      end

      if networked then
        entity:SetNWEntity('Owner', entity.cwPropertyTab.owner)
      end
    end

    entity:SetNWBool('Owned', true)
    entity:SetNWInt('Key', key)
    entity:SetOwnerKey(key)

    plyProperty[entity:EntIndex()] = entity
    hook.Run('PlayerPropertyGivenOffline', key, uniqueID, entity, networked, removeDelay)
  end
end

--- Removes an entity from a character's property, whether or not its player is online.
--
-- If the player is online with that character, this calls
-- `cw.player:TakeProperty`. Otherwise ownership is only cleared if the entity
-- belongs to that key and unique ID, and `PlayerPropertyTakenOffline` fires.
-- @param key [Number The character key]
-- @param uniqueID [String The owner's `Player:UniqueID`]
-- @param entity [Entity The entity]
-- @param bAnyCharacter=nil [Boolean Unused]
function cw.player:TakePropertyOffline(key, uniqueID, entity, bAnyCharacter)
  if key and uniqueID then
    local owner = player.GetByUniqueID(uniqueID)

    if IsValid(owner) and owner:GetCharacterKey() == key then
      self:TakeProperty(owner, entity)
      return
    end

    if cw.entity:QueryProperty(entity, 'uniqueID') == uniqueID
    and cw.entity:QueryProperty(entity, 'key') == key then
      entity.cwPropertyTab = nil
      entity:SetNWEntity('Owner', NULL)
      entity:SetNWBool('Owned', false)
      entity:SetNWInt('Key', 0)
      entity:SetOwnerKey(nil)

      if entity.SetPlayer then
        entity:SetVar('Founder', nil)
        entity:SetVar('FounderIndex', nil)
        entity:SetNWString('FounderName', '')
      end

      plyProperty[entity:EntIndex()] = nil
      hook.Run('PlayerPropertyTakenOffline', key, uniqueID, entity)
    end
  end
end

--- Removes an entity from the player's property.
--
-- Does nothing unless the player owns the entity. Fires `PlayerPropertyTaken`.
-- @param player [Player The owner]
-- @param entity [Entity The entity]
-- @see cw.player:GiveProperty
function cw.player:TakeProperty(player, entity)
  if cw.entity:GetOwner(entity) == player then
    entity.cwPropertyTab = nil

    entity:SetNWEntity('Owner', NULL)
    entity:SetNWBool('Owned', false)
    entity:SetNWInt('Key', 0)
    entity:SetOwnerKey(nil)

    if entity.SetPlayer then
      entity:SetVar('Founder', nil)
      entity:SetVar('FounderIndex', nil)
      entity:SetNWString('FounderName', '')
    end

    plyProperty[entity:EntIndex()] = nil
    hook.Run('PlayerPropertyTaken', player, entity)
  end
end

--- Sets the player's skin to the one returned by `cw.player:GetDefaultSkin`.
-- @param player [Player The player]
function cw.player:SetDefaultSkin(player)
  player:SetSkin(self:GetDefaultSkin(player))
end

--- Returns the player's default skin from the `GetPlayerDefaultSkin` hook.
-- @param player [Player The player]
-- @return [Number The skin index]
function cw.player:GetDefaultSkin(player)
  return hook.Run('GetPlayerDefaultSkin', player)
end

--- Sets the player's model to the one returned by `cw.player:GetDefaultModel`.
-- @param player [Player The player]
function cw.player:SetDefaultModel(player)
  player:SetModel(self:GetDefaultModel(player))
end

--- Returns the player's default model from the `GetPlayerDefaultModel` hook.
-- @param player [Player The player]
-- @return [String The model path]
function cw.player:GetDefaultModel(player)
  return hook.Run('GetPlayerDefaultModel', player)
end

--- Returns how drunk the player is.
-- @param player [Player The player]
-- @return [Number The number of drinks still in effect, or `nil` if the player is sober]
function cw.player:GetDrunk(player)
  if player.cwDrunkTab then return #player.cwDrunkTab end
end

--- Adds a drink to the player, or sobers them up.
--
-- The level is networked through the `IsDrunk` net var.
-- @param player [Player The player]
-- @param expire [Number Seconds until the new drink wears off, or `false` to clear all drinks]
-- @see cw.player:GetDrunk
function cw.player:SetDrunk(player, expire)
  local curTime = CurTime()

  if expire == false then
    player.cwDrunkTab = nil
  elseif !player.cwDrunkTab then
    player.cwDrunkTab = { curTime + expire }
  else
    player.cwDrunkTab[#player.cwDrunkTab + 1] = curTime + expire
  end

  player:SetNetVar('IsDrunk', self:GetDrunk(player) or 0)
end

--- Removes the ammo a weapon came with when it was given.
--
-- Empties the weapon's clips and takes the item's `primaryDefaultAmmo` and
-- `secondaryDefaultAmmo` amounts from the player's reserve ammo.
-- @param player [Player The player holding the weapon]
-- @param weapon [Weapon The weapon]
-- @param itemTable=nil [Item The weapon's item; looked up from the weapon if not given]
function cw.player:StripDefaultAmmo(player, weapon, itemTable)
  if !itemTable then
    itemTable = item.GetByWeapon(weapon)
  end

  if itemTable then
    local secondaryDefaultAmmo = itemTable.secondaryDefaultAmmo
    local primaryDefaultAmmo = itemTable.primaryDefaultAmmo

    if primaryDefaultAmmo then
      local ammoClass = weapon:GetPrimaryAmmoType()

      if weapon:Clip1() != -1 then
        weapon:SetClip1(0)
      end

      if type(primaryDefaultAmmo) == 'number' then
        player:SetAmmo(
          math.max(player:GetAmmoCount(ammoClass) - primaryDefaultAmmo, 0), ammoClass
        )
      end
    end

    if secondaryDefaultAmmo then
      local ammoClass = weapon:GetSecondaryAmmoType()

      if weapon:Clip2() != -1 then
        weapon:SetClip2(0)
      end

      if type(secondaryDefaultAmmo) == 'number' then
        player:SetAmmo(
          math.max(player:GetAmmoCount(ammoClass) - secondaryDefaultAmmo, 0), ammoClass
        )
      end
    end
  end
end

--- Returns whether the player is whitelisted for a faction.
-- @param player [Player The player]
-- @param faction [String Name of the faction]
-- @return [Boolean Whether the player is whitelisted]
function cw.player:IsWhitelisted(player, faction)
  return table.HasValue(player:GetData('Whitelisted'), faction)
end

--- Adds the player to a faction's whitelist or removes them from it.
--
-- Changes the player's `Whitelisted` data, which is saved with the player, and
-- tells their client.
-- @param player [Player The player]
-- @param faction [String Name of the faction]
-- @param isWhitelisted [Boolean Whether the player should be whitelisted]
function cw.player:SetWhitelisted(player, faction, isWhitelisted)
  local whitelisted = player:GetData('Whitelisted')

  if isWhitelisted then
    if !self:IsWhitelisted(player, faction) then
      local index = 1

      -- Removing a whitelist leaves a gap, so the number of entries does not point at a free index.
      while whitelisted[index] != nil do
        index = index + 1
      end

      whitelisted[index] = faction
    end
  else
    for k, v in pairs(whitelisted) do
      if v == faction then
        whitelisted[k] = nil
      end
    end
  end

  netstream.Start(
    player, 'SetWhitelisted', { faction, isWhitelisted }
  )
end

--- Calls back after a delay, as long as a condition stays true the whole time.
--
-- The condition is checked every tick. If it fails or the player leaves, the
-- callback is called with `false`. Starting a new condition timer cancels the
-- previous one the same way.
--
-- ```
-- local position = player:GetPos()
--
-- cw.player:ConditionTimer(player, 5, function()
--   return player:Alive() and player:GetPos() == position
-- end, function(bSuccess)
--   if bSuccess then
--     player:SetHealth(player:GetMaxHealth())
--   end
-- end)
-- ```
--
-- @param player [Player The player the timer belongs to]
-- @param delay [Number Seconds the condition must hold]
-- @param Condition [Function Called without arguments; return `true` while the timer should go on]
-- @param Callback [Function Called as `Callback(bSuccess)`]
-- @see cw.player:EntityConditionTimer
function cw.player:ConditionTimer(player, delay, Condition, Callback)
  local realDelay = CurTime() + delay
  local uniqueID = player:UniqueID()

  if player.cwConditionTimer then
    player.cwConditionTimer.Callback(false)
    player.cwConditionTimer = nil
  end

  player.cwConditionTimer = {
    delay = realDelay,
    Callback = Callback,
    Condition = Condition
  }

  timer.Create('CondTimer'..uniqueID, 0, 0, function()
    if !IsValid(player) then
      timer.Remove('CondTimer'..uniqueID)
      Callback(false)
      return
    end

    -- The timer is cleared before the callback runs, so that a callback that errors is not called again every
    -- tick and one that starts a new condition timer keeps it.
    if Condition() then
      if CurTime() >= realDelay then
        timer.Remove('CondTimer'..uniqueID)
        player.cwConditionTimer = nil
        Callback(true)
      end
    else
      timer.Remove('CondTimer'..uniqueID)
      player.cwConditionTimer = nil
      Callback(false)
    end
  end)
end

--- Calls back after a delay, as long as the player keeps looking at an entity within range.
--
-- Fails like `cw.player:ConditionTimer` if the player looks away, moves out
-- of range, the target or entity becomes invalid, or the condition fails.
-- @param player [Player The player the timer belongs to]
-- @param target [Entity The target, which must stay valid]
-- @param entity=nil [Entity The entity the player must look at; defaults to `target`]
-- @param delay [Number Seconds the condition must hold]
-- @param distance [Number Maximum distance from the player's shoot position to the entity]
-- @param Condition [Function Called without arguments; return `true` while the timer should go on]
-- @param Callback [Function Called as `Callback(bSuccess)`]
function cw.player:EntityConditionTimer(player, target, entity, delay, distance, Condition, Callback)
  local realEntity = entity or target
  local realDelay = CurTime() + delay
  local uniqueID = player:UniqueID()

  if player.cwConditionEntTimer then
    player.cwConditionEntTimer.Callback(false)
    player.cwConditionEntTimer = nil
  end

  player.cwConditionEntTimer = {
    delay = realDelay, target = target,
    entity = realEntity, distance = distance,
    Callback = Callback, Condition = Condition
  }

  timer.Create('EntityCondTimer'..uniqueID, 0, 0, function()
    if !IsValid(player) then
      timer.Remove('EntityCondTimer'..uniqueID)
      Callback(false)
      return
    end

    local traceLine = player:GetEyeTraceNoCursor()

    if IsValid(target) and IsValid(realEntity) and traceLine.Entity == realEntity
    and traceLine.Entity:GetPos():Distance(player:GetShootPos()) <= distance
    and Condition() then
      if CurTime() >= realDelay then
        timer.Remove('EntityCondTimer'..uniqueID)
        player.cwConditionEntTimer = nil
        Callback(true)
      end
    else
      timer.Remove('EntityCondTimer'..uniqueID)
      player.cwConditionEntTimer = nil
      Callback(false)
    end
  end)
end

--- Returns the ammo the player was given on spawn.
-- @param player [Player The player]
-- @param ammo=nil [String An ammo type; `nil` returns the whole table]
-- @return [Number The amount of that ammo type, or a `Map` of amounts by ammo type when `ammo` is `nil`]
function cw.player:GetSpawnAmmo(player, ammo)
  if ammo then
    return player.cwSpawnAmmo[ammo]
  else
    return player.cwSpawnAmmo
  end
end

--- Returns whether a weapon was given to the player on spawn.
-- @param player [Player The player]
-- @param weapon [String The weapon class]
-- @return [Boolean `true` if it is a spawn weapon, otherwise `nil`]
function cw.player:GetSpawnWeapon(player, weapon)
  if weapon then
    return player.cwSpawnWeps[weapon]
  end
end

--- Takes ammo that was given on spawn from the player.
--
-- Does nothing if the player has no spawn ammo of that type, and takes at most
-- the spawn amount.
-- @param player [Player The player]
-- @param ammo [String The ammo type]
-- @param amount [Number How much to take]
function cw.player:TakeSpawnAmmo(player, ammo, amount)
  if player.cwSpawnAmmo[ammo] then
    if player.cwSpawnAmmo[ammo] < amount then
      amount = player.cwSpawnAmmo[ammo]

      player.cwSpawnAmmo[ammo] = nil
    else
      player.cwSpawnAmmo[ammo] = player.cwSpawnAmmo[ammo] - amount
    end

    player:RemoveAmmo(amount, ammo)
  end
end

--- Gives the player ammo and records it as spawn ammo.
--
-- Spawn ammo is not saved with the character.
-- @param player [Player The player]
-- @param ammo [String The ammo type]
-- @param amount [Number How much to give]
function cw.player:GiveSpawnAmmo(player, ammo, amount)
  if player.cwSpawnAmmo[ammo] then
    player.cwSpawnAmmo[ammo] = player.cwSpawnAmmo[ammo] + amount
  else
    player.cwSpawnAmmo[ammo] = amount
  end

  player:GiveAmmo(amount, ammo)
end

--- Strips a spawn weapon from the player.
-- @param player [Player The player]
-- @param class [String The weapon class]
function cw.player:TakeSpawnWeapon(player, class)
  player.cwSpawnWeps[class] = nil
  player:StripWeapon(class)
end

--- Gives the player a weapon and records it as a spawn weapon.
--
-- Spawn weapons are not saved with the character.
-- @param player [Player The player]
-- @param class [String The weapon class]
function cw.player:GiveSpawnWeapon(player, class)
  player.cwSpawnWeps[class] = true
  player:Give(class)
end

--- Gives the player the weapon of a weapon item.
-- @param player [Player The player]
-- @param itemTable [Item The weapon item]
-- @return [Boolean `true` if the item is a weapon, otherwise `nil`]
function cw.player:GiveItemWeapon(player, itemTable)
  if item.IsWeapon(itemTable) then
    player:Give(itemTable:GetWeaponClass(), itemTable)
    return true
  end
end

--- Gives the player the weapon of a weapon item and records it as a spawn weapon.
-- @param player [Player The player]
-- @param itemTable [Item The weapon item]
-- @return [Boolean `true` if the item is a weapon, otherwise `nil`]
function cw.player:GiveSpawnItemWeapon(player, itemTable)
  if item.IsWeapon(itemTable) then
    player.cwSpawnWeps[itemTable:GetWeaponClass()] = true
    player:Give(itemTable:GetWeaponClass(), itemTable)

    return true
  end
end

--- Gives flags to the player's current character.
--
-- Fires `PlayerFlagsGiven` for each flag the character did not have.
-- @param player [Player The player]
-- @param flags [String The flags, one character each]
-- @see cw.player:TakeFlags
-- @see cw.player:GivePlayerFlags
function cw.player:GiveFlags(player, flags)
  for i = 1, #flags do
    local flag = string.utf8sub(flags, i, i)

    if !string.find(player:GetFlags(), flag, 1, true) then
      player:SetCharacterData('Flags', player:GetFlags()..flag, true)

      hook.Run('PlayerFlagsGiven', player, flag)
    end
  end
end

--- Gives flags to the player across all of their characters.
--
-- Stored in the player's `Flags` data. Fires `PlayerFlagsGiven` for each flag
-- the player did not have.
-- @param player [Player The player]
-- @param flags [String The flags, one character each]
-- @see cw.player:TakePlayerFlags
function cw.player:GivePlayerFlags(player, flags)
  for i = 1, #flags do
    local flag = string.utf8sub(flags, i, i)

    if !string.find(player:GetPlayerFlags(), flag, 1, true) then
      player:SetData('Flags', player:GetPlayerFlags()..flag, true)

      hook.Run('PlayerFlagsGiven', player, flag)
    end
  end
end

--- Plays a sound on the player's client.
-- @param player [Player The player, a list of players, or `nil` for everyone]
-- @param sound [String Path of the sound file]
function cw.player:PlaySound(player, sound)
  netstream.Start(player, 'PlaySound', sound)
end

--- Returns how many characters the player may have.
--
-- One per faction that is not whitelisted or that the player is whitelisted
-- for, plus the `additional_characters` config.
-- @param player [Player The player]
-- @return [Number The maximum number of characters]
function cw.player:GetMaximumCharacters(player)
  local maximum = config.Get('additional_characters'):Get()

  for k, v in pairs(faction.GetAll()) do
    if !v.whitelist or self:IsWhitelisted(player, v.name) then
      maximum = maximum + 1
    end
  end

  return maximum
end

--- Returns a field of the player's current character table.
--
-- The key is converted to camel case, so `'Name'` and `'name'` both read
-- `character.name`.
-- @param player [Player The player]
-- @param key [String The field, such as `'Name'`, `'Cash'` or `'Faction'`]
-- @param default=nil [Any Value to return if there is no character or the field is `nil`]
-- @return [Any The value, or `default`]
function cw.player:Query(player, key, default)
  local character = player:GetCharacter()

  if character then
    key = cw.core:SetCamelCase(key, true)

    if character[key] != nil then
      return character[key]
    end
  end

  return default
end

--- Moves the player to a position, nudging them to a nearby free spot if they would be stuck.
-- @param player [Player The player]
-- @param position [Vector The position]
-- @param filter=nil [Entity An entity, list of entities or trace filter function that does not count as blocking]
-- @see cw.player:GetSafePosition
function cw.player:SetSafePosition(player, position, filter)
  player:SetPos(position + Vector(0, 0, 16))

  if player:IsStuck() then
    player:DropToFloor()
    player:SetPos(player:GetPos() + Vector(0, 0, 16))

    if !istable(filter) and !isfunction(filter) then
      filter = { filter }
    end

    if istable(filter) then
      table.insert(filter, player)
    end

    if !player:IsStuck() then return end

    local positions = cw.player:GetSafePosition(player, player:GetPos(), filter, 3)

    for k, v in ipairs(positions) do
      player:SetPos(v)

      if !player:IsStuck() then
        return
      else
        player:DropToFloor()

        if !player:IsStuck() then
          return
        end
      end
    end
  end
end

--- Returns free spots on a grid around a position, sorted from nearest to farthest.
--
-- A spot is free if traces through a player-sized box there and from
-- `position` to it hit nothing.
-- @param player [Player The player, ignored by the traces unless `filter` is given]
-- @param position [Vector The center position]
-- @param filter=nil [Any Trace filter; defaults to the player]
-- @param margin=3 [Number Grid radius in steps; the step size is `margin * 10` units]
-- @return [List<Vector> The free positions]
function cw.player:GetSafePosition(player, position, filter, margin)
  margin = margin or 3

  local pos = position
  local min, max = Vector(-16, -16, 0), Vector(16, 16, 32)
  local positions = {}

  for x = -margin, margin do
    for y = -margin, margin do
      local pick = pos + Vector(x * margin * 10, y * margin * 10, 0)

      if !util.IsInWorld(pick) then continue end

      local data = {}
        data.start = pick + min + Vector(0, 0, margin * 1.25)
        data.endpos = pick + max
        data.filter = filter or player
      local trace = util.TraceLine(data)

      if trace.StartSolid or trace.Hit then continue end

      data.start = pick + Vector(-max.x, -max.y, margin * 1.25)
      data.endpos = pick + Vector(min.x, min.y, 32)

      local trace2 = util.TraceLine(data)

      if trace2.StartSolid or trace2.Hit then continue end

      data.start = pos
      data.endpos = pick

      local trace3 = util.TraceLine(data)

      if trace3.Hit or trace3.StartSolid then continue end

      table.insert(positions, pick)
    end
  end

  table.sort(positions, function(a, b)
    return a:Distance(pos) < b:Distance(pos)
  end)

  return positions
end

--- Decodes a JSON data string.
-- @param player [Player Unused]
-- @param data [String The JSON string]
-- @return [Map The decoded table, or an empty table if it cannot be decoded]
function cw.player:ConvertDataString(player, data)
  local bSuccess, value = pcall(util.JSONToTable, data)

  if bSuccess and value != nil then
    return value
  else
    return {}
  end
end

--- Gives the player back the property of their current character that is still registered to them.
--
-- Fires `PlayerReturnProperty`.
-- @param player [Player The player]
-- @see cw.player:DisableProperty
function cw.player:ReturnProperty(player)
  local uniqueID = player:UniqueID()
  local key = player:GetCharacterKey()

  for k, v in pairs(self:GetAllProperty()) do
    if IsValid(v) then
      if uniqueID == cw.entity:QueryProperty(v, 'uniqueID') then
        if key == cw.entity:QueryProperty(v, 'key') then
          self:GiveProperty(player, v, cw.entity:QueryProperty(v, 'networked'))
        end
      end
    end
  end

  hook.Run('PlayerReturnProperty', player)
end

--- Takes flags from the player's current character.
--
-- Fires `PlayerFlagsTaken` for each flag the character had.
-- @param player [Player The player]
-- @param flags [String The flags, one character each]
-- @see cw.player:GiveFlags
function cw.player:TakeFlags(player, flags)
  for i = 1, #flags do
    local flag = string.utf8sub(flags, i, i)

    if flag != '' and string.find(player:GetFlags(), flag, 1, true) then
      player:SetCharacterData('Flags', string.Replace(player:GetFlags(), flag, ''), true)

      hook.Run('PlayerFlagsTaken', player, flag)
    end
  end
end

--- Takes flags from the player's player-wide flags.
--
-- Fires `PlayerFlagsTaken` for each flag the player had.
-- @param player [Player The player]
-- @param flags [String The flags, one character each]
-- @see cw.player:GivePlayerFlags
function cw.player:TakePlayerFlags(player, flags)
  for i = 1, #flags do
    local flag = string.utf8sub(flags, i, i)

    if flag != '' and string.find(player:GetPlayerFlags(), flag, 1, true) then
      player:SetData('Flags', string.Replace(player:GetPlayerFlags(), flag, ''), true)

      hook.Run('PlayerFlagsTaken', player, flag)
    end
  end
end

--- Opens or closes the main menu on the player's client.
-- @param player [Player The player]
-- @param isOpen [Boolean Whether the menu should be open]
function cw.player:SetMenuOpen(player, isOpen)
  netstream.Start(player, 'MenuOpen', isOpen)
end

--- Sets whether the player has initialized, through the `Initialized` net var.
-- @param player [Player The player]
-- @param initialized [Boolean Whether the player has initialized]
function cw.player:SetInitialized(player, initialized)
  player:SetNetVar('Initialized', initialized)
end

--- Returns whether the player's character has at least one of the given flags.
--
-- The `s`, `a` and `o` flags are granted by the superadmin, admin and
-- operator user groups. Unless `bByDefault` is set, the player's class flags
-- and the `PlayerDoesHaveFlag` hook also count; the hook returning `false`
-- denies a flag.
-- @param player [Player The player]
-- @param flags [String The flags, one character each]
-- @param bByDefault=nil [Boolean Only check the character's own flags and user group]
-- @return [Boolean `true` if the player has any of the flags, otherwise `nil`]
-- @see cw.player:HasFlags
function cw.player:HasAnyFlags(player, flags, bByDefault)
  if player:GetCharacter() then
    local playerFlags = player:GetFlags()

    if cw.class:HasAnyFlags(player:Team(), flags) and !bByDefault then
      return true
    end

    for i = 1, #flags do
      local flag = string.utf8sub(flags, i, i)
      local bSuccess = true

      if !bByDefault then
        local hasFlag = hook.Run('PlayerDoesHaveFlag', player, flag)

        if hasFlag != false then
          if hasFlag then
            return true
          end
        else
          bSuccess = nil
        end
      end

      if bSuccess then
        if flag == 's' then
          if player:IsSuperAdmin() then
            return true
          end
        elseif flag == 'a' then
          if player:IsAdmin() then
            return true
          end
        elseif flag == 'o' then
          if player:IsSuperAdmin() or player:IsAdmin() then
            return true
          elseif player:IsUserGroup('operator') then
            return true
          end
        elseif flag != '' and string.find(playerFlags, flag, 1, true) then
          return true
        end
      end
    end
  end
end

--- Returns whether the player's character has the given flags.
--
-- The `s`, `a` and `o` flags are granted by the superadmin, admin and
-- operator user groups. Unless `bByDefault` is set, the player's class flags
-- and the `PlayerDoesHaveFlag` hook also count. Without `bIsStrict`, having
-- any one of the flags is enough; with it, all of them are required and the
-- hook returning `false` denies a flag.
-- @param player [Player The player]
-- @param flags [String The flags, one character each]
-- @param bByDefault=nil [Boolean Only check the character's own flags and user group]
-- @param bIsStrict=nil [Boolean Require every flag]
-- @return [Boolean `true` if the check passes, otherwise `nil`]
-- @see cw.player:HasAnyFlags
function cw.player:HasFlags(player, flags, bByDefault, bIsStrict)
  if player:GetCharacter() then
    local playerFlags = player:GetFlags()

    if cw.class:HasFlags(player:Team(), flags) and !bByDefault then
      return true
    end

    if !bIsStrict then
      for i = 1, #flags do
        local v = string.sub(flags, i, i)

        if !bByDefault then
          local hasFlag = hook.Run('PlayerDoesHaveFlag', player, v)

          if hasFlag then
            return true
          end
        end

        if v == 's' then
          if player:IsSuperAdmin() then
            return true
          end
        elseif v == 'a' then
          if player:IsAdmin() then
            return true
          end
        elseif v == 'o' then
          if player:IsUserGroup('operator') or player:IsAdmin() then
            return true
          end
        end

        if string.find(playerFlags, v, 1, true) then
          return true
        end
      end
    end

    for i = 1, #flags do
      local flag = string.utf8sub(flags, i, i)
      local bSuccess

      if !bByDefault then
        local hasFlag = hook.Run('PlayerDoesHaveFlag', player, flag)

        if hasFlag != false then
          if hasFlag then
            bSuccess = true
          end
        else
          return
        end
      end

      if !bSuccess then
        if flag == 's' then
          if !player:IsSuperAdmin() then
            return
          end
        elseif flag == 'a' then
          if !player:IsAdmin() then
            return
          end
        elseif flag == 'o' then
          if !player:IsSuperAdmin() and !player:IsAdmin() then
            if !player:IsUserGroup('operator') then
              return
            end
          end
        elseif !string.find(playerFlags, flag, 1, true) then
          return
        end
      end
    end

    return true
  end
end

--- Uses up the player's death code after they act while knocked out.
--
-- Fires `PlayerDeathCodeUsed` and takes the code.
-- @param player [Player The player]
-- @param commandTable=nil [Command The command the code was used for, or `nil` for chat]
-- @param arguments [List<String> The command arguments or the chat text]
-- @see cw.player:GiveDeathCode
function cw.player:UseDeathCode(player, commandTable, arguments)
  hook.Run('PlayerDeathCodeUsed', player, commandTable, arguments)

  self:TakeDeathCode(player)
end

--- Returns the player's death code.
-- @param player [Player The player]
-- @param authenticated=nil [Boolean Only return the code if the player has authenticated it]
-- @return [Number The code, or `nil` if there is none]
function cw.player:GetDeathCode(player, authenticated)
  if player.cwDeathCodeIdx and (!authenticated or player.cwDeathCodeAuth) then
    return player.cwDeathCodeIdx
  end
end

--- Removes the player's death code.
-- @param player [Player The player]
function cw.player:TakeDeathCode(player)
  player.cwDeathCodeAuth = nil
  player.cwDeathCodeIdx = nil
end

--- Gives the player a new random death code and sends it to their client.
--
-- Called when the player is knocked out.
-- @param player [Player The player]
function cw.player:GiveDeathCode(player)
  player.cwDeathCodeIdx = math.random(0, 99999)
  player.cwDeathCodeAuth = nil

  netstream.Start(player, 'ChatBoxDeathCode', player.cwDeathCodeIdx)
end

--- Takes a door from the player and refunds half the `door_cost` config.
--
-- Parent and child doors are taken with it unless `bThisDoorOnly` is set. The
-- door is unlocked if `PlayerCanUnlockEntity` allows it, its text is cleared,
-- and `PlayerDoorTaken` fires. Non-map `prop_dynamic` doors are removed.
-- @param player [Player The owner]
-- @param door [Entity The door]
-- @param bForce=nil [Boolean Do not refund the door]
-- @param bThisDoorOnly=nil [Boolean Do not take the door's parent or children]
-- @param bChildrenOnly=nil [Boolean Take the children even if the door has a parent, instead of going through the
-- parent]
-- @see cw.player:GiveDoor
function cw.player:TakeDoor(player, door, bForce, bThisDoorOnly, bChildrenOnly)
  local doorCost = config.Get('door_cost'):Get()

  if !bThisDoorOnly then
    local doorParent = cw.entity:GetDoorParent(door)

    if !doorParent or bChildrenOnly then
      for k, v in pairs(cw.entity:GetDoorChildren(door)) do
        if IsValid(v) then
          self:TakeDoor(player, v, true, true)
        end
      end
    else
      return self:TakeDoor(player, doorParent, bForce)
    end
  end

  if hook.Run('PlayerCanUnlockEntity', player, door) then
    door:Fire('unlock', '', 0)
    door:EmitSound('doors/door_latch3.wav')
  end

  cw.entity:SetDoorText(door, false)
  self:TakeProperty(player, door)

  hook.Run('PlayerDoorTaken', player, door)

  if door:GetClass() == 'prop_dynamic' then
    if !door:IsMapEntity() then
      door:Remove()
    end
  end

  if !bForce and doorCost > 0 then
    self:GiveCash(player, doorCost / 2, L('CashReason_DoorSale'))
  end
end

--- Broadcasts what a player says over the radio.
--
-- `PlayerAdjustRadioInfo(player, info)` fills `info.listeners` with the
-- players who receive it (as values or keys). Unless `noEavesdrop` is set,
-- other players within the `talk_radius` config hear it too. With `check`,
-- `PlayerCanRadio` must return `true`. Fires `PlayerRadioUsed` once sent.
-- @param player [Player The speaking player]
-- @param text [String What the player says]
-- @param check=nil [Boolean Ask `PlayerCanRadio` first]
-- @param noEavesdrop=nil [Boolean Do not let nearby players hear it]
function cw.player:SayRadio(player, text, check, noEavesdrop)
  local eavesdroppers = {}
  local listeners = {}
  local canRadio = true
  local info = { listeners = {}, noEavesdrop = noEavesdrop, text = text }

  hook.Run('PlayerAdjustRadioInfo', player, info)

  for k, v in pairs(info.listeners) do
    if typeof(v) == 'player' then
      table.insert(listeners, v)
    elseif typeof(k) == 'player' then
      table.insert(listeners, k)
    end
  end

  if !info.noEavesdrop then
    local talkRadius = config.Get('talk_radius'):Get()
    local position = player:GetShootPos()

    for k, v in ipairs(_player.GetAll()) do
      if v:HasInitialized() and !table.HasValue(listeners, v) then
        if v:GetShootPos():Distance(position) <= talkRadius then
          table.insert(eavesdroppers, v)
        end
      end
    end
  end

  if check then
    canRadio = hook.Run('PlayerCanRadio', player, info.text, listeners, eavesdroppers)
  end

  if canRadio then
    info = chatbox.AddText(listeners, '"'..info.text..'"', {
      suffix = ' #Suffix_Radio ',
      sender = player,
      isPlayerMessage = true,
      filter = 'ic',
      radius = 0,
      textColor = Color(10, 200, 10, 255),
      data = { radio = true }
    })

    if info and IsValid(info.sender) then
      chatbox.AddText(eavesdroppers, info.text, {
        suffix = ' #Suffix_Radio ',
        sender = player,
        isPlayerMessage = true,
        filter = 'ic',
        radius = 0,
        textColor = Color(255, 255, 200, 255),
        data = { radio = true }
      })

      hook.Run('PlayerRadioUsed', player, info.text, listeners, eavesdroppers)
    end
  end
end

--- Returns the faction table of the player's current faction.
-- @param player [Player The player]
-- @return [Faction The faction, or `nil` if it does not exist]
function cw.player:GetFactionTable(player)
  return faction.GetAll()[player:GetFaction()]
end

--- Gives a door, and its parent and children, to the player.
--
-- Resets the door's access list, sets its text, makes it networked property
-- of the player and fires `PlayerDoorGiven`. The door is unlocked if
-- `PlayerCanUnlockEntity` allows it. Does nothing if the entity is not a door.
-- @param player [Player The new owner]
-- @param door [Entity The door]
-- @param name=nil [String Text to show on the door]
-- @param unsellable=nil [Boolean Prevent the player from selling the door]
-- @param override=nil [Boolean Give this door directly instead of going through its parent]
-- @see cw.player:TakeDoor
function cw.player:GiveDoor(player, door, name, unsellable, override)
  if cw.entity:IsDoor(door) then
    local doorParent = cw.entity:GetDoorParent(door)

    if doorParent and !override then
      self:GiveDoor(player, doorParent, name, unsellable)
    else
      for k, v in pairs(cw.entity:GetDoorChildren(door)) do
        if IsValid(v) then
          self:GiveDoor(player, v, name, unsellable, true)
        end
      end

      door.unsellable = unsellable
      door.accessList = {}

      cw.entity:SetDoorText(door, name or '')
      self:GiveProperty(player, door, true)

      hook.Run('PlayerDoorGiven', player, door)

      if hook.Run('PlayerCanUnlockEntity', player, door) then
        door:EmitSound('doors/door_latch3.wav')
        door:Fire('unlock', '', 0)
      end
    end
  end
end

--- Returns a trace of what the player is looking at, seeing through vehicles and non-solid entities.
--
-- Uses a 4096 unit trace with a solid and hitbox mask when it hits an entity
-- that the normal eye trace misses or hits a vehicle instead.
-- @param player [Player The player]
-- @param useFilterTrace=nil [Boolean Always use the masked trace]
-- @return [Map The trace result]
function cw.player:GetRealTrace(player, useFilterTrace)
  local eyePos = player:EyePos()
  local trace = player:GetEyeTraceNoCursor()

  local newTrace = util.TraceLine({
    endpos = eyePos + (player:GetAimVector() * 4096),
    filter = player,
    start = eyePos,
    mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER
  })

  if (IsValid(newTrace.Entity) and (!IsValid(trace.Entity)
  or trace.Entity:IsVehicle()) and !newTrace.HitWorld) or useFilterTrace then
    trace = newTrace
  end

  return trace
end

--- Returns whether a player recognises another player's character.
--
-- Always `true` when the `recognise_system` config is off. Otherwise the
-- result of the `PlayerDoesRecognisePlayer` hook, which receives the stored
-- status.
-- @param player [Player The player who would recognise]
-- @param target [Player The player to be recognised]
-- @param status=RECOGNISE_PARTIAL [Number The minimum `RECOGNISE_*` level]
-- @param isAccurate=nil [Boolean Require exactly `status` instead of at least it]
-- @return [Boolean Whether the player recognises the target]
-- @see cw.player:SetRecognises
function cw.player:DoesRecognise(player, target, status, isAccurate)
  if !status then
    return self:DoesRecognise(player, target, RECOGNISE_PARTIAL)
  elseif config.Get('recognise_system'):Get() then
    local recognisedNames = player:GetRecognisedNames()
    local realValue = false
    local key = target:GetCharacterKey()

    if recognisedNames and recognisedNames[key] then
      if isAccurate then
        realValue = (recognisedNames[key] == status)
      else
        realValue = (recognisedNames[key] >= status)
      end
    end

    return hook.Run('PlayerDoesRecognisePlayer', player, target, status, isAccurate, realValue)
  else
    return true
  end
end

--- Returns the name a player knows another player by.
-- @param player [Player The player looking]
-- @param target [Player The player being named]
-- @return [String The target's name if recognised, otherwise their unrecognised name]
function cw.player:GetName(player, target)
  if self:DoesRecognise(player, target) then
    return target:Name()
  else
    return self:GetUnrecognisedName(target)
  end
end

--- Tells the player's client that character creation failed.
-- @param player [Player The player]
-- @param fault=nil [String The reason; defaults to the `CharFault_Unknown` phrase]
function cw.player:SetCreateFault(player, fault)
  if !fault then
    fault = L('CharFault_Unknown')
  end

  netstream.Start(player, 'CharacterFinish', { bSuccess = false, fault = fault })
end

--- Deletes one of the player's characters without asking any hooks first.
--
-- Deletes the row from the characters table, removes the character from the
-- player's list and their client, and fires `PlayerDeleteCharacter`, which
-- can return `true` to skip the log message.
-- @param player [Player The player]
-- @param characterID [Number The character slot]
-- @see cw.player:DeleteCharacter
function cw.player:ForceDeleteCharacter(player, characterID)
  local charactersTable = config.Get('mysql_characters_table'):Get()
  local schemaFolder = cw.core:GetSchemaFolder()
  local character = player.cwCharacterList[characterID]

  if character then
    local queryObj = cwDatabase:Delete(charactersTable)
      queryObj:Where('_Schema', schemaFolder)
      queryObj:Where('_SteamID', player:SteamID())
      queryObj:Where('_CharacterID', characterID)
    queryObj:Execute()

    if !hook.Run('PlayerDeleteCharacter', player, character) then
      cw.core:PrintLog(LOGTYPE_GENERIC, player:SteamName().." has deleted the character '"..character.name.."'.")
    end

    player.cwCharacterList[characterID] = nil

    netstream.Start(player, 'CharacterRemove', characterID)
  end
end

--- Deletes one of the player's characters if they are allowed to.
--
-- The active character cannot be deleted. `PlayerCanDeleteCharacter` may
-- return `false` or a reason string to block it.
-- @param player [Player The player]
-- @param characterID [Number The character slot]
-- @return [Boolean Whether the character was deleted, String The reason if it was not]
-- @see cw.player:ForceDeleteCharacter
function cw.player:DeleteCharacter(player, characterID)
  local character = player.cwCharacterList[characterID]

  if character then
    if player:GetCharacter() != character then
      local fault = hook.Run('PlayerCanDeleteCharacter', player, character)

      if fault == nil or fault == true then
        self:ForceDeleteCharacter(player, characterID)

        return true
      elseif type(fault) != 'string' then
        return false, L('CharFault_CannotDelete')
      else
        return false, fault
      end
    else
      return false, L('CharFault_CannotDeleteActive')
    end
  else
    return false, L('CharFault_InvalidCharacter')
  end
end

--- Switches the player to one of their characters if they are allowed to.
--
-- Checks `PlayerCanUseCharacter`, the faction limit (unless
-- `PlayerCanBypassFactionLimit` returns `true`) and `PlayerCanSwitchCharacter`,
-- then loads the character with `cw.player:LoadCharacter`. If the character
-- menu was reset, the current character is respawned instead.
-- @param player [Player The player]
-- @param characterID [Number The character slot]
-- @return [Boolean Whether the character is being used, String The reason if it is not]
function cw.player:UseCharacter(player, characterID)
  local isCharacterMenuReset = player:IsCharacterMenuReset()
  local currentCharacter = player:GetCharacter()
  local character = player.cwCharacterList[characterID]

  if !character then
    return false, L('CharFault_InvalidCharacter')
  end

  if currentCharacter != character or isCharacterMenuReset then
    local factionTable = _faction.FindByID(character.faction)

    if !factionTable then
      return false, L('InvalidFaction')
    end

    local fault = hook.Run('PlayerCanUseCharacter', player, character)

    if fault == nil or fault == true then
      local players = #_faction.GetPlayers(character.faction)
      local limit = _faction.GetLimit(factionTable.name)

      if isCharacterMenuReset and character.faction == currentCharacter.faction then
        players = players - 1
      end

      if hook.Run('PlayerCanBypassFactionLimit', player, character) then
        limit = nil
      end

      if limit and players >= limit then
        return false, L('CharFault_FactionFull', character.faction, limit, limit)
      else
        if currentCharacter then
          local fault = hook.Run('PlayerCanSwitchCharacter', player, character)

          if fault != nil and fault != true then
            return false, fault or L('CharFault_CannotSwitch')
          end
        end

        cw.core:PrintLog(LOGTYPE_GENERIC, player:SteamName().." has loaded the character '"..character.name.."'.")

        if isCharacterMenuReset then
          player.cwCharMenuReset = false
          player:Spawn()
        else
          self:LoadCharacter(player, characterID)
        end

        return true
      end
    else
      return false, fault or L('CharFault_CannotUse')
    end
  else
    return false, L('CharFault_AlreadyUsing')
  end
end

--- Returns the player's current character.
-- @param player [Player The player]
-- @return [Character The character table, or `nil` if they have none loaded]
function cw.player:GetCharacter(player)
  return player.cwCharacter
end

--- Returns what players who do not recognise the player see instead of their name.
--
-- This is the player's physical description, or the `unrecognised_name`
-- config if it is empty.
-- @param player [Player The player]
-- @param bFormatted=nil [Boolean Shorten it to 24 characters and wrap it in square brackets]
-- @return [String The unrecognised name, Boolean Whether the physical description was used]
function cw.player:GetUnrecognisedName(player, bFormatted)
  local unrecognisedPhysDesc = self:GetPhysDesc(player)
  local unrecognisedName = config.Get('unrecognised_name'):Get()
  local usedPhysDesc = false

  if unrecognisedPhysDesc != '' then
    unrecognisedName = unrecognisedPhysDesc
    usedPhysDesc = true
  end

  if bFormatted then
    if string.utf8len(unrecognisedName) > 24 then
      unrecognisedName = string.utf8sub(unrecognisedName, 1, 21)..'...'
    end

    unrecognisedName = '['..unrecognisedName..']'
  end

  return unrecognisedName, usedPhysDesc
end

--- Replaces each `%s` in a text with the name a player knows each given player by.
--
-- ```
-- local text = cw.player:FormatRecognisedText(listener, '%s hands %s a crowbar.', giver, receiver)
-- ```
--
-- @param player [Player The player who reads the text]
-- @param text [String The text with one `%s` per player]
-- @param ... [Player The players to name, in order]
-- @return [String The formatted text]
function cw.player:FormatRecognisedText(player, text, ...)
  local arguments = { ... }

  for i = 1, #arguments do
    if string.find(text, '%%s') and IsValid(arguments[i]) then
      local unrecognisedName = '['..self:GetUnrecognisedName(arguments[i])..']'

      if self:DoesRecognise(player, arguments[i]) then
        unrecognisedName = arguments[i]:Name()
      end

      -- A '%' in a name or physical description must not be read as part of the replacement pattern.
      unrecognisedName = string.gsub(unrecognisedName, '%%', '%%%%')
      text = string.gsub(text, '%%s', unrecognisedName, 1)
    end
  end

  return text
end

--- Re-sends a saved recognition of a player, or forgets it if `PlayerCanRestoreRecognisedName` refuses.
-- @param player [Player The player who recognises]
-- @param target [Player The player who is recognised]
function cw.player:RestoreRecognisedName(player, target)
  local recognisedNames = player:GetRecognisedNames()
  local key = target:GetCharacterKey()

  if recognisedNames[key] then
    if hook.Run('PlayerCanRestoreRecognisedName', player, target) then
      self:SetRecognises(player, target, recognisedNames[key], true)
    else
      recognisedNames[key] = nil
    end
  end
end

--- Clears the player's recognised names on their client and restores the saved ones in both directions.
--
-- Restoring only happens when the `save_recognised_names` config is on.
-- @param player [Player The player]
function cw.player:RestoreRecognisedNames(player)
  netstream.Start(player, 'ClearRecognisedNames', true)

  if config.Get('save_recognised_names'):Get() then
    for k, v in ipairs(_player.GetAll()) do
      if v:HasInitialized() then
        self:RestoreRecognisedName(player, v)
        self:RestoreRecognisedName(v, player)
      end
    end
  end
end

--- Sets how well a player recognises another player's character and tells their client.
--
-- `RECOGNISE_SAVE` is only kept if the `save_recognised_names` config is on
-- and `PlayerCanSaveRecognisedName` returns `true`; it becomes
-- `RECOGNISE_TOTAL` otherwise. Does nothing if the player already recognises
-- the target at that level, unless `bForce` is set.
-- @param player [Player The player who recognises]
-- @param target [Player The player who is recognised]
-- @param status [Number A `RECOGNISE_*` level, or `false` to forget the target]
-- @param bForce=nil [Boolean Set it even if the player already recognises the target at that level]
-- @see cw.player:DoesRecognise
function cw.player:SetRecognises(player, target, status, bForce)
  local recognisedNames = player:GetRecognisedNames()
  local name = target:Name()
  local key = target:GetCharacterKey()

  --[[ I have no idea why this would happen. --]]
  if key == nil then return end

  if status == RECOGNISE_SAVE then
    if config.Get('save_recognised_names'):Get() then
      if !hook.Run('PlayerCanSaveRecognisedName', player, target) then
        status = RECOGNISE_TOTAL
      end
    else
      status = RECOGNISE_TOTAL
    end
  end

  if !status or bForce or !self:DoesRecognise(player, target, status) then
    recognisedNames[key] = status or nil

    netstream.Start(player, 'RecognisedName', {
      key = key, status = (status or 0)
    })
  end
end

--- Returns the player's physical description.
--
-- Falls back to the class's `defaultPhysDesc`, then the `default_physdesc`
-- config, then a built-in text. `GetPlayerPhysDescOverride` may replace the
-- result.
-- @param player [Player The player]
-- @return [String The physical description]
function cw.player:GetPhysDesc(player)
  local physDesc = player:GetDTString(STRING_PHYSDESC)
  local team = player:Team()

  if physDesc == '' then
    physDesc = cw.class:Query(team, 'defaultPhysDesc', '')
  end

  if physDesc == '' then
    physDesc = config.Get('default_physdesc'):Get()
  end

  if !physDesc or physDesc == '' then
    physDesc = 'Описание соответствует модели.'
  else
    physDesc = cw.core:ModifyPhysDesc(physDesc)
  end

  local override = hook.Run('GetPlayerPhysDescOverride', player, physDesc)

  if override then
    physDesc = override
  end

  return physDesc
end

--- Makes the player forget the characters they recognise.
--
-- Fires `PlayerRecognisedNamesCleared`.
-- @param player [Player The player]
-- @param status=nil [Number Only forget players recognised at this `RECOGNISE_*` level; `nil` forgets everyone]
-- @param isAccurate=nil [Boolean Match `status` exactly instead of at least]
-- @see cw.player:ClearName
function cw.player:ClearRecognisedNames(player, status, isAccurate)
  if !status then
    local character = player:GetCharacter()

    if character then
      character.recognisedNames = {}

      netstream.Start(player, 'ClearRecognisedNames', true)
    end
  else
    for k, v in ipairs(_player.GetAll()) do
      if v:HasInitialized() then
        if self:DoesRecognise(player, v, status, isAccurate) then
          self:SetRecognises(player, v, false)
        end
      end
    end
  end

  hook.Run('PlayerRecognisedNamesCleared', player, status, isAccurate)
end

--- Makes every player forget the player's character.
--
-- Fires `PlayerNameCleared`.
-- @param player [Player The player to be forgotten]
-- @param status=nil [Number Only affect players who recognise them at this `RECOGNISE_*` level]
-- @param isAccurate=nil [Boolean Match `status` exactly instead of at least]
-- @see cw.player:ClearRecognisedNames
function cw.player:ClearName(player, status, isAccurate)
  for k, v in ipairs(_player.GetAll()) do
    if v:HasInitialized() then
      if !status or self:DoesRecognise(v, player, status, isAccurate) then
        self:SetRecognises(v, player, false)
      end
    end
  end

  hook.Run('PlayerNameCleared', player, status, isAccurate)
end

--- Puts all of the player's item weapons back into their inventory and selects their hands.
--
-- Each weapon must pass `PlayerCanHolsterWeapon`; `PlayerHolsterWeapon` fires
-- for each.
-- @param player [Player The player]
function cw.player:HolsterAll(player)
  for k, v in pairs(player:GetWeapons()) do
    local class = v:GetClass()
    local itemTable = item.GetByWeapon(v)

    if itemTable and hook.Run('PlayerCanHolsterWeapon', player, itemTable, v, true, true) then
      hook.Run('PlayerHolsterWeapon', player, itemTable, v, true)
      player:StripWeapon(class)
      player:GiveItem(itemTable, true)
    end
  end

  player:SelectWeapon('cw_hands')
end

--- Bans or unbans the player's current character and saves it.
-- @param player [Player The player]
-- @param banned [Boolean Whether the character is banned]
function cw.player:SetBanned(player, banned)
  player:SetCharacterData('CharBanned', banned)
  player:SaveCharacter()
  player:SetNetVar('CharBanned', banned)
end

--- Changes the name of the player's current character.
--
-- Fires `PlayerNameChanged` unless this happens during the first spawn.
-- @param player [Player The player]
-- @param name [String The new name]
-- @param saveless=nil [Boolean Do not save the character afterwards]
function cw.player:SetName(player, name, saveless)
  local previousName = player:Name()
  local newName = name

  player:SetCharacterData('Name', newName, true)
  player:SetDTString(STRING_NAME, newName)

  if !player.cwFirstSpawn then
    hook.Run('PlayerNameChanged', player, previousName, newName)
  end

  if !saveless then
    player:SaveCharacter()
  end
end

--- Returns the property of the player's current character.
-- @param player [Player The player]
-- @param class=nil [String Only return entities of this class]
-- @return [List<Entity> The owned entities]
function cw.player:GetPropertyEntities(player, class)
  local uniqueID = player:UniqueID()
  local entities = {}
  local key = player:GetCharacterKey()

  for k, v in pairs(self:GetAllProperty()) do
    if uniqueID == cw.entity:QueryProperty(v, 'uniqueID') then
      if key == cw.entity:QueryProperty(v, 'key') then
        if !class or v:GetClass() == class then
          entities[#entities + 1] = v
        end
      end
    end
  end

  return entities
end

--- Returns how many entities the player's current character owns.
-- @param player [Player The player]
-- @param class=nil [String Only count entities of this class]
-- @return [Number The number of entities]
function cw.player:GetPropertyCount(player, class)
  local uniqueID = player:UniqueID()
  local count = 0
  local key = player:GetCharacterKey()

  for k, v in pairs(self:GetAllProperty()) do
    if uniqueID == cw.entity:QueryProperty(v, 'uniqueID') then
      if key == cw.entity:QueryProperty(v, 'key') then
        if !class or v:GetClass() == class then
          count = count + 1
        end
      end
    end
  end

  return count
end

--- Returns how many doors the player's current character owns, not counting child doors.
-- @param player [Player The player]
-- @return [Number The number of doors]
function cw.player:GetDoorCount(player)
  local uniqueID = player:UniqueID()
  local count = 0
  local key = player:GetCharacterKey()

  for k, v in pairs(self:GetAllProperty()) do
    if cw.entity:IsDoor(v) and !cw.entity:GetDoorParent(v) then
      if uniqueID == cw.entity:QueryProperty(v, 'uniqueID') then
        if player:GetCharacterKey() == cw.entity:QueryProperty(v, 'key') then
          count = count + 1
        end
      end
    end
  end

  return count
end

--- Removes the player's current character from a door's access list.
-- @param player [Player The player]
-- @param door [Entity The door]
function cw.player:TakeDoorAccess(player, door)
  if door.accessList then
    door.accessList[player:GetCharacterKey()] = false
  end
end

--- Gives the player's current character access to a door.
-- @param player [Player The player]
-- @param door [Entity The door]
-- @param access [Number `DOOR_ACCESS_BASIC` or `DOOR_ACCESS_COMPLETE`]
-- @see cw.player:HasDoorAccess
function cw.player:GiveDoorAccess(player, door, access)
  local key = player:GetCharacterKey()

  if !door.accessList then
    door.accessList = {
      [key] = access
    }
  else
    door.accessList[key] = access
  end
end

--- Returns whether the player has access to a door.
--
-- Players with the `D` flag always do. Otherwise the result comes from the
-- `PlayerDoesHaveDoorAccess` hook, asked about the parent door if the door
-- shares its parent's access and has no entry of its own.
-- @param player [Player The player]
-- @param door [Entity The door]
-- @param access=DOOR_ACCESS_BASIC [Number The access level required]
-- @param isAccurate=nil [Boolean Require exactly that level]
-- @return [Boolean Whether the player has access]
function cw.player:HasDoorAccess(player, door, access, isAccurate)
  if self:HasFlags(player, 'D') then
    return true
  end

  if !access then
    return self:HasDoorAccess(player, door, DOOR_ACCESS_BASIC, isAccurate)
  else
    local doorParent = cw.entity:GetDoorParent(door)
    local key = player:GetCharacterKey()

    if doorParent and cw.entity:DoorHasSharedAccess(doorParent)
    and (!door.accessList or door.accessList[key] == nil) then
      return hook.Run('PlayerDoesHaveDoorAccess', player, doorParent, access, isAccurate)
    else
      return hook.Run('PlayerDoesHaveDoorAccess', player, door, access, isAccurate)
    end
  end
end

--- Returns whether the player has at least an amount of cash.
--
-- Always `true` when cash is disabled.
-- @param player [Player The player]
-- @param amount [Number The amount]
-- @return [Boolean Whether the player can afford it]
function cw.player:CanAfford(player, amount)
  if config.Get('cash_enabled'):Get() then
    return (player:GetCash() >= amount)
  else
    return true
  end
end

--- Gives cash to the player's character, or takes it with a negative amount.
--
-- The amount is rounded and the balance cannot drop below zero. Shows a hint
-- with the change and fires `PlayerCashUpdated`. Does nothing when cash is
-- disabled or the amount is not a finite number.
--
-- ```
-- cw.player:GiveCash(player, -50, 'buying a crowbar')
-- ```
--
-- @param player [Player The player]
-- @param amount [Number Cash to give; negative takes it]
-- @param reason=nil [String Shown in the hint after the amount]
-- @param bNoMsg=nil [Boolean Do not show a hint]
-- @see Player:GiveCash
function cw.player:GiveCash(player, amount, reason, bNoMsg)
  amount = tonumber(amount)

  -- NaN or an infinite amount would wreck the balance for good.
  if !amount or amount != amount or math.abs(amount) == math.huge then return end

  if config.Get('cash_enabled'):Get() then
    local positiveHintColor = 'positive_hint'
    local negativeHintColor = 'negative_hint'
    local roundedAmount = math.Round(amount)
    local cash = math.Round(math.max(player:GetCash() + roundedAmount, 0))

    player:SetCharacterData('Cash', cash, true)
    player:SetNetVar('Cash', cash)

    if roundedAmount < 0 then
      roundedAmount = math.abs(roundedAmount)

      if !bNoMsg then
        if reason then
          cwHint:Send(
            player, L('CashHint_Lost', cw.core:FormatCash(roundedAmount)..' ')..'('..reason..').', 4, negativeHintColor
          )
        else
          cwHint:Send(
            player, L('CashHint_Lost', cw.core:FormatCash(roundedAmount))..'.', 4, negativeHintColor
          )
        end
      end
    elseif roundedAmount > 0 then
      if !bNoMsg then
        if reason then
          cwHint:Send(
            player, L('CashHint_Gained', cw.core:FormatCash(roundedAmount)..' ')..'('..reason..').', 4,
            positiveHintColor
          )
        else
          cwHint:Send(
            player, L('CashHint_Gained', cw.core:FormatCash(roundedAmount))..'.', 4, positiveHintColor
          )
        end
      end
    end

    hook.Run('PlayerCashUpdated', player, roundedAmount, reason, bNoMsg)
  end
end

--- Shows cinematic text with black bars to the player.
-- @param player [Player The player, a list of players, or `nil` for everyone]
-- @param text [String The text]
-- @param color=nil [Color The text color; defaults to white]
-- @param barLength=nil [Number Length of the black bars, as used by `cw.core:AddCinematicText`]
-- @param hangTime=nil [Number Seconds the text stays on screen; defaults to 3]
function cw.player:CinematicText(player, text, color, barLength, hangTime)
  netstream.Start(player, 'CinematicText', {
    text = text,
    color = color,
    barLength = barLength,
    hangTime = hangTime
  })
end

--- Shows cinematic text to every player who has initialized.
-- @param text [String The text]
-- @param color=nil [Color The text color; defaults to white]
-- @param hangTime=nil [Number Seconds the text stays on screen; defaults to 3]
function cw.player:CinematicTextAll(text, color, hangTime)
  for k, v in ipairs(_player.GetAll()) do
    if v:HasInitialized() then
      self:CinematicText(v, text, color, nil, hangTime)
    end
  end
end

--- Returns whether a player is the server owner and protected from admin actions.
--
-- The owner is set by the `owner_steamid` config, which may hold several
-- comma-separated Steam IDs. Developers recognised by the developer plugin
-- count as protected.
-- @param identifier [Player The player, or a name or Steam ID passed to `player.Find`]
-- @return [Boolean Whether the player is protected]
function cw.player:IsProtected(identifier)
  local steamID = nil
  local ownerSteamID = config.Get('owner_steamid'):Get()
  local bSuccess, value = pcall(IsValid, identifier)

  if !bSuccess or value == false then
    local player = _player.Find(identifier)

    if catDev and catDev:IsDeveloper(player) then
      return true
    end

    if IsValid(player) then
      steamID = player:SteamID()
    end
  else
    steamID = identifier:SteamID()
  end

  if string.find(ownerSteamID, ',') then
    ownerSteamID = string.gsub(ownerSteamID, ' ', '')
    ownerSteamID = string.Split(ownerSteamID, ',')

    for k, v in pairs(ownerSteamID) do
      if steamID and steamID == v then
        return true
      end
    end
  else
    if steamID and steamID == ownerSteamID then
      return true
    end
  end

  return false
end

--- Notifies every player who has initialized within a radius of a position.
-- @param text [String The text]
-- @param class [Any The notification class, see `cw.player:Notify`]
-- @param position [Vector The center position]
-- @param radius [Number The radius]
function cw.player:NotifyInRadius(text, class, position, radius)
  local listeners = {}

  for k, v in ipairs(_player.GetAll()) do
    if v:HasInitialized() then
      if position:Distance(v:GetPos()) <= radius then
        listeners[#listeners + 1] = v
      end
    end
  end

  self:Notify(listeners, text, class)
end

--- Sends a chat notification to every player.
-- @param text [String The text]
-- @param icon=nil [String Path of the icon shown next to the message]
function cw.player:NotifyAll(text, icon)
  self:Notify(nil, text, true, icon)
end

--- Sends a chat notification to admins of a given rank.
--
-- `'operator'` or `'o'` notifies all admins, `'admin'` or `'a'` notifies
-- admins who are not operators, and `'superadmin'` or `'s'` notifies
-- superadmins.
-- @param adminLevel [String The rank to notify]
-- @param text [String The text]
-- @param icon=nil [String Path of the icon shown next to the message]
function cw.player:NotifyAdmins(adminLevel, text, icon)
  for k, v in ipairs(_player.GetAll()) do
    if adminLevel == 'operator' or adminLevel == 'o' then
      if v:IsAdmin() then
        self:Notify(v, text, true, icon)
      end
    elseif adminLevel == 'admin' or adminLevel == 'a' then
      if v:IsAdmin() and !v:IsUserGroup('operator') then
        self:Notify(v, text, true, icon)
      end
    elseif adminLevel == 'superadmin' or adminLevel == 's' then
      if v:IsSuperAdmin() then
        self:Notify(v, text, true, icon)
      end
    end
  end
end

--- Notifies a player in chat or with a notification popup.
--
-- With `class` set to `true` or `nil` the text goes to chat through
-- `chatbox.AddText`. Otherwise it is a popup of that `NOTIFY_*` class.
-- @param player [Player The player, a list of players, or `nil` for everyone]
-- @param text [String The text]
-- @param class=nil [Any `true` or `nil` for chat, or a `NOTIFY_*` number for a popup]
-- @param icon=nil [String Path of the chat icon; not used for lists of players]
-- @see Player:Notify
function cw.player:Notify(player, text, class, icon)
  if type(player) == 'table' then
    for k, v in pairs(player) do
      self:Notify(v, text, class)
    end
  elseif class == true then
    if icon then
      local data = { icon = icon }
      chatbox.AddText(player, text, data)
    else
      chatbox.AddText(player, text)
    end
  elseif !class then
    if icon then
      local data = { icon = icon }
      chatbox.AddText(player, text, data)
    else
      chatbox.AddText(player, text)
    end
  else
    netstream.Start(player, 'Notification', { text = text, class = class })
  end
end

--- Gives the player back a list of weapons made by `cw.player:GetWeapons`.
--
-- Skips weapons the player already has, and spawn weapons that belonged to a
-- different team.
-- @param player [Player The player]
-- @param weapons [List<Map> The weapons, as returned by `cw.player:GetWeapons`]
-- @param bForceReturn=nil [Boolean Passed on to `Player:Give`]
function cw.player:SetWeapons(player, weapons, bForceReturn)
  for k, v in pairs(weapons) do
    if !player:HasWeapon(v.weaponData['class']) then
      if !v.teamIndex or player:Team() == v.teamIndex then
        player:Give(
          v.weaponData['class'], v.weaponData['itemTable'], bForceReturn
        )
      end
    end
  end
end

--- Gives the player ammo from a table of amounts.
-- @param player [Player The player]
-- @param ammo [Map Amounts keyed by ammo type]
function cw.player:GiveAmmo(player, ammo)
  for k, v in pairs(ammo) do player:GiveAmmo(v, k) end
end

--- Sets the player's ammo from a table of amounts.
-- @param player [Player The player]
-- @param ammo [Map Amounts keyed by ammo type]
function cw.player:SetAmmo(player, ammo)
  for k, v in pairs(ammo) do player:SetAmmo(v, k) end
end

--- Returns the player's reserve ammo of every item ammo type, without their spawn ammo.
--
-- The ammo types are the `ammoClass` of every item, adjusted by the
-- `AdjustAmmoTypes` hook.
-- @param player [Player The player]
-- @param bDoStrip=nil [Boolean Also remove all of the player's ammo]
-- @return [Map Amounts keyed by ammo type]
function cw.player:GetAmmo(player, bDoStrip)
  local spawnAmmo = self:GetSpawnAmmo(player)
  local ammoTypes = {}
  local ammo = {}

  for k, v in pairs(item.GetAll()) do
    if v.ammoClass then
      ammoTypes[v.ammoClass] = true
    end
  end

  hook.Run('AdjustAmmoTypes', ammoTypes)

  if ammoTypes then
    for k, v in pairs(ammoTypes) do
      if v then
        ammo[k] = player:GetAmmoCount(k)
      end
    end
  end

  if spawnAmmo then
    for k, v in pairs(spawnAmmo) do
      if ammo[k] then
        ammo[k] = math.max(ammo[k] - v, 0)
      end
    end
  end

  if bDoStrip then
    player:RemoveAllAmmo()
  end

  return ammo
end

--- Returns a list of the player's weapons that `cw.player:SetWeapons` can give back, and strips them.
-- @param player [Player The player]
-- @param bDoKeep=nil [Boolean Do not strip the weapons]
-- @return [List<Map> One entry per weapon with `weaponData` (`class` and `itemTable`) and `teamIndex` (only for
-- spawn weapons)]
function cw.player:GetWeapons(player, bDoKeep)
  local weapons = {}

  for k, v in pairs(player:GetWeapons()) do
    local itemTable = item.GetByWeapon(v)
    local teamIndex = player:Team()
    local class = v:GetClass()

    if !self:GetSpawnWeapon(player, class) then
      teamIndex = nil
    end

    weapons[#weapons + 1] = {
      weaponData = {
        itemTable = itemTable,
        class = class
      },
      teamIndex = teamIndex
    }

    if !bDoKeep then
      player:StripWeapon(class)
    end
  end

  return weapons
end

--- Returns the total item weight of the player's equipped weapons.
-- @param player [Player The player]
-- @return [Number The weight]
function cw.player:GetEquippedWeight(player)
  local weight = 0

  for k, v in pairs(player:GetWeapons()) do
    local itemTable = item.GetByWeapon(v)

    if itemTable then
      weight = weight + itemTable.weight
    end
  end

  return weight
end

--- Returns the total item space of the player's equipped weapons.
-- @param player [Player The player]
-- @return [Number The space]
function cw.player:GetEquippedSpace(player)
  local space = 0

  for k, v in pairs(player:GetWeapons()) do
    local itemTable = item.GetByWeapon(v)

    if itemTable then
      space = space + itemTable.space
    end
  end

  return space
end

--- Returns the class of an item weapon the player carries but is not holding.
-- @param player [Player The player]
-- @return [String The weapon class, or `nil` if there is none]
function cw.player:GetHolsteredWeapon(player)
  for k, v in pairs(player:GetWeapons()) do
    local itemTable = item.GetByWeapon(v)
    local class = v:GetClass()

    if itemTable then
      if self:GetWeaponClass(player) != class then
        return class
      end
    end
  end
end

--- Returns whether the player is ragdolled.
-- @param player [Player The player]
-- @param exception=nil [Number A `RAGDOLL_*` state that does not count as ragdolled]
-- @param bNoEntity=nil [Boolean Check the ragdoll state even if the player has no ragdoll entity]
-- @return [Boolean Whether the player is ragdolled; `nil` if they have no ragdoll entity]
function cw.player:IsRagdolled(player, exception, bNoEntity)
  if player:GetRagdollEntity() or bNoEntity then
    local ragdolled = player:GetDTInt(INT_RAGDOLLSTATE)

    if ragdolled == exception then
      return false
    else
      return (ragdolled != RAGDOLL_NONE)
    end
  end
end

--- Sets when the player gets up, shown as the `unragdoll` action.
-- @param player [Player The player]
-- @param delay [Number Seconds until the player gets up, or `false` to cancel getting up]
-- @see cw.player:GetUnragdollTime
function cw.player:SetUnragdollTime(player, delay)
  player.cwRagdollPaused = nil

  if delay then
    self:SetAction(player, 'unragdoll', delay, 2, function()
      if IsValid(player) and player:Alive() then
        self:SetRagdollState(player, RAGDOLL_NONE)
      end
    end)
  else
    self:SetAction(player, 'unragdoll', false)
  end
end

--- Pauses the countdown until the player gets up.
-- @param player [Player The player]
-- @see cw.player:StartUnragdollTime
function cw.player:PauseUnragdollTime(player)
  if !player.cwRagdollPaused then
    local unragdollTime = self:GetUnragdollTime(player)
    local curTime = CurTime()

    if player:IsRagdolled() then
      if unragdollTime > 0 then
        player.cwRagdollPaused = unragdollTime - curTime
        self:SetAction(player, 'unragdoll', false)
      end
    end
  end
end

--- Resumes a countdown paused with `cw.player:PauseUnragdollTime`.
-- @param player [Player The player]
function cw.player:StartUnragdollTime(player)
  if player.cwRagdollPaused then
    if player:IsRagdolled() then
      self:SetUnragdollTime(player, player.cwRagdollPaused)

      player.cwRagdollPaused = nil
    end
  end
end

--- Returns when the player gets up.
-- @param player [Player The player]
-- @return [Number The `CurTime` the player gets up at, or `0` if no countdown is running]
function cw.player:GetUnragdollTime(player)
  local action, actionDuration, startActionTime = self:GetAction(player)

  if action == 'unragdoll' then
    return startActionTime + actionDuration
  else
    return 0
  end
end

--- Returns the player's ragdoll state.
-- @param player [Player The player]
-- @return [Number A `RAGDOLL_*` value]
function cw.player:GetRagdollState(player)
  return player:GetDTInt(INT_RAGDOLLSTATE)
end

--- Returns the player's ragdoll entity.
-- @param player [Player The player]
-- @return [Entity The ragdoll, or `nil` if there is none]
function cw.player:GetRagdollEntity(player)
  if player.cwRagdollTab then
    if IsValid(player.cwRagdollTab.entity) then
      return player.cwRagdollTab.entity
    end
  end
end

--- Returns the table with the player's state from before they were ragdolled.
-- @param player [Player The player]
-- @return [Map The ragdoll table (`entity`, `health`, `armor`, `weapons`, `immunity` and so on), or `nil`]
function cw.player:GetRagdollTable(player)
  return player.cwRagdollTab
end

--- Starts a timer that makes the ragdoll decay once its player has left.
--
-- Checked every 60 seconds; the ragdoll decays over the `body_decay_time`
-- config if `PlayerCanRagdollDecay` returns `true`.
-- @param player [Player The player]
-- @param ragdoll [Entity The player's ragdoll]
function cw.player:DoRagdollDecayCheck(player, ragdoll)
  local index = ragdoll:EntIndex()

  timer.Create('DecayCheck'..index, 60, 0, function()
    local ragdollIsValid = IsValid(ragdoll)
    local playerIsValid = IsValid(player)

    if !playerIsValid and ragdollIsValid then
      if !cw.entity:IsDecaying(ragdoll) then
        local decayTime = config.Get('body_decay_time'):Get()

        if decayTime > 0 and hook.Run('PlayerCanRagdollDecay', player, ragdoll, decayTime) then
          cw.entity:Decay(ragdoll, decayTime)
        end
      else
        timer.Remove('DecayCheck'..index)
      end
    elseif !ragdollIsValid then
      timer.Remove('DecayCheck'..index)
    end
  end)
end

--- Sets how long the player's ragdoll is immune to damage.
-- @param player [Player A ragdolled player]
-- @param delay [Number Seconds of immunity, or `nil` to remove it]
function cw.player:SetRagdollImmunity(player, delay)
  if delay then
    player:GetRagdollTable().immunity = CurTime() + delay
  else
    player:GetRagdollTable().immunity = 0
  end
end

--- Knocks the player over into a ragdoll or gets them back up.
--
-- `RAGDOLL_KNOCKEDOUT` and `RAGDOLL_FALLENOVER` create a ragdoll (or change
-- the state of an existing one) if `PlayerCanRagdoll` returns `true`, store
-- the player's weapons, health and armor, and make the player spectate it.
-- Being knocked out gives the player a death code. `RAGDOLL_NONE` gets the
-- player up where the ragdoll lies and restores them, and `RAGDOLL_RESET` only
-- removes the ragdoll, if `PlayerCanUnragdoll` returns `true`. Fires
-- `PlayerRagdolled` or `PlayerUnragdolled`.
--
-- ```
-- cw.player:SetRagdollState(player, RAGDOLL_KNOCKEDOUT, 30)
-- ```
--
-- @param player [Player The player]
-- @param state [Number A `RAGDOLL_*` value]
-- @param delay=nil [Number Seconds until the player gets up on their own]
-- @param decay=nil [Number Seconds the ragdoll takes to decay when the player gets up; `nil` removes it]
-- @param force=nil [Vector Force applied to the ragdoll's bones]
-- @param multiplier=nil [Number Unused]
-- @param velocityCallback=nil [Function Called as `velocityCallback(physObj, boneIndex, ragdoll, velocity, force)`
-- for each bone instead of applying the velocity and force]
function cw.player:SetRagdollState(player, state, delay, decay, force, multiplier, velocityCallback)
  if state == RAGDOLL_KNOCKEDOUT or state == RAGDOLL_FALLENOVER then
    if player:IsRagdolled() then
      if hook.Run('PlayerCanRagdoll', player, state, delay, decay, player.cwRagdollTab) then
        self:SetUnragdollTime(player, delay)
          player:SetDTInt(INT_RAGDOLLSTATE, state)
          player.cwRagdollTab.delay = delay
          player.cwRagdollTab.decay = decay
        hook.Run('PlayerRagdolled', player, state, player.cwRagdollTab)
      end
    elseif hook.Run('PlayerCanRagdoll', player, state, delay, decay) then
      local velocity = player:GetVelocity() + (player:GetAimVector() * 128)
      local ragdoll = ents.Create('prop_ragdoll')
      local bodygroups = player:GetBodyGroups()
      local bgString = ''

      for k, v in ipairs(bodygroups) do
        bgString = bgString..tostring(player:GetBodygroup(v.id))
      end

      ragdoll:SetMaterial(player:GetMaterial())
      ragdoll:SetAngles(player:GetAngles())
      ragdoll:SetColor(player:GetColor())
      ragdoll:SetModel(player:GetModel())
      ragdoll:SetSkin(player:GetSkin())
      ragdoll:SetPos(player:GetPos())
      ragdoll:SetBodyGroups(bgString)
      ragdoll:Spawn()

      player.cwRagdollTab = {}
      player.cwRagdollTab.eyeAngles = player:EyeAngles()
      player.cwRagdollTab.immunity = CurTime() + config.Get('ragdoll_immunity_time'):Get()
      player.cwRagdollTab.moveType = MOVETYPE_WALK
      player.cwRagdollTab.entity = ragdoll
      player.cwRagdollTab.health = player:Health()
      player.cwRagdollTab.armor = player:Armor()
      player.cwRagdollTab.delay = delay
      player.cwRagdollTab.decay = decay

      if !player:IsOnGround() then
        player.cwRagdollTab.immunity = 0
      end

      if IsValid(ragdoll) then
        local headIndex = ragdoll:LookupBone('ValveBiped.Bip01_Head1')

        ragdoll:SetCollisionGroup(COLLISION_GROUP_WEAPON)

        -- Physics objects are numbered from zero.
        for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
          local physicsObject = ragdoll:GetPhysicsObjectNum(i)
          local boneIndex = ragdoll:TranslatePhysBoneToBone(i)
          local position, angle = player:GetBonePosition(boneIndex)

          if IsValid(physicsObject) and position then
            physicsObject:SetPos(position)
            physicsObject:SetAngles(angle)

            if !velocityCallback then
              if boneIndex == headIndex then
                physicsObject:SetVelocity(velocity * 1.5)
              else
                physicsObject:SetVelocity(velocity)
              end

              if force then
                if boneIndex == headIndex then
                  physicsObject:ApplyForceCenter(force * 1.5)
                else
                  physicsObject:ApplyForceCenter(force)
                end
              end
            else
              velocityCallback(physicsObject, boneIndex, ragdoll, velocity, force)
            end
          end
        end
      end

      if player:Alive() then
        if IsValid(player:GetActiveWeapon()) then
          player.cwRagdollTab.weapon = self:GetWeaponClass(player)
        end

        player.cwRagdollTab.weapons = self:GetWeapons(player, true)

        if delay then
          self:SetUnragdollTime(player, delay)
        end
      end

      if player:InVehicle() then
        player:ExitVehicle()
        player.cwRagdollTab.eyeAngles = Angle(0, 0, 0)
      end

      if player:IsOnFire() then
        ragdoll:Ignite(8, 0)
      end

      player:Spectate(OBS_MODE_CHASE)
      player:RunCommand('-duck')
      player:RunCommand('-voicerecord')
      player:SetMoveType(MOVETYPE_OBSERVER)
      player:StripWeapons(true)
      player:SpectateEntity(ragdoll)
      player:CrosshairDisable()

      if player:FlashlightIsOn() then
        player:Flashlight(false)
      end

      player.cwRagdollPaused = nil

      player:SetDTInt(INT_RAGDOLLSTATE, state)
      player:SetDTEntity(2, ragdoll)

      if state != RAGDOLL_FALLENOVER then
        self:GiveDeathCode(player)
      end

      cw.entity:SetPlayer(ragdoll, player)
      self:DoRagdollDecayCheck(player, ragdoll)

      hook.Run('PlayerRagdolled', player, state, player.cwRagdollTab)
    end
  elseif state == RAGDOLL_NONE or state == RAGDOLL_RESET then
    if player:IsRagdolled(nil, true) then
      local ragdollTable = player:GetRagdollTable()

      if hook.Run('PlayerCanUnragdoll', player, state, ragdollTable) then
        player:UnSpectate()
        player:CrosshairEnable()

        if state != RAGDOLL_RESET then
          self:LightSpawn(player, nil, nil, true)
        end

        if state != RAGDOLL_RESET then
          if IsValid(ragdollTable.entity) then
            local velocity = ragdollTable.entity:GetVelocity()
            local position = cw.entity:GetPelvisPosition(ragdollTable.entity)

            if position then
              self:SetSafePosition(player, position, ragdollTable.entity)
            end

            player:SetSkin(ragdollTable.entity:GetSkin())
            player:SetColor(ragdollTable.entity:GetColor())
            player:SetMaterial(ragdollTable.entity:GetMaterial())

            if !ragdollTable.model then
              player:SetModel(ragdollTable.entity:GetModel())
            else
              player:SetModel(ragdollTable.model)
            end

            if !ragdollTable.skin then
              player:SetSkin(ragdollTable.entity:GetSkin())
            else
              player:SetSkin(ragdollTable.skin)
            end

            player:SetVelocity(velocity)
          end

          player:SetArmor(ragdollTable.armor)
          player:SetHealth(ragdollTable.health)
          player:SetMoveType(ragdollTable.moveType)
          player:SetEyeAngles(ragdollTable.eyeAngles)
        end

        if IsValid(ragdollTable.entity) then
          timer.Remove('DecayCheck'..ragdollTable.entity:EntIndex())

          if ragdollTable.decay then
            if hook.Run('PlayerCanRagdollDecay', player, ragdollTable.entity, ragdollTable.decay) then
              cw.entity:Decay(ragdollTable.entity, ragdollTable.decay)
            end
          else
            ragdollTable.entity:Remove()
          end
        end

        if state != RAGDOLL_RESET then
          self:SetWeapons(player, ragdollTable.weapons or {}, true)

          if ragdollTable.weapon then
            player:SelectWeapon(ragdollTable.weapon)
          end
        end

        self:SetUnragdollTime(player, false)
          player:SetDTInt(INT_RAGDOLLSTATE, RAGDOLL_NONE)
          player:SetDTEntity(2, NULL)
        hook.Run('PlayerUnragdolled', player, state, ragdollTable)

        player.cwRagdollPaused = nil
        player.cwRagdollTab = {}
      end
    end
  end
end

--- Drops the player's item weapons as item entities, such as when they die.
--
-- Uses the ragdoll's stored weapons if the player is ragdolled. Each weapon
-- must pass `PlayerCanDropWeapon` and `PlayerAdjustDropWeaponInfo`;
-- `PlayerDropWeapon` fires for each one dropped.
-- @param player [Player The player]
function cw.player:DropWeapons(player)
  local ragdollEntity = player:GetRagdollEntity()

  if player:IsRagdolled() then
    local ragdollWeapons = player:GetRagdollWeapons()

    for k, v in pairs(ragdollWeapons) do
      local itemTable = v.weaponData['itemTable']

      if itemTable and hook.Run('PlayerCanDropWeapon', player, itemTable, NULL, true) then
        local info = {
          itemTable = itemTable,
          position = ragdollEntity:GetPos() + Vector(0, 0, math.random(1, 48)),
          angles = Angle(0, 0, 0)
        }

        player:TakeItem(info.itemTable, true)
        ragdollWeapons[k] = nil

        if hook.Run('PlayerAdjustDropWeaponInfo', player, info) then
          local entity = cw.entity:CreateItem(player, info.itemTable, info.position, info.angles)

          if IsValid(entity) then
            hook.Run('PlayerDropWeapon', player, info.itemTable, entity, NULL)
          end
        end
      end
    end
  else
    for k, v in pairs(player:GetWeapons()) do
      local itemTable = item.GetByWeapon(v)

      if itemTable and hook.Run('PlayerCanDropWeapon', player, itemTable, v, true) then
        local info = {
          itemTable = itemTable,
          position = player:GetPos() + Vector(0, 0, math.random(1, 48)),
          angles = Angle(0, 0, 0)
        }

        if hook.Run('PlayerAdjustDropWeaponInfo', player, info) then
          local entity = cw.entity:CreateItem(
            player, info.itemTable, info.position, info.angles
          )

          if IsValid(entity) then
            hook.Run('PlayerDropWeapon', player, info.itemTable, entity, v)
            player:StripWeapon(v:GetClass())
            player:TakeItem(info.itemTable, true)
          end
        end
      end
    end
  end
end

--- Respawns the player in place, keeping their position, health, armor, model and look.
--
-- Gets the player up first if they are ragdolled, unless `bForceReturn` is
-- set. Fires `PostPlayerLightSpawn` once the spawn is done.
-- @param player [Player The player]
-- @param weapons=nil [List<Map> Weapons to give back; `true` keeps the current ones]
-- @param ammo=nil [Map Ammo to give back; `true` keeps the current ammo]
-- @param bForceReturn=nil [Boolean Do not get the player up, and passed on to `cw.player:SetWeapons`]
function cw.player:LightSpawn(player, weapons, ammo, bForceReturn)
  if player:IsRagdolled() and !bForceReturn then
    self:SetRagdollState(player, RAGDOLL_NONE)
  end

  player.cwLightSpawn = true

  local moveType = player:GetMoveType()
  local material = player:GetMaterial()
  local position = player:GetPos()
  local angles = player:EyeAngles()
  local weapon = player:GetActiveWeapon()
  local health = player:Health()
  local armor = player:Armor()
  local model = player:GetModel()
  local color = player:GetColor()
  local skin = player:GetSkin()

  if ammo then
    if type(ammo) != 'table' then
      ammo = self:GetAmmo(player, true)
    end
  end

  if weapons then
    if type(weapons) != 'table' then
      weapons = self:GetWeapons(player)
    end

    if IsValid(weapon) then
      weapon = weapon:GetClass()
    end
  end

  player.cwSpawnCallback = function(player, gamemodeHook)
    if weapons then
      hook.Run('PlayerLoadout', player)

      self:SetWeapons(player, weapons, bForceReturn)

      if type(weapon) == 'string' then
        player:SelectWeapon(weapon)
      end
    end

    if ammo then
      self:GiveAmmo(player, ammo)
    end

    player:SetPos(position)
    player:SetSkin(skin)
    player:SetModel(model)
    player:SetColor(color)
    player:SetArmor(armor)
    player:SetHealth(health)
    player:SetMaterial(material)
    player:SetMoveType(moveType)
    player:SetEyeAngles(angles)

    if gamemodeHook then
      hook.Run('PostPlayerLightSpawn', player, weapons, ammo, false)
    end

    player:ResetSequence(
      player:GetSequence()
    )
  end

  player:Spawn()
end

--- Returns a copy of a database row with its column names converted to camel case.
--
-- Underscores are removed, so `_SteamName` becomes `steamName`.
-- @param baseTable [Map The row]
-- @return [Map The converted copy]
function cw.player:ConvertToCamelCase(baseTable)
  local newTable = {}

  for k, v in pairs(baseTable) do
    local key = cw.core:SetCamelCase(string.gsub(k, '_', ''), true)

    if key and key != '' then
      newTable[key] = v
    end
  end

  return newTable
end

--- Loads the player's characters for the current schema from the database.
-- @param player [Player The player]
-- @param Callback [Function Called as `Callback(characters)` with a list of camel case character tables, or with
-- `nil` if the player has none]
function cw.player:GetCharacters(player, Callback)
  if !IsValid(player) then return end

  local charactersTable = config.Get('mysql_characters_table'):Get()
  local schemaFolder = cw.core:GetSchemaFolder()
  local queryObj = cwDatabase:Select(charactersTable)
    queryObj:Where('_Schema', schemaFolder)
    queryObj:Where('_SteamID', player:SteamID())
    queryObj:Callback(function(result)
      if !IsValid(player) then return end

      if cwDatabase:IsResult(result) then
        local characters = {}

        for k, v in pairs(result) do
          characters[k] = self:ConvertToCamelCase(v)
        end

        Callback(characters)
      else
        Callback()
      end
    end)

  queryObj:Execute()
end

--- Adds a character to the player's character selection screen.
--
-- `PlayerAdjustCharacterScreenInfo(player, character, info)` can change what
-- is shown.
-- @param player [Player The player]
-- @param character [Character The character]
function cw.player:CharacterScreenAdd(player, character)
  local info = {
    name = character.name,
    model = character.model,
    banned = character.data['CharBanned'],
    faction = character.faction,
    characterID = character.characterID
  }

  if character.data['PhysDesc'] then
    if string.utf8len(character.data['PhysDesc']) > 64 then
      info.details = string.utf8sub(character.data['PhysDesc'], 1, 64)..'...'
    else
      info.details = character.data['PhysDesc']
    end
  end

  if character.data['CharBanned'] then
    info.details = L('CharScreen_Banned')
  end

  hook.Run('PlayerAdjustCharacterScreenInfo', player, character, info)
  netstream.Start(player, 'CharacterAdd', info)
end

--- Decodes the JSON and numeric fields of a character loaded from the database, in place.
--
-- Cash that is not a finite number becomes `0`.
-- @param baseTable [Character The camel case character table]
function cw.player:ConvertCharacterMySQL(baseTable)
  baseTable.recognisedNames = self:ConvertCharacterRecognisedNamesString(baseTable.recognisedNames)
  baseTable.characterID = tonumber(baseTable.characterID)
  baseTable.attributes = self:ConvertCharacterDataString(baseTable.attributes)
  baseTable.traits = self:ConvertCharacterDataString(baseTable.traits)
  baseTable.inventory = cw.inventory:ToLoadable(
    self:ConvertCharacterDataString(baseTable.inventory)
  )
  baseTable.cash = tonumber(baseTable.cash) or 0

  if baseTable.cash != baseTable.cash or math.abs(baseTable.cash) == math.huge then
    baseTable.cash = 0
  end

  baseTable.ammo = self:ConvertCharacterDataString(baseTable.ammo)
  baseTable.data = self:ConvertCharacterDataString(baseTable.data)
  baseTable.key = tonumber(baseTable.key)
end

--- Returns the slot of the player's current character.
-- @param player [Player The player]
-- @return [Number The character slot, or `nil` if they have no character loaded]
function cw.player:GetCharacterID(player)
  local character = player:GetCharacter()

  if character then
    for k, v in pairs(player:GetCharacters()) do
      if v == character then
        return k
      end
    end
  end
end

--- Loads one of the player's characters, or creates a new one in a slot.
--
-- With `tMergeCreate`, a new character with default values is merged with it,
-- given its default inventory through `GetPlayerDefaultInventory`, checked
-- with `PlayerCanCreateCharacter` (unless `bForce`), inserted into the
-- database and added to the character screen; `PlayerCharacterCreated`
-- fires. Nothing happens if the slot is taken.
--
-- Without it, the current character is saved and unloaded
-- (`PlayerCharacterUnloaded`), the character in the slot becomes current, the
-- player is killed silently to respawn as it, and `PlayerCharacterLoaded`
-- fires.
-- @param player [Player The player]
-- @param characterID [Number The character slot]
-- @param tMergeCreate=nil [Map Fields of a new character to create]
-- @param Callback=nil [Function Called without arguments once a new character is saved]
-- @param bForce=nil [Boolean Skip `PlayerCanCreateCharacter`]
function cw.player:LoadCharacter(player, characterID, tMergeCreate, Callback, bForce)
  local character = {}
  local unixTime = os.time()

  if tMergeCreate then
    character.data = {}
    character.ammo = {}
    character.cash = config.Get('default_cash'):Get()
    character.model = 'models/police.mdl'
    character.flags = 'b'
    character.schema = cw.core:GetSchemaFolder()
    character.gender = GENDER_MALE
    character.faction = FACTION_CITIZEN
    character.steamID = player:SteamID()
    character.steamName = player:SteamName()
    character.inventory = {}
    character.attributes = {}
    character.traits = { positive = {}, negative = {} }
    character.onNextLoad = ''
    character.lastPlayed = unixTime
    character.timeCreated = unixTime
    character.characterID = characterID
    character.recognisedNames = {}

    if !player.cwCharacterList[characterID] then
      table.Merge(character, tMergeCreate)

      character.inventory = {}
      hook.Run(
        'GetPlayerDefaultInventory', player, character, character.inventory
      )

      if !bForce then
        local fault = hook.Run('PlayerCanCreateCharacter', player, character, characterID)

        if fault == false or type(fault) == 'string' then
          player.cwIsCreatingChar = nil

          return self:SetCreateFault(player, fault or L('CharFault_CannotCreate'))
        end
      end

      self:SaveCharacter(player, true, character, function(key)
        if !IsValid(player) then return end

        player.cwCharacterList[characterID] = character
        player.cwCharacterList[characterID].key = key

        hook.Run('PlayerCharacterCreated', player, character)
        self:CharacterScreenAdd(player, character)

        if Callback then
          Callback()
        end
      end)
    else
      player.cwIsCreatingChar = nil
    end
  else
    character = player.cwCharacterList[characterID]

    if character then
      if player:GetCharacter() then
        self:SaveCharacter(player)
        self:UpdateCharacter(player)

        hook.Run('PlayerCharacterUnloaded', player)
      end

      player.cwCharacter = character

      if player:Alive() then
        player:KillSilent()
      end

      -- The previous character's ammo is saved with it above; left on the player, the save below would write it
      -- into this character too.
      player:StripAmmo()

      if self:SetBasicSharedVars(player) then
        hook.Run('PlayerCharacterLoaded', player)
        player:SaveCharacter()
      end
    end
  end
end

--- Networks the flags, model, name, key, faction and gender of the player's current character.
-- @param player [Player The player]
-- @return [Boolean Always `true`]
function cw.player:SetBasicSharedVars(player)
  local gender = player:GetGender()
  local playerFaction = player:GetFaction()

  player:SetDTString(STRING_FLAGS, player:GetFlags())
  player:SetNetVar('Model', self:GetDefaultModel(player))
  player:SetDTString(STRING_NAME, player:Name())
  player:SetNetVar('Key', player:GetCharacterKey())

  if faction.GetAll()[playerFaction] then
    player:SetNetVar('Faction', faction.GetAll()[playerFaction].index)
  end

  if gender == GENDER_MALE then
    player:SetNetVar('Gender', 2)
  else
    player:SetNetVar('Gender', 1)
  end

  return true
end

--- Returns a character's saved ammo merged with the player's current ammo.
-- @param player [Player The player]
-- @param character [Character The character]
-- @param bRawTable=nil [Boolean Return the table instead of JSON]
-- @return [String The ammo as JSON, or a `Map` with `bRawTable`]
function cw.player:GetCharacterAmmoString(player, character, bRawTable)
  local ammo = table.Copy(character.ammo)

  for k, v in pairs(self:GetAmmo(player)) do
    if v > 0 then
      ammo[k] = v
    end
  end

  if !bRawTable then
    return util.TableToJSON(ammo)
  else
    return ammo
  end
end

--- Returns a copy of a character's data, adjusted by the `PlayerSaveCharacterData` hook.
-- @param player [Player The player]
-- @param character [Character The character]
-- @param bRawTable=nil [Boolean Return the table instead of JSON]
-- @return [String The data as JSON, or a `Map` with `bRawTable`]
function cw.player:GetCharacterDataString(player, character, bRawTable)
  local data = table.Copy(character.data)
  hook.Run('PlayerSaveCharacterData', player, data)

  if !bRawTable then
    return util.TableToJSON(data)
  else
    return data
  end
end

--- Returns the character keys a character recognises at the `RECOGNISE_SAVE` level, as JSON.
-- @param player [Player The player]
-- @param character [Character The character]
-- @return [String A JSON list of character keys]
function cw.player:GetCharacterRecognisedNamesString(player, character)
  local recognisedNames = {}

  for k, v in pairs(character.recognisedNames) do
    if v == RECOGNISE_SAVE then
      recognisedNames[#recognisedNames + 1] = k
    end
  end

  return util.TableToJSON(recognisedNames)
end

--- Returns a copy of a character's inventory with the items added by `PlayerAddToSavedInventory`.
-- @param player [Player The player]
-- @param character [Character The character]
-- @param bRawTable=nil [Boolean Return the inventory instead of JSON]
-- @return [String The saveable inventory as JSON, or an `Inventory` with `bRawTable`]
function cw.player:GetCharacterInventoryString(player, character, bRawTable)
  local inventory = cw.inventory:CreateDuplicate(character.inventory)
  hook.Run('PlayerAddToSavedInventory', player, character, function(itemTable)
    cw.inventory:AddInstance(inventory, itemTable)
  end)

  if !bRawTable then
    return util.TableToJSON(cw.inventory:ToSaveable(inventory))
  else
    return inventory
  end
end

--- Decodes a saved list of recognised character keys.
-- @param data [String A JSON list of character keys]
-- @return [Map `RECOGNISE_SAVE` keyed by character key, or an empty table if it cannot be decoded]
function cw.player:ConvertCharacterRecognisedNamesString(data)
  local bSuccess, value = pcall(util.JSONToTable, data)

  if bSuccess and value != nil then
    local recognisedNames = {}

    for k, v in pairs(value) do
      recognisedNames[v] = RECOGNISE_SAVE
    end

    return recognisedNames
  else
    return {}
  end
end

--- Decodes a JSON data string.
-- @param data [String The JSON string]
-- @return [Map The decoded table, or an empty table if it cannot be decoded]
function cw.player:ConvertCharacterDataString(data)
  local bSuccess, value = pcall(util.JSONToTable, data)

  if bSuccess and value != nil then
    return value
  else
    return {}
  end
end

--- Loads the player's player data from the database, creating a row for new players.
--
-- Sets the player's join time, last played time, user group and data, makes
-- protected players and developers superadmins, and fires
-- `PlayerRestoreData`. Retries every 2 seconds until the data has loaded.
-- @param player [Player The player]
-- @param Callback=nil [Function Called as `Callback(player)` once the data has loaded]
-- @see cw.player:SaveData
function cw.player:LoadData(player, Callback)
  local playersTable = config.Get('mysql_players_table'):Get()
  local schemaFolder = cw.core:GetSchemaFolder()
  local unixTime = os.time()
  local steamID = player:SteamID()

  local queryObj = cwDatabase:Select(playersTable)
    queryObj:Where('_Schema', schemaFolder)
    queryObj:Where('_SteamID', steamID)
    queryObj:Callback(function(result)
      if !IsValid(player) or player.cwData then
        return
      end

      local onNextPlay = ''

      if cwDatabase:IsResult(result) then
        player.cwTimeJoined = tonumber(result[1]._TimeJoined)
        player.cwLastPlayed = tonumber(result[1]._LastPlayed)
        player.cwUserGroup = result[1]._UserGroup
        player.cwData = self:ConvertDataString(player, result[1]._Data)

        onNextPlay = result[1]._OnNextPlay
      else
        player.cwTimeJoined = unixTime
        player.cwLastPlayed = unixTime
        player.cwUserGroup = 'user'
        player.cwData = self:SaveData(player, true)
      end

      if self:IsProtected(player) then
        player.cwUserGroup = 'superadmin'
      end

      if catDev and catDev:IsDeveloper(player) then
        player.cwUserGroup = 'superadmin'
      end

      if !player.cwUserGroup or player.cwUserGroup == '' then
        player.cwUserGroup = 'user'
      end

      if !config.Get('use_own_group_system'):Get()
      and player.cwUserGroup != 'user' then
        player:SetUserGroup(player.cwUserGroup)
      end

      hook.Run('PlayerRestoreData', player, player.cwData)

      if Callback and IsValid(player) then
        Callback(player)
      end

      -- Stored OnNextPlay payloads are no longer executed: the column is only cleared.
      if onNextPlay != nil and onNextPlay != '' then
        local updateObj = cwDatabase:Update(playersTable)
          updateObj:Update('_OnNextPlay', '')
          updateObj:Where('_SteamID', steamID)
          updateObj:Where('_Schema', schemaFolder)
        updateObj:Execute()

        ErrorNoHalt(
          '[Catwork] Discarded a stored OnNextPlay payload ('..#tostring(onNextPlay)..' bytes) for '
          ..steamID..'.\n'
        )
      end
    end)

  queryObj:Execute()

  timer.Simple(2, function()
    if IsValid(player) and !player.cwData then
      self:LoadData(player, Callback)
    end
  end)
end

--- Saves the player's player data to the database.
--
-- `PlayerSaveData(player, data)` can change a copy of the data before it is
-- saved.
-- @param player [Player The player]
-- @param bCreate=nil [Boolean Insert a new row for the player instead of updating theirs]
-- @return [Map An empty table when `bCreate` is set, otherwise nothing]
function cw.player:SaveData(player, bCreate)
  if !bCreate then
    local schemaFolder = cw.core:GetSchemaFolder()
    local steamName = player:SteamName()
    local ipAddress = player:IPAddress()
    local userGroup = player:GetClockworkUserGroup()
    local steamID = player:SteamID()
    local data = table.Copy(player.cwData)

    hook.Run('PlayerSaveData', player, data)

    local playersTable = config.Get('mysql_players_table'):Get()
    local queryObj = cwDatabase:Update(playersTable)
      queryObj:Where('_Schema', schemaFolder)
      queryObj:Where('_SteamID', steamID)
      queryObj:Update('_LastPlayed', os.time())
      queryObj:Update('_SteamName', steamName)
      queryObj:Update('_IPAddress', ipAddress)
      queryObj:Update('_UserGroup', userGroup)
      queryObj:Update('_SteamID', steamID)
      queryObj:Update('_Schema', schemaFolder)
      queryObj:Update('_Data', util.TableToJSON(data))
    queryObj:Execute()
  else
    local playersTable = config.Get('mysql_players_table'):Get()
    local queryObj = cwDatabase:Insert(playersTable)
      queryObj:Insert('_Data', '')
      queryObj:Insert('_Schema', cw.core:GetSchemaFolder())
      queryObj:Insert('_SteamID', player:SteamID())
      queryObj:Insert('_Donations', '')
      queryObj:Insert('_UserGroup', 'user')
      queryObj:Insert('_IPAddress', player:IPAddress())
      queryObj:Insert('_SteamName', player:SteamName())
      queryObj:Insert('_OnNextPlay', '')
      queryObj:Insert('_LastPlayed', os.time())
      queryObj:Insert('_TimeJoined', os.time())
    queryObj:Execute()

    return {}
  end
end

--- Stores the player's current inventory, ammo and data in their character table.
-- @param player [Player The player]
function cw.player:UpdateCharacter(player)
  player.cwCharacter.inventory = self:GetCharacterInventoryString(player, player.cwCharacter, true)
  player.cwCharacter.ammo = self:GetCharacterAmmoString(player, player.cwCharacter, true)
  player.cwCharacter.data = self:GetCharacterDataString(player, player.cwCharacter, true)
end

--- Saves a character to the database.
--
-- Without `bCreate`, the character's row is updated (only for players who
-- have initialized) and the player data is saved too. With `bCreate`, every
-- field of the character is inserted as a new row.
-- @param player [Player The player]
-- @param bCreate=nil [Boolean Insert the character as a new row]
-- @param character=nil [Character The character to save; defaults to the current one]
-- @param Callback=nil [Function With `bCreate`, called as `Callback(key)` with the new row's key]
function cw.player:SaveCharacter(player, bCreate, character, Callback)
  if bCreate then
    local charactersTable = config.Get('mysql_characters_table'):Get()

    if !character or type(character) != 'table' then
      character = player:GetCharacter()
    end

    local queryObj = cwDatabase:Insert(charactersTable)

      for k, v in pairs(character) do
        local tableKey = '_'..cw.core:SetCamelCase(k, false)

        if k == 'recognisedNames' then
          queryObj:Insert(tableKey, util.TableToJSON(character.recognisedNames))
        elseif k == 'attributes' then
          queryObj:Insert(tableKey, util.TableToJSON(character.attributes))
        elseif k == 'traits' then
          queryObj:Insert(tableKey, util.TableToJSON(character.traits))
        elseif k == 'inventory' then
          queryObj:Insert(tableKey, util.TableToJSON(cw.inventory:ToSaveable(character.inventory)))
        elseif k == 'ammo' then
          queryObj:Insert(tableKey, util.TableToJSON(character.ammo))
        elseif k == 'data' then
          queryObj:Insert(tableKey, util.TableToJSON(v))
        else
          queryObj:Insert(tableKey, v)
        end
      end

      queryObj:Callback(function(result, status, lastID)
        if Callback then
          Callback(tonumber(lastID))
        end
      end)

    queryObj:Execute()
  elseif player:HasInitialized() then
    local currentCharacter = player:GetCharacter()
    local charactersTable = config.Get('mysql_characters_table'):Get()
    local schemaFolder = cw.core:GetSchemaFolder()
    local unixTime = os.time()
    local steamID = player:SteamID()

    if !character then
      character = currentCharacter
    end

    if !character then return end

    local queryObj = cwDatabase:Update(charactersTable)
      queryObj:Where('_Schema', schemaFolder)
      queryObj:Where('_SteamID', steamID)
      queryObj:Where('_CharacterID', character.characterID)
      queryObj:Update('_RecognisedNames', self:GetCharacterRecognisedNamesString(player, character))
      queryObj:Update('_Attributes', util.TableToJSON(character.attributes))
      queryObj:Update('_Traits', util.TableToJSON(character.traits))
      queryObj:Update('_LastPlayed', unixTime)
      queryObj:Update('_SteamName', player:SteamName())
      queryObj:Update('_Faction', character.faction)
      queryObj:Update('_Gender', character.gender)
      queryObj:Update('_Schema', character.schema)
      queryObj:Update('_Model', character.model)
      queryObj:Update('_Flags', character.flags)
      queryObj:Update('_Cash', character.cash)
      queryObj:Update('_Name', character.name)

      if currentCharacter == character then
        queryObj:Update('_Inventory', self:GetCharacterInventoryString(player, character))
        queryObj:Update('_Ammo', self:GetCharacterAmmoString(player, character))
        queryObj:Update('_Data', self:GetCharacterDataString(player, character))
      else
        queryObj:Update('_Inventory', util.TableToJSON(cw.inventory:ToSaveable(character.inventory)))
        queryObj:Update('_Ammo', util.TableToJSON(character.ammo))
        queryObj:Update('_Data', util.TableToJSON(character.data))
      end

    queryObj:Execute()

    --[[ Save the player's data after pushing the update. --]]
    self:SaveData(player)
  end
end

--- Returns the class of the player's active weapon.
-- @param player [Player The player]
-- @param safe=nil [Any Value to return if the player has no active weapon]
-- @return [String The weapon class, or `safe`]
function cw.player:GetWeaponClass(player, safe)
  if IsValid(player:GetActiveWeapon()) then
    return player:GetActiveWeapon():GetClass()
  else
    return safe
  end
end

--- Returns the player's wages from the `Wages` net var.
-- @param player [Player The player]
-- @return [Number The wages]
function cw.player:GetWages(player)
  return player:GetNetVar('Wages')
end

--- Replaces all flags of the player's current character.
-- @param player [Player The player]
-- @param flags [String The new flags, one character each]
function cw.player:SetFlags(player, flags)
  self:TakeFlags(player, player:GetFlags())
  self:GiveFlags(player, flags)
end

--- Replaces all of the player's player-wide flags.
-- @param player [Player The player]
-- @param flags [String The new flags, one character each]
function cw.player:SetPlayerFlags(player, flags)
  self:TakePlayerFlags(player, player:GetPlayerFlags())
  self:GivePlayerFlags(player, flags)
end

--- Sets the rank of the player's character within their faction.
--
-- Also applies the rank's `class`, `model` and `weapons` (given as spawn
-- weapons). Does nothing if the faction has no rank by that name.
-- @param player [Player The player]
-- @param rank [String Name of the rank]
function cw.player:SetFactionRank(player, rank)
  if rank then
    local faction = faction.FindByID(player:GetFaction())

    if faction and istable(faction.ranks) then
      for k, v in pairs(faction.ranks) do
        if k == rank then
          player:SetCharacterData('factionrank', k)

          if v.class and cw.class:GetAll()[v.class] then
            cw.class:Set(player, v.class)
          end

          if v.model then
            player:SetModel(v.model)
          end

          if istable(v.weapons) then
            for k, v in pairs(v.weapons) do
              self:GiveSpawnWeapon(player, v)
            end
          end

          break
        end
      end
    end
  end
end

--- Returns the player's player-wide flags.
-- @param player [Player The player]
-- @return [String The flags, or `''`]
function cw.player:GetPlayerFlags(player)
  return player:GetData('Flags') or ''
end

local playerMeta = FindMetaTable('Player')

--- Gives cash to the player's character, or takes it with a negative amount.
--
-- Same as `cw.player:GiveCash`.
-- @param amount [Number Cash to give; negative takes it]
-- @param reason=nil [String Shown in the hint after the amount]
-- @param bNoMsg=nil [Boolean Do not show a hint]
function playerMeta:GiveCash(amount, reason, bNoMsg)
  return cw.player:GiveCash(self, amount, reason, bNoMsg)
end

--- Notifies the player in chat or with a notification popup.
--
-- Same as `cw.player:Notify`.
-- @param text [String The text]
-- @param class=nil [Any `true` or `nil` for chat, or a `NOTIFY_*` number for a popup]
-- @param icon=nil [String Path of the chat icon]
function playerMeta:Notify(text, class, icon)
  return cw.player:Notify(self, text, class, icon)
end
