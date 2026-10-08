--- Client-side part of the `cw.player` library: queries about the local player, and about other players as the client
-- knows them.
--
-- It covers carrying capacity, worn clothes and accessories, flags, recognition and displayed names, line of sight,
-- ragdoll and action state, cash, wages and chat icons. Many functions mirror the server ones of the same name in
-- `sv_player.lua`.

if !cw.player then
  include('sh_player.lua')
end

--- Returns whether the local player's inventory can take some more weight.
-- @param weight [Number Weight to add]
-- @return [Boolean Whether the total stays within `cw.player:GetMaxWeight`]
-- @see cw.player:CanHoldSpace
function cw.player:CanHoldWeight(weight)
  local inventoryWeight = cw.inventory:CalculateWeight(
    cw.inventory:GetClient()
  )

  if inventoryWeight + weight > self:GetMaxWeight() then
    return false
  else
    return true
  end
end

--- Returns whether the local player's inventory can take some more space.
-- @param space [Number Space to add]
-- @return [Boolean Whether the total stays within `cw.player:GetMaxSpace`]
-- @see cw.player:CanHoldWeight
function cw.player:CanHoldSpace(space)
  local inventorySpace = cw.inventory:CalculateSpace(
    cw.inventory:GetClient()
  )

  if inventorySpace + space > self:GetMaxSpace() then
    return false
  else
    return true
  end
end

--- Returns the maximum weight the local player can carry.
--
-- Starts from the `InvWeight` network variable, or the `default_inv_weight` config,
-- and adds the `addInvSpace` of every item in the inventory.
-- @return [Number Maximum inventory weight]
function cw.player:GetMaxWeight()
  local itemsList = cw.inventory:GetAsItemsList(
    cw.inventory:GetClient()
  )

  local weight = cw.client:GetNetVar('InvWeight') or config.GetVal('default_inv_weight')

  for k, v in pairs(itemsList) do
    local addInvWeight = v.addInvSpace

    if addInvWeight then
      weight = weight + addInvWeight
    end
  end

  return weight
end

--- Returns the maximum space the local player can carry.
--
-- Starts from the `InvSpace` network variable, or the `default_inv_space` config,
-- and adds the `addInvVolume` of every item in the inventory.
-- @return [Number Maximum inventory space]
function cw.player:GetMaxSpace()
  local itemsList = cw.inventory:GetAsItemsList(
    cw.inventory:GetClient()
  )
  local space = cw.client:GetNetVar('InvSpace') or config.GetVal('default_inv_space')

  for k, v in pairs(itemsList) do
    local addInvSpace = v.addInvVolume

    if addInvSpace then
      space = space + addInvSpace
    end
  end

  return space
end

--- Returns the local player's clothes data as sent by the server.
-- @return [Map The clothes item's `uniqueID` and `itemID`, both `nil` when no clothes are worn]
function cw.player:GetClothesData()
  return cw.ClothesData
end

--- Returns the accessories the local player is wearing.
-- @return [Map<String> Item unique IDs keyed by item ID]
function cw.player:GetAccessoryData()
  return cw.AccessoryData
end

--- Returns the clothes item the local player is wearing.
-- @return [Item The clothes item from the inventory, or `nil` if none is worn]
function cw.player:GetClothesItem()
  local clothesData = self:GetClothesData()

  if clothesData.itemID != nil and clothesData.uniqueID != nil then
    return cw.inventory:FindItemByID(
      cw.inventory:GetClient(),
      clothesData.uniqueID, clothesData.itemID
    )
  end
end

--- Returns whether the local player is wearing a clothes item.
-- @return [Boolean Whether clothes are worn]
function cw.player:IsWearingClothes()
  return (self:GetClothesItem() != nil)
end

--- Returns whether the local player is wearing an accessory of an item type.
-- @param uniqueID [String Unique ID of the item type, compared case-insensitively]
-- @return [Boolean Whether such an accessory is worn]
function cw.player:HasAccessory(uniqueID)
  local accessoryData = self:GetAccessoryData()

  for k, v in pairs(accessoryData) do
    if string.lower(v) == string.lower(uniqueID) then
      return true
    end
  end

  return false
end

--- Returns whether the local player is wearing a specific accessory item.
-- @param itemTable [Item The item instance]
-- @return [Boolean Whether the item is worn]
function cw.player:IsWearingAccessory(itemTable)
  local accessoryData = self:GetAccessoryData()
  local itemID = itemTable.itemID

  if accessoryData[itemID] then
    return true
  else
    return false
  end
end

--- Returns whether an item is the clothes item the local player is wearing.
-- @param itemTable [Item The item instance]
-- @return [Boolean Whether the item is worn, or `nil` if no clothes are worn]
function cw.player:IsWearingItem(itemTable)
  local clothesItem = self:GetClothesItem()
  return (clothesItem and clothesItem:IsTheSameAs(itemTable))
end

--- Returns whether a player is noclipping outside a vehicle.
-- @param player [Player The player]
-- @return [Boolean `true` if they are noclipping, `nil` otherwise]
function cw.player:IsNoClipping(player)
  if player:GetMoveType() == MOVETYPE_NOCLIP
  and !player:InVehicle() then
    return true
  end
end

--- Returns whether a player has the operator flag (`o`).
-- @param player [Player The player]
-- @return [Boolean `true` if they have it, `nil` otherwise]
-- @see cw.player:HasFlags
function cw.player:IsAdmin(player)
  if self:HasFlags(player, 'o') then
    return true
  end
end

--- Returns whether the server has finished sending the local player's data.
-- @return [Boolean Whether the data has streamed]
function cw.player:HasDataStreamed()
  return cw.DataHasStreamed
end

--- Returns whether a player can hear another player.
--
-- Always `true` unless the `messages_must_see_player` config is on, in which case
-- `cw.player:CanSeePlayer` decides, ignoring every entity in the way.
-- @param player [Player The listener]
-- @param target [Player The speaker]
-- @param allowance=0.5 [Number Fraction of the line of sight that must be clear]
-- @return [Boolean Whether `player` can hear `target`]
function cw.player:CanHearPlayer(player, target, allowance)
  if config.GetVal('messages_must_see_player') then
    return self:CanSeePlayer(player, target, (allowance or 0.5), true)
  else
    return true
  end
end

--- Returns whether the player the local player is looking at recognises them.
--
-- Always `true` when the `recognise_system` config is off.
-- @return [Boolean Whether the target recognises the local player, from the `TargetKnows` network variable]
function cw.player:DoesTargetRecognise()
  if config.GetVal('recognise_system') then
    return cw.client:GetNetVar('TargetKnows')
  else
    return true
  end
end

--- Returns a trace along a player's aim that can hit players and NPCs by their hitboxes.
--
-- Traces 4096 units from the player's eyes. A second trace with a hitbox mask is
-- used when it hits an entity the plain trace missed, or the plain trace hit a vehicle.
-- @param player [Player The player whose aim to trace]
-- @param useFilterTrace=nil [Boolean Whether to always use the hitbox trace]
-- @return [Map The `TraceResult`, or `nil` if the player is not valid]
function cw.player:GetRealTrace(player, useFilterTrace)
  if !IsValid(player) then
    return
  end

  local angles = player:GetAimVector() * 4096
  local eyePos = EyePos()

  if player != cw.client then
    eyePos = player:EyePos()
  end

  local trace = util.TraceLine({
    endpos = eyePos + angles,
    start = eyePos,
    filter = player
  })

  local newTrace = util.TraceLine({
    endpos = eyePos + angles,
    filter = player,
    start = eyePos,
    mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER
  })

  if (IsValid(newTrace.Entity) and !newTrace.HitWorld and (!IsValid(trace.Entity)
  or string.find(trace.Entity:GetClass(), 'vehicle'))) or useFilterTrace then
    trace = newTrace
  end

  return trace
end

--- Returns a player's current action.
-- @variant GetAction(player)
-- Returns the action with its duration and start time.
--   @param player [Player The player]
--   @return [String The action, or `''` if there is none, Number Its duration in seconds, Number The `CurTime` it
--   started at]
-- @variant GetAction(player, percentage)
-- Returns the action with how far it has progressed.
--   @param player [Player The player]
--   @param percentage [Boolean `true`]
--   @return [String The action, or `''` if there is none, Number Progress from `0` to `100`]
function cw.player:GetAction(player, percentage)
  local startActionTime = player:GetNetVar('StartActTime') or 0
  local actionDuration = player:GetNetVar('ActDuration') or 0
  local curTime = CurTime()
  local action = player:GetNetVar('ActName') or 'Unknown'

  if curTime < startActionTime + actionDuration then
    if percentage then
      return action, (100 / actionDuration) * (actionDuration - ((startActionTime + actionDuration) - curTime))
    else
      return action, actionDuration, startActionTime
    end
  else
    return '', 0, 0
  end
end

--- Returns how many characters the local player may have.
--
-- The `additional_characters` config plus one for every faction that is not
-- whitelisted or that the player is whitelisted for.
-- @return [Number Maximum number of characters]
function cw.player:GetMaximumCharacters()
  local whitelisted = cw.character:GetWhitelisted()
  local maximum = config.Get('additional_characters'):Get(2)

  for k, v in pairs(faction.GetStored()) do
    if !v.whitelist or table.HasValue(whitelisted, v.name) then
      maximum = maximum + 1
    end
  end

  return maximum
end

--- Returns whether a player's weapon is raised.
-- @param player [Player The player]
-- @return [Boolean Whether the weapon is raised, from `Player:IsWeaponRaised`]
function cw.player:GetWeaponRaised(player)
  return player:IsWeaponRaised()
end

--- Returns the name shown for a player the local player does not recognise.
-- @param player [Player The player]
-- @return [String The player's physical description, or the `unrecognised_name` config if there is none,
-- Boolean `true` if the physical description was used]
function cw.player:GetUnrecognisedName(player)
  local unrecognisedPhysDesc = self:GetPhysDesc(player)
  local unrecognisedName = config.Get('unrecognised_name'):Get()
  local usedPhysDesc

  if unrecognisedPhysDesc then
    unrecognisedName = unrecognisedPhysDesc
    usedPhysDesc = true
  end

  return unrecognisedName, usedPhysDesc
end

--- Returns a player's name as the local player knows it.
-- @param target [Player The player]
-- @return [String Their character name if the local player recognises them, otherwise
-- `cw.player:GetUnrecognisedName`]
function cw.player:GetName(target)
  if self:DoesRecognise(target) then
    return target:Name()
  else
    return self:GetUnrecognisedName(target)
  end
end

--- Returns whether a player can see an NPC.
--
-- `true` straight away if the player is looking at it; otherwise traces between
-- their shoot positions.
-- @param player [Player The player looking]
-- @param target [NPC The NPC]
-- @param allowance=0.75 [Number Fraction of the trace that must be clear]
-- @param ignoreEnts=nil [List<Entity> Entities the trace ignores; any other true value ignores every entity]
-- @return [Boolean `true` if the NPC can be seen, `nil` otherwise]
function cw.player:CanSeeNPC(player, target, allowance, ignoreEnts)
  if player:GetEyeTraceNoCursor().Entity == target then
    return true
  else
    local trace = {}

    trace.mask =
      CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER
    trace.start = player:GetShootPos()
    trace.endpos = target:GetShootPos()
    trace.filter = { player, target }

    if ignoreEnts then
      if type(ignoreEnts) == 'table' then
        table.Add(trace.filter, ignoreEnts)
      else
        table.Add(trace.filter, ents.GetAll())
      end
    end

    trace = util.TraceLine(trace)

    if trace.Fraction >= (allowance or 0.75) then
      return true
    end
  end
end

--- Returns whether two players can see each other.
--
-- `true` straight away if either is looking at the other; otherwise traces between
-- their shoot positions.
-- @param player [Player The player looking]
-- @param target [Player The other player]
-- @param allowance=0.75 [Number Fraction of the trace that must be clear]
-- @param ignoreEnts=nil [List<Entity> Entities the trace ignores; any other true value ignores every entity]
-- @return [Boolean `true` if the player can be seen, `nil` otherwise]
function cw.player:CanSeePlayer(player, target, allowance, ignoreEnts)
  if player:GetEyeTraceNoCursor().Entity == target then
    return true
  elseif target:GetEyeTraceNoCursor().Entity == player then
    return true
  else
    local trace = {}

    trace.mask =
      CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER
    trace.start = player:GetShootPos()
    trace.endpos = target:GetShootPos()
    trace.filter = { player, target }

    if ignoreEnts then
      if type(ignoreEnts) == 'table' then
        table.Add(trace.filter, ignoreEnts)
      else
        table.Add(trace.filter, ents.GetAll())
      end
    end

    trace = util.TraceLine(trace)

    if trace.Fraction >= (allowance or 0.75) then
      return true
    end
  end
end

--- Returns whether a player can see an entity.
--
-- `true` straight away if the player is looking at it; otherwise traces from their
-- shoot position to the entity's center.
-- @param player [Player The player looking]
-- @param target [Entity The entity]
-- @param allowance=0.75 [Number Fraction of the trace that must be clear]
-- @param ignoreEnts=nil [List<Entity> Entities the trace ignores; any other true value ignores every entity]
-- @return [Boolean `true` if the entity can be seen, `nil` otherwise]
function cw.player:CanSeeEntity(player, target, allowance, ignoreEnts)
  if player:GetEyeTraceNoCursor().Entity == target then
    return true
  else
    local trace = {}

    trace.mask =
      CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER
    trace.start = player:GetShootPos()
    trace.endpos = target:LocalToWorld(target:OBBCenter())
    trace.filter = { player, target }

    if ignoreEnts then
      if type(ignoreEnts) == 'table' then
        table.Add(trace.filter, ignoreEnts)
      else
        table.Add(trace.filter, ents.GetAll())
      end
    end

    trace = util.TraceLine(trace)

    if trace.Fraction >= (allowance or 0.75) then
      return true
    end
  end
end

--- Returns whether a player has a clear line of sight to a position.
-- @param player [Player The player looking]
-- @param position [Vector The position]
-- @param allowance=0.75 [Number Fraction of the trace that must be clear]
-- @param ignoreEnts=nil [List<Entity> Entities the trace ignores; any other true value ignores every entity]
-- @return [Boolean `true` if the position can be seen, `nil` otherwise]
function cw.player:CanSeePosition(player, position, allowance, ignoreEnts)
  local trace = {}

  trace.mask =
    CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER
  trace.start = player:GetShootPos()
  trace.endpos = position
  trace.filter = player

  if ignoreEnts then
    if type(ignoreEnts) == 'table' then
      table.Add(trace.filter, ignoreEnts)
    else
      table.Add(trace.filter, ents.GetAll())
    end
  end

  trace = util.TraceLine(trace)

  if trace.Fraction >= (allowance or 0.75) then
    return true
  end
end

--- Returns what wages are called for a player's class.
-- @param player [Player The player]
-- @return [String The class's `wagesName`, or the `wages_name` config]
function cw.player:GetWagesName(player)
  return cw.class:Query(player:Team(), 'wagesName', config.Get('wages_name'):Get())
end

--- Returns whether a player is ragdolled.
-- @param player [Player The player]
-- @param exception=nil [Number A `RAGDOLL_*` state that does not count as ragdolled]
-- @param entityless=nil [Boolean Whether to check the state even when the player has no ragdoll entity]
-- @return [Boolean Whether the player is ragdolled, or `nil` if they have no ragdoll entity and
-- `entityless` is not set]
function cw.player:IsRagdolled(player, exception, entityless)
  if player:GetRagdollEntity() or entityless then
    if player:GetDTInt(INT_RAGDOLLSTATE) == 0 then
      return false
    elseif player:GetDTInt(INT_RAGDOLLSTATE) == exception then
      return false
    else
      return (player:GetDTInt(INT_RAGDOLLSTATE) != RAGDOLL_NONE)
    end
  end
end

--- Returns whether the local player recognises another player.
--
-- Always `true` when the `recognise_system` config is off, and for the local
-- player's own character. The `PlayerDoesRecognisePlayer` hook receives the
-- computed value and returns the result.
-- @param player [Player The player to check]
-- @param status=RECOGNISE_PARTIAL [Number Lowest `RECOGNISE_*` level that counts]
-- @param isAccurate=nil [Boolean Whether the level must equal `status` instead of reaching it]
-- @return [Boolean Whether the player is recognised]
function cw.player:DoesRecognise(player, status, isAccurate)
  if !status then
    return self:DoesRecognise(player, RECOGNISE_PARTIAL)
  elseif config.Get('recognise_system'):Get() then
    local key = self:GetCharacterKey(player)
    local realValue = false

    if self:GetCharacterKey(cw.client) == key then
      return true
    elseif cw.RecognisedNames[key] then
      if isAccurate then
        realValue = (cw.RecognisedNames[key] == status)
      else
        realValue = (cw.RecognisedNames[key] >= status)
      end
    end

    return hook.Run('PlayerDoesRecognisePlayer', player, status, isAccurate, realValue)
  else
    return true
  end
end

--- Returns the key of a player's character, used to identify it in recognition data.
-- @param player [Player The player]
-- @return [Number The `Key` network variable, or `nil` if the player is not valid]
function cw.player:GetCharacterKey(player)
  if IsValid(player) then
    return player:GetNetVar('Key')
  end
end

--- Returns a player's ragdoll state.
-- @param player [Player The player]
-- @return [Number The `RAGDOLL_*` state, or `false` if it is unset]
function cw.player:GetRagdollState(player)
  if player:GetDTInt(INT_RAGDOLLSTATE) == 0 then
    return false
  else
    return player:GetDTInt(INT_RAGDOLLSTATE)
  end
end

--- Returns a player's physical description.
--
-- Falls back to the class's `defaultPhysDesc`, then the `default_physdesc` config,
-- then the `#PhysDesc_MatchesModel` phrase. The `GetPlayerPhysDescOverride` hook
-- can return a replacement.
-- @param player=cw.client [Player The player]
-- @return [String The physical description]
function cw.player:GetPhysDesc(player)
  if !player then
    player = cw.client
  end

  local physDesc = player:GetDTString(STRING_PHYSDESC)
  local team = player:Team()

  if physDesc == '' then
    physDesc = cw.class:Query(team, 'defaultPhysDesc', '')
  end

  if physDesc == '' then
    physDesc = config.Get('default_physdesc'):Get()
  end

  if !physDesc or physDesc == '' then
    physDesc = L('#PhysDesc_MatchesModel')
  else
    physDesc = cw.core:ModifyPhysDesc(physDesc)
  end

  local override = hook.Run('GetPlayerPhysDescOverride', player, physDesc)

  if override then
    physDesc = override
  end

  return physDesc
end

--- Returns the local player's wages.
-- @return [Number The `Wages` network variable]
function cw.player:GetWages()
  return cw.client:GetNetVar('Wages')
end

--- Returns the local player's cash.
-- @return [Number The `Cash` network variable, or `0`]
function cw.player:GetCash()
  return cw.client:GetNetVar('Cash') or 0
end

--- Returns a player's ragdoll entity.
-- @param player [Player The player]
-- @return [Entity The ragdoll, or `nil` if the player is not ragdolled]
function cw.player:GetRagdollEntity(player)
  local ragdollEntity = player:GetDTEntity(2)

  if IsValid(ragdollEntity) then
    return ragdollEntity
  end
end

--- Returns the skin of the model a player's class gives them.
-- @param player [Player The player]
-- @return [Number The skin, from `cw.class:GetAppropriateModel`]
function cw.player:GetDefaultSkin(player)
  local model, skin = cw.class:GetAppropriateModel(player:Team(), player)

  return skin
end

--- Returns the model a player's class gives them.
-- @param player [Player The player]
-- @return [String The model path, from `cw.class:GetAppropriateModel`]
function cw.player:GetDefaultModel(player)
  local model, skin = cw.class:GetAppropriateModel(player:Team(), player)
  return model
end

--- Returns whether a player has at least one of some flags.
--
-- The flags of the player's class count, and the `PlayerDoesHaveFlag` hook can
-- grant or deny a flag. `s`, `a` and `o` are also granted by the superadmin,
-- admin and operator user groups.
-- @param player [Player The player]
-- @param flags [String The flags, such as `'pet'`]
-- @param bByDefault=nil [Boolean Whether to ignore the class flags and the hook]
-- @return [Boolean `true` if the player has one of the flags, `nil` otherwise or if they have no flags]
-- @see cw.player:HasFlags
function cw.player:HasAnyFlags(player, flags, bByDefault)
  local playerFlags = player:GetDTString(STRING_FLAGS)

  if playerFlags != nil and playerFlags != '' then
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
        elseif string.find(playerFlags, flag) then
          return true
        end
      end
    end
  end
end

--- Returns whether a player has some flags.
--
-- Without `bIsStrict` any one of the flags is enough; with it every flag is needed.
-- The flags of the player's class count, and the `PlayerDoesHaveFlag` hook can
-- grant or deny a flag. `s`, `a` and `o` are also granted by the superadmin,
-- admin and operator user groups.
--
-- ```
-- if cw.player:HasFlags(cw.client, cmdTable.access) then
--   -- show the command
-- end
-- ```
--
-- @param player [Player The player]
-- @param flags [String The flags, such as `'pet'`]
-- @param bByDefault=nil [Boolean Whether to ignore the class flags and the hook]
-- @param bIsStrict=nil [Boolean Whether every flag is needed]
-- @return [Boolean Whether the player has the flags; `nil` if they have no flags at all]
-- @see cw.player:HasAnyFlags
function cw.player:HasFlags(player, flags, bByDefault, bIsStrict)
  local playerFlags = player:GetDTString(STRING_FLAGS)

  if playerFlags != nil and playerFlags != '' then
    if cw.class:HasFlags(player:Team(), flags) and !bByDefault then
      return true
    end

    if !bIsStrict then
      for k, v in ipairs(string.Explode('', flags)) do
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

        if string.find(playerFlags, v) then
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
        elseif !string.find(playerFlags, flag) then
          return false
        end
      end
    end

    return true
  end
end

--- Returns how drunk the local player is.
-- @return [Number The `IsDrunk` network variable, or `nil` if the player is sober]
function cw.player:GetDrunk()
  local isDrunk = LocalPlayer():GetNetVar('IsDrunk') or 0

  if isDrunk and isDrunk > 0 then
    return isDrunk
  end
end

--- Returns the icon shown next to a player's name in the chat box.
--
-- Uses the icons registered with `cw.icon:Add`, preferring player icons. Without
-- one, whitelisted factions get `icon16/add.png` and everyone else `icon16/user.png`.
-- @param player [Player The player]
-- @return [String Path of the icon material; `icon16/user_delete.png` if the player is not valid]
function cw.player:GetChatIcon(player)
  local icon

  if !IsValid(player) then
    return 'icon16/user_delete.png'
  end

  for k, v in pairs(cw.icon:GetAll()) do
    if v.callback(player) then
      if !icon then
        icon = v.path
      end

      if v.isPlayer then
        icon = v.path
        break
      end
    end
  end

  if !icon then
    local faction = player:GetFaction()

    icon = 'icon16/user.png'

    if faction and _faction.GetStored()[faction] then
      if _faction.GetStored()[faction].whitelist then
        icon = 'icon16/add.png'
      end
    end
  end

  return icon
end
