--- Server-side hooks of the HL2RP schema, the `Schema` implementations of Catwork and gamemode hooks that enforce the
-- setting's rules.
--
-- They handle Combine units (names and ranks, radio and display lines, biosignal loss on death), player scanners, tied
-- players, entity menu options for corpses, breaches and stationary radios, the server whitelist, permanent kill and
-- item loss on death, door damage and damage scaling, and Combine death, pain and footstep sounds. Loading and saving
-- is delegated to the functions of `sv_schema.lua` from `ClockworkInitPostEntity` and `PostSaveData`.

--- Called when a player first spawns; exchanges custom scoreboard icons with them two seconds later.
-- @param player [Player The player]
-- @param bOneWay [Boolean Unused]
function Schema:PlayerInitialSpawn(player, bOneWay)
  timer.Simple(2, function()
    if IsValid(player) then
      self:SendIconData(player)
    end
  end)
end

--- Called when Catwork has loaded all of the entities.
--
-- Loads the saved ration dispensers, vending machines, Combine objectives, radios and named NPCs.
function Schema:ClockworkInitPostEntity()
  self:LoadRationDispensers()
  self:LoadVendingMachines()
  self:LoadObjectives()
  self:LoadRadios()
  self:LoadNPCs()
end

--- Called when data should be saved; the schema saves its entities in `Schema:PostSaveData` instead.
function Schema:SaveData() end

--- Called just after data has been saved.
--
-- Saves the ration dispensers, vending machines, radios and named NPCs of the current map.
function Schema:PostSaveData()
  self:SaveRationDispensers()
  self:SaveVendingMachines()
  self:SaveRadios()
  self:SaveNPCs()
end

--- Called when a player's default model is needed; overridden to do nothing so the faction model is used.
-- @param player [Player The player]
function Schema:GetPlayerDefaultModel(player)
end

--- Called when a player chooses an option from an entity's menu.
--
-- Opens corpse loot and belongings storage, charges breaches and handles the stationary radio options:
-- setting a frequency in the `1X1.X` format, toggling it and picking it up as an item. Empty
-- belongings are removed when closed.
-- @param player [Player The player who chose the option]
-- @param entity [Entity The entity]
-- @param option [String The option's name]
-- @param arguments [Any The option's menu string, such as `'cw_radioToggle'`, or the typed frequency]
function Schema:EntityHandleMenuOption(player, entity, option, arguments)
  if entity:GetClass() == 'prop_ragdoll' and arguments == 'cw_corpseLoot' then
    if !entity.cwInventory then entity.cwInventory = {} end
    if !entity.cash then entity.cash = 0 end

    local entityPlayer = cw.entity:GetPlayer(entity)

    if !entityPlayer or !entityPlayer:Alive() then
      player:EmitSound('physics/body/body_medium_impact_soft'..math.random(1, 7)..'.wav')

      cw.storage:Open(player, {
        name = '#Storage_Corpse',
        weight = 8,
        entity = entity,
        distance = 192,
        cash = entity.cash,
        inventory = entity.cwInventory,
        OnGiveCash = function(player, storageTable, cash)
          entity.cash = storageTable.cash
        end,
        OnTakeCash = function(player, storageTable, cash)
          entity.cash = storageTable.cash
        end
      })
    end
  elseif entity:GetClass() == 'cw_belongings' and arguments == 'cw_belongingsOpen' then
    player:EmitSound('physics/body/body_medium_impact_soft'..math.random(1, 7)..'.wav')

    cw.storage:Open(player, {
      name = '#Storage_Belongings',
      weight = 100,
      entity = entity,
      distance = 192,
      cash = entity.cash,
      inventory = entity.cwInventory,
      OnGiveCash = function(player, storageTable, cash)
        entity.cash = storageTable.cash
      end,
      OnTakeCash = function(player, storageTable, cash)
        entity.cash = storageTable.cash
      end,
      OnClose = function(player, storageTable, entity)
        if IsValid(entity) then
          if (!entity.cwInventory and !entity.cash) or (table.Count(entity.cwInventory) == 0 and entity.cash == 0) then
            entity:Explode(entity:BoundingRadius() * 2)
            entity:Remove()
          end
        end
      end,
      CanGiveItem = function(player, storageTable, itemTable)
        return false
      end
    })
  elseif entity:GetClass() == 'cw_breach' then
    entity:CreateDummyBreach()
    entity:BreachEntity(player)
  elseif entity:GetClass() == 'cw_radio' then
    if option == 'Set Frequency' and type(arguments) == 'string' then
      if string.find(arguments, '^%d%d%d%.%d$') then
        local start, finish, decimal = string.match(arguments, '(%d)%d(%d)%.(%d)')

        start = tonumber(start)
        finish = tonumber(finish)
        decimal = tonumber(decimal)

        if start == 1 and finish > 0 and finish < 10 and decimal > 0 and decimal < 10 then
          entity:SetFrequency(arguments)

          cw.player:Notify(player, L('Radio_FrequencySetStationary', arguments))
        else
          cw.player:Notify(player, L('Radio_FrequencyRange'))
        end
      else
        cw.player:Notify(player, L('Radio_FrequencyFormat'))
      end
    elseif arguments == 'cw_radioToggle' then
      entity:Toggle()
    elseif arguments == 'cw_radioTake' then
      local bSuccess, fault = player:GiveItem(item.CreateInstance('stationary_radio'))

      if !bSuccess then
        cw.player:Notify(player, fault)
      else
        entity:Remove()
      end
    end
  end
end

--- Called when an NPC is killed.
--
-- When the NPC is a player's scanner, the player dies with it and the scanner is reset.
-- @param npc [NPC The NPC]
-- @param attacker [Entity The attacker]
-- @param inflictor [Entity The inflictor]
function Schema:OnNPCKilled(npc, attacker, inflictor)
  for k, v in pairs(self.scanners) do
    local scanner = v[1]
    local player = k

    if IsValid(player) and IsValid(scanner) and scanner == npc then
      cw.core:CalculateSpawnTime(player, inflictor, attacker)

      npc:EmitSound('npc/scanner/scanner_explode_crash2.wav')

      self:PlayerDeath(player, inflictor, attacker, true)
      self:ResetPlayerScanner(player)
    end
  end
end

--- Called when a player's visibility is set up; adds a scanner player's scanner to their PVS.
-- @param player [Player The player]
function Schema:SetupPlayerVisibility(player)
  if self.scanners[player] then
    local scanner = self.scanners[player][1]

    if IsValid(scanner) then
      AddOriginToPVS(scanner:GetPos())
    end
  end
end

--- Called when the info of a weapon a player drops should be adjusted.
--
-- Drops the active weapon from the player's eyes and holstered weapons from where their gear model is.
-- @param player [Player The player]
-- @param info [Map The drop info: `itemTable`, and `position` and `angles`, which are set in place]
function Schema:PlayerAdjustDropWeaponInfo(player, info)
  if cw.player:GetWeaponClass(player) == info.itemTable:GetWeaponClass() then
    info.position = player:GetShootPos()
    info.angles = player:GetAimVector():Angle()
  else
    local gearTable = {
      cw.player:GetGear(player, 'Throwable'),
      cw.player:GetGear(player, 'Secondary'),
      cw.player:GetGear(player, 'Primary'),
      cw.player:GetGear(player, 'Melee')
    }

    for k, v in pairs(gearTable) do
      if IsValid(v) then
        local gearItemTable = v:GetItemTable()

        if gearItemTable and gearItemTable:GetWeaponClass() == info.itemTable:GetWeaponClass() then
          local position, angles = v:GetRealPosition()

          if position and angles then
            info.position = position
            info.angles = angles

            break
          end
        end
      end
    end
  end
end

--- Called when a player uses a door.
--
-- On `rp_c18_v1`, closes certain doors automatically ten seconds after they are used.
-- @param player [Player The player]
-- @param door [Entity The door]
function Schema:PlayerUseDoor(player, door)
  if string.lower(game.GetMap()) == 'rp_c18_v1' then
    local name = string.lower(door:GetName())

    if name == 'nxs_brnroom' or name == 'nxs_brnroom2' or name == 'Clockwork_al_door1'
    or name == 'Clockwork_al_door2' or name == 'nxs_brnbcroom' then
      local curTime = CurTime()

      if !door.nextAutoClose or curTime >= door.nextAutoClose then
        door:Fire('close', '', 10)
        door.nextAutoClose = curTime + 10
      end
    end
  end
end

--- Called when a player's inventory contains an item that no longer exists.
--
-- Replaces the old `radio` item with `handheld_radio`.
-- @param player [Player The player]
-- @param inventory [Inventory The inventory being restored]
-- @param item [String The unique ID of the unknown item]
-- @param amount [Number How many of the item there are]
function Schema:PlayerHasUnknownInventoryItem(player, inventory, item, amount)
  if item == 'radio' then
    inventory['handheld_radio'] = amount
  end
end

--- Called when a new character's default inventory is needed.
--
-- Gives administrators a radio, Civil Protection a radio and stunstick, Overwatch a radio, pistol, MP7 and
-- ammunition, and everyone else a suitcase.
-- @param player [Player The player]
-- @param character [Character The new character]
-- @param inventory [Inventory The inventory, filled in place]
function Schema:GetPlayerDefaultInventory(player, character, inventory)
  if character.faction == FACTION_ADMIN then
    cw.inventory:AddInstance(
      inventory, item.CreateInstance('handheld_radio')
    )
  elseif character.faction == FACTION_MPF then
    cw.inventory:AddInstance(
      inventory, item.CreateInstance('handheld_radio')
    )
    cw.inventory:AddInstance(
      inventory, item.CreateInstance('cw_stunstick')
    )
    /*cw.inventory:AddInstance(
      inventory, item.CreateInstance("weapon_pistol")
    )
    for i = 1, 2 do
      cw.inventory:AddInstance(
        inventory, item.CreateInstance("ammo_pistol")
      )
    end*/
  elseif character.faction == FACTION_OTA then
    cw.inventory:AddInstance(
      inventory, item.CreateInstance('handheld_radio')
    )
    cw.inventory:AddInstance(
      inventory, item.CreateInstance('weapon_pistol')
    )
    cw.inventory:AddInstance(
      inventory, item.CreateInstance('ammo_pistol')
    )
    cw.inventory:AddInstance(
      inventory, item.CreateInstance('weapon_mp7a1')
    )
    cw.inventory:AddInstance(
      inventory, item.CreateInstance('ammo_smg1')
    )
  else
    cw.inventory:AddInstance(
      inventory, item.CreateInstance('suitcase')
    )
  end
end

--- Called when a player starts typing; plays the radio-on sound for Combine players typing a message.
-- @param player [Player The player]
-- @param code [String The typing display code, such as `'n'` for normal speech or `'r'` for the radio]
function Schema:PlayerStartTypingDisplay(player, code)
  if player:IsCombine() and !player:IsNoClipping() then
    if code == 'n' or code == 'y' or code == 'w' or code == 'r' then
      if !player.typingBeep then
        player.typingBeep = true

        player:EmitSound('npc/overwatch/radiovoice/on1.wav')
      end
    end
  end
end

--- Called when a player stops typing; plays the radio-off sound for Combine players who sent a message.
-- @param player [Player The player]
-- @param textTyped [Boolean Whether the player sent a message]
function Schema:PlayerFinishTypingDisplay(player, textTyped)
  if player:IsCombine() and textTyped then
    if player.typingBeep then
      player:EmitSound('npc/overwatch/radiovoice/off4.wav')
    end
  end

  player.typingBeep = nil
end

--- Called when a player hits an entity with a stunstick.
--
-- Progresses the player's Strength and punches the view of a hit player. Four hits less than two seconds
-- apart knock the target out for the `knockout_time` config value.
-- @param player [Player The player with the stunstick]
-- @param entity [Entity The entity that was hit]
function Schema:PlayerStunEntity(player, entity)
  local target = cw.entity:GetPlayer(entity)
  local strength = cw.attributes:Fraction(player, ATB_STRENGTH, 12, 6)

  player:ProgressAttribute(ATB_STRENGTH, 0.5, true)

  if target and target:Alive() then
    local curTime = CurTime()

    if target.nextStunInfo and curTime <= target.nextStunInfo[2] then
      target.nextStunInfo[1] = target.nextStunInfo[1] + 1
      target.nextStunInfo[2] = curTime + 2

      if target.nextStunInfo[1] == 3 then
        cw.player:SetRagdollState(target, RAGDOLL_KNOCKEDOUT, config.Get('knockout_time'):Get())
      end
    else
      target.nextStunInfo = { 0, curTime + 2 }
    end

    target:ViewPunch(Angle(12 + strength, 0, 0))

    netstream.Start(target, 'Stunned', 0.5)
  end
end

--- Called when a player's spawn weapons should be given.
--
-- Gives GHOST units a sniper rifle, vortigaunts their vortigaunt weapon and enslaved vortigaunts a broom.
-- @param player [Player The player]
function Schema:PlayerGiveWeapons(player)
  if player:GetFaction() == FACTION_MPF then
    if self:IsPlayerCombineRank(player, 'GHOST') then
      cw.player:GiveSpawnWeapon(player, 'weapon_ep2sniper')
    end
  elseif player:GetFaction() == FACTION_VORT then
    cw.player:GiveSpawnWeapon(player, 'weapon_vort')
  elseif player:GetFaction() == FACTION_VORT_SLAVE then
    cw.player:GiveSpawnWeapon(player, 'cw_pushbroom')
  end
end

--- Called when an item in a player's inventory is updated.
--
-- Takes off the player's clothes when they no longer have the clothes item.
-- @param player [Player The player]
-- @param itemTable [Item The item]
-- @param amount [Number The change in amount]
-- @param force [Boolean Whether the update was forced]
function Schema:PlayerInventoryItemUpdated(player, itemTable, amount, force)
  local clothes = player:GetCharacterData('clothes')

  if clothes == itemTable.index then
    if !player:HasItemByID(itemTable.uniqueID) then
      itemTable:OnChangeClothes(player, false)

      player:SetCharacterData('clothes', nil)
    end
  end
end

--- Called when a player switches their flashlight; scanner players and tied players cannot turn it on.
-- @param player [Player The player]
-- @param on [Boolean Whether the flashlight is being turned on]
-- @return [Boolean `false` to block the switch]
function Schema:PlayerSwitchFlashlight(player, on)
  if on and (self.scanners[player] or player:GetNetVar('tied') != 0) then
    return false
  end
end

--- Called to check whether a player's storage should close.
--
-- Closes a search of another player once the searched player is no longer tied.
-- @param player [Player The player]
-- @param storage [Map The open storage]
-- @return [Boolean `true` to close the storage]
function Schema:PlayerStorageShouldClose(player, storage)
  local entity = player:GetStorageEntity()

  if player.searching and entity:IsPlayer() and entity:GetNetVar('tied') == 0 then
    return true
  end
end

--- Called when a player attempts to spray; only untied players with a spray can may spray.
-- @param player [Player The player]
-- @return [Boolean `true` to block the spray]
function Schema:PlayerSpray(player)
  if !player:HasItemByID('spray_can') or player:GetNetVar('tied') != 0 then
    return true
  end
end

--- Called when a player presses F3; uses the player's zip tie, or tells them they have none.
-- @param player [Player The player]
function Schema:ShowSpare1(player)
  local itemTable = player:FindItemByID('zip_tie')

  if !itemTable then
    cw.player:Notify(player, L('ZipTie_NotOwned'))

    return
  end

  cw.player:RunClockworkCommand(player, 'InvAction', 'use', itemTable.uniqueID, tostring(itemTable.itemID))
end

--- Called when a player presses F4; runs the `CharSearch` command.
-- @param player [Player The player]
function Schema:ShowSpare2(player)
  cw.player:RunClockworkCommand(player, 'CharSearch')
end

--- Called when a player attempts to spawn a prop.
--
-- While the `cwu_props` config is enabled, citizens outside the Civil Worker's Union cannot spawn beds or
-- the furniture in `Schema.cwuProps`. Admins are exempt.
-- @param player [Player The player]
-- @param model [String The prop's model]
-- @return [Boolean `false` to block the spawn]
function Schema:PlayerSpawnProp(player, model)
  if !player:IsAdmin() and config.Get('cwu_props'):Get() then
    if player:GetFaction() == FACTION_CITIZEN then
      if player:GetCharacterData('customclass') != "Civil Worker's Union" then
        model = string.Replace(model, '\\', '/')
        model = string.Replace(model, '//', '/')
        model = string.lower(model)

        if string.find(model, 'bed') then
          cw.player:Notify(player, L('CWU_NotMember'))

          return false
        end

        for k, v in pairs(self.cwuProps) do
          if string.lower(v) == model then
            cw.player:Notify(player, L('CWU_NotMember'))

            return false
          end
        end
      end
    end
  end
end

--- Called when a player attempts to spawn an object; tied players and scanners cannot.
-- @param player [Player The player]
-- @return [Boolean `false` to block the spawn]
function Schema:PlayerSpawnObject(player)
  if player:GetNetVar('tied') != 0 or self.scanners[player] then
    cw.player:Notify(player, L('Err_NoPermissionRightNow'))

    return false
  end
end

--- Called when a player's character data is restored.
--
-- Gives non-Combine characters a random five-digit citizen ID when they have none, or an old four-digit
-- one.
-- @param player [Player The player]
-- @param data [Map The character data, changed in place]
function Schema:PlayerRestoreCharacterData(player, data)
  if !self:PlayerIsCombine(player) then
    if !data['citizenid'] or string.len(tostring(data['citizenid'])) == 4 then
      data['citizenid'] = cw.core:ZeroNumberToDigits(math.random(1, 99999), 5)
    end
  end
end

--- Called when a player attempts to breach an entity; any real door except rotating ones may be breached.
-- @param player [Player The player]
-- @param entity [Entity The entity]
-- @return [Boolean Whether the entity can be breached, or `nil` for the default]
function Schema:PlayerCanBreachEntity(player, entity)
  if string.lower(entity:GetClass()) == 'func_door_rotating' then
    return false
  end

  if cw.entity:IsDoor(entity) then
    if !cw.entity:IsDoorFalse(entity) then
      return true
    end
  end
end

--- Called when a player attempts to restore a recognised name; Combine names are never restored.
-- @param player [Player The player]
-- @param target [Player The recognised player]
-- @return [Boolean `false` to forget the name]
function Schema:PlayerCanRestoreRecognisedName(player, target)
  if self:PlayerIsCombine(target) then
    return false
  end
end

--- Called when a player attempts to save a recognised name; Combine names are never saved.
-- @param player [Player The player]
-- @param target [Player The recognised player]
-- @return [Boolean `false` to not save the name]
function Schema:PlayerCanSaveRecognisedName(player, target)
  if self:PlayerIsCombine(target) then
    return false
  end
end

--- Called when a player attempts to use the radio.
--
-- Combine players and scanners can always use it; everyone else needs a handheld radio and a frequency.
-- @param player [Player The player]
-- @param text [String The message]
-- @param listeners [Map The players who will hear the message]
-- @param eavesdroppers [Map The players who will overhear it]
-- @return [Boolean `false` to block the message]
function Schema:PlayerCanRadio(player, text, listeners, eavesdroppers)
  local isCombine = player:IsCombine()

  if isCombine or player:HasItemByID('handheld_radio') or self.scanners[player] then
    if !isCombine and !player:GetCharacterData('frequency') then
      cw.player:Notify(player, L('Radio_NeedFrequency'))

      return false
    end
  else
    cw.player:Notify(player, L('Radio_NotOwned'))

    return false
  end
end

--- Called when a player's character has initialized.
--
-- Puts Combine players in the class matching their rank when it has room, and adds a database line to
-- the Combine display for citizens.
-- @param player [Player The player]
function Schema:PlayerCharacterInitialized(player)
  local faction = player:GetFaction()

  if self:PlayerIsCombine(player) then
    for k, v in pairs(cw.class:GetStored()) do
      if v.factions and table.HasValue(v.factions, faction) then
        if #_team.GetPlayers(v.index) < cw.class:GetLimit(v.name) then
          if v.index == CLASS_MPS and self:IsPlayerCombineRank(player, 'SCN') then
            cw.class:Set(player, v.index) break
          elseif v.index == CLASS_MPR and self:IsPlayerCombineRank(player, 'RCT') then
            cw.class:Set(player, v.index) break
          elseif v.index == CLASS_EMP and self:IsPlayerCombineRank(player, 'EpU') then
            cw.class:Set(player, v.index) break
          elseif v.index == CLASS_EOW and self:IsPlayerCombineRank(player, 'EOW') then
            cw.class:Set(player, v.index) break
          end
        end
      end
    end
  elseif faction == FACTION_CITIZEN then
    self:AddCombineDisplayLine(L('CombineDisplay_CitizenDatabase'), Color(255, 100, 255, 255))
  end
end

--- Called when a player's name changes.
--
-- Moves Combine players to the class of a newly gained rank. Civil Protection units who become scanners
-- are turned into one with `Schema:MakePlayerScanner`.
-- @param player [Player The player]
-- @param previousName [String The old name]
-- @param newName [String The new name]
function Schema:PlayerNameChanged(player, previousName, newName)
  if self:PlayerIsCombine(player) then
    local faction = player:GetFaction()

    if faction == FACTION_OTA then
      if !self:IsStringCombineRank(previousName, 'OWS') and self:IsStringCombineRank(newName, 'OWS') then
        cw.class:Set(player, CLASS_OWS)
      elseif !self:IsStringCombineRank(previousName, 'OWC') and self:IsStringCombineRank(newName, 'OWC') then
        cw.class:Set(player, CLASS_OWC)
      elseif !self:IsStringCombineRank(previousName, 'EOW') and self:IsStringCombineRank(newName, 'EOW') then
        cw.class:Set(player, CLASS_EOW)
      end
    elseif faction == FACTION_MPF then
      if !self:IsStringCombineRank(previousName, 'SCN') and self:IsStringCombineRank(newName, 'SCN') then
        cw.class:Set(player, CLASS_MPS, true)

        self:MakePlayerScanner(player, true)
      elseif !self:IsStringCombineRank(previousName, 'RCT') and self:IsStringCombineRank(newName, 'RCT') then
        cw.class:Set(player, CLASS_MPR)
      elseif !self:IsStringCombineRank(previousName, 'EpU') and self:IsStringCombineRank(newName, 'EpU') then
        cw.class:Set(player, CLASS_EMP)
      elseif !self:IsStringCombineRank(newName, 'RCT') then
        if player:Team() != CLASS_MPU then
          cw.class:Set(player, CLASS_MPU)
        end
      end
    end
  end
end

--- Called when a player attempts to use an entity from a vehicle; allows players and their ragdolls.
-- @param player [Player The player]
-- @param entity [Entity The entity]
-- @param vehicle [Vehicle The vehicle]
-- @return [Boolean `true` to allow it]
function Schema:PlayerCanUseEntityInVehicle(player, entity, vehicle)
  if entity:IsPlayer() or cw.entity:IsPlayerRagdoll(entity) then
    return true
  end
end

--- Called when a player presses a key.
--
-- Use starts untying the tied player being looked at. Scanner players play a scanner sound with the
-- attack keys, take a photo with reload that stuns facing non-Combine players nearby, and follow the
-- player they look at with walk (see the `CharFollow` command).
-- @param player [Player The player]
-- @param key [Number The `IN_*` key]
function Schema:KeyPress(player, key)
  if key == IN_USE then
    if !self.scanners[player] then
      local untieTime = Schema:GetDexterityTime(player)
      local target = player:GetEyeTraceNoCursor().Entity
      local entity = target

      if IsValid(target) then
        target = cw.entity:GetPlayer(target)

        if target and player:GetNetVar('tied') == 0 then
          if target:GetShootPos():Distance(player:GetShootPos()) <= 192 then
            if target:GetNetVar('tied') != 0 then
              cw.player:SetAction(player, 'untie', untieTime)

              cw.player:EntityConditionTimer(player, target, entity, untieTime, 192, function()
                return player:Alive() and !player:IsRagdolled() and player:GetNetVar('tied') == 0
              end, function(success)
                if success then
                  self:TiePlayer(target, false)

                  player:ProgressAttribute(ATB_AGILITY, 5, true)
                end

                cw.player:SetAction(player, 'untie', false)
              end)
            end
          end
        end
      end
    end
  elseif key == IN_ATTACK or key == IN_ATTACK2 then
    if self.scanners[player] then
      local scanner = self.scanners[player][1]

      if IsValid(scanner) then
        player.nextScannerSound = CurTime() + math.random(8, 48)

        scanner:EmitSound(self.scannerSounds[math.random(1, #self.scannerSounds)])
      end
    end
  elseif key == IN_RELOAD then
    if self.scanners[player] then
      local scanner = self.scanners[player][1]
      local curTime = CurTime()
      local marker = self.scanners[player][2]

      if IsValid(scanner) then
        local position = scanner:GetPos()

        for k, v in ipairs(ents.FindInSphere(position, 384)) do
          if v:IsPlayer() and v:HasInitialized() and !self:PlayerIsCombine(v) then
            local playerPosition = v:GetPos()
            local scannerDot = scanner:GetAimVector():Dot((playerPosition - position):GetNormalized())
            local playerDot = v:GetAimVector():Dot((position - playerPosition):GetNormalized())
            local threshold = 0.2 + math.Clamp((0.6 / 384) * playerPosition:Distance(position), 0, 0.6)

            if cw.player:CanSeeEntity(v, scanner, 0.9, { marker }) and playerDot >= threshold
            and scannerDot >= threshold then
              if player != v then
                if v:GetFaction() == FACTION_CITIZEN then
                  if !v:GetForcedAnimation() then
                    v:SetForcedAnimation('photo_react_blind', 2, function(player)
                      player:Freeze(true)
                    end, function(player)
                      player:Freeze(false)
                    end)
                  end
                end

                netstream.Start(v, 'Stunned', 3)
              end
            end
          end
        end

        scanner:EmitSound('npc/scanner/scanner_photo1.wav')
      end
    end
  elseif key == IN_WALK then
    if self.scanners[player] then
      cw.player:RunClockworkCommand(player, 'CharFollow')
    end
  end
end

--- Called every tick.
--
-- Moves each scanner's follow marker while its player holds forward (slower with sprint) and removes the
-- scanners of players who left.
function Schema:Tick()
  for k, v in pairs(self.scanners) do
    local scanner = v[1]
    local marker = v[2]

    if IsValid(k) then
      if IsValid(scanner) and IsValid(marker) then
        if k:KeyDown(IN_FORWARD) then
          local position = scanner:GetPos() + (scanner:GetForward() * 25) + (scanner:GetUp() * -64)

          if k:KeyDown(IN_SPEED) then
            marker:SetPos(position + (k:GetAimVector() * 64))
          else
            marker:SetPos(position + (k:GetAimVector() * 128))
          end

          scanner.followTarget = nil
        end

        if IsValid(scanner.followTarget) then
          scanner:Input('SetFollowTarget', scanner.followTarget, scanner.followTarget, '!activator')
        else
          scanner:Fire('SetFollowTarget', 'marker_'..k:SteamID64(), 0)
        end

        if scannerClass == 'npc_cscanner' and self:IsPlayerCombineRank(k, 'SYNTH') then
          self:MakePlayerScanner(k, true)
        elseif scannerClass == 'npc_clawscanner' and !self:IsPlayerCombineRank(k, 'SYNTH') then
          self:MakePlayerScanner(k, true)
        end
      else
        self:ResetPlayerScanner(k)
      end
    else
      if IsValid(scanner) then
        scanner:Remove()
      end

      if IsValid(marker) then
        marker:Remove()
      end

      self.scanners[k] = nil
    end
  end
end

--- Called when a player's health is set; copies it to their scanner.
-- @param player [Player The player]
-- @param newHealth [Number The new health]
-- @param oldHealth [Number The old health]
function Schema:PlayerHealthSet(player, newHealth, oldHealth)
  if self.scanners[player] then
    if IsValid(self.scanners[player][1]) then
      self.scanners[player][1]:SetHealth(newHealth)
    end
  end
end

--- Called when a player attempts to be given a weapon; scanner players cannot.
-- @param player [Player The player]
-- @param class [String The weapon class]
-- @param uniqueID [String The item's unique ID]
-- @param forceReturn [Boolean Whether the weapon is being returned forcibly]
-- @return [Boolean `false` to block the weapon]
function Schema:PlayerCanBeGivenWeapon(player, class, uniqueID, forceReturn)
  if self.scanners[player] then
    return false
  end
end

--- Called each frame a player is dead; permakilled characters cannot respawn.
-- @param player [Player The player]
-- @return [Boolean `true` to stop the player respawning]
function Schema:PlayerDeathThink(player)
  if player:GetCharacterData('permakilled') then
    return true
  end
end

--- Called when a player attempts to switch characters.
--
-- Permakilled characters can always be switched from; tied characters cannot.
-- @param player [Player The player]
-- @param character [Character The character to switch to]
-- @return [Boolean Whether the switch is allowed, String The reason when it is not]
function Schema:PlayerCanSwitchCharacter(player, character)
  if player:GetCharacterData('permakilled') then
    return true
  end

  if player:GetNetVar('tied') != 0 then
    return false, L('CantSwitchWhenTied')
  end
end

--- Called when a player's death info should be adjusted; permakilled characters get no respawn time.
-- @param player [Player The player]
-- @param info [Map The death info; `spawnTime` may be replaced]
function Schema:PlayerAdjustDeathInfo(player, info)
  if player:GetCharacterData('permakilled') then
    info.spawnTime = 0
  end
end

--- Called when a character's entry on the character screen should be adjusted.
--
-- Marks permakilled characters, shows Overwatch availability, shows the elite Overwatch and scanner
-- models and passes on the character's custom class.
-- @param player [Player The player whose characters are listed]
-- @param character [Character The character]
-- @param info [Map The entry: `name`, `faction`, and `details`, `model` and `customClass`, which may be set]
function Schema:PlayerAdjustCharacterScreenInfo(player, character, info)
  if character.data['permakilled'] then
    info.details = L('CharScreen_PermaKilled')
  end

  if info.faction == FACTION_OTA then
    if self:IsStringCombineRank(info.name, 'EOW') then
      info.model = 'models/combine_super_soldier.mdl'
    end

  --	if self.OTACanUse then
    info.details = L('CharScreen_OTAAvailable')
  --	else
  --		info.details = "Overwatch Transhuman Arms в данный момент в стазисе."
  --	end
  elseif self:IsCombineFaction(info.faction) then
    if !self:CanUseCP(player) and self:GetPlayerCombineRank(player) < 6 then
      info.details = L('CharScreen_TooManyCP')
    end

    if self:IsStringCombineRank(info.name, 'SCN') then
      if self:IsStringCombineRank(info.name, 'SYNTH') then
        info.model = 'models/shield_scanner.mdl'
      else
        info.model = 'models/combine_scanner.mdl'
      end

    -- elseif (self:IsStringCombineRank(info.name, "SeC")) then
    -- 	info.model = "models/metropolice/c08.mdl"
    -- elseif (self:IsStringCombineRank(info.name, "DvL")) then
    -- 	info.model = "models/metropolice/c08.mdl"
    -- elseif (self:IsStringCombineRank(info.name, "EpU")) then
    -- 	info.model = "models/metropolice/c08.mdl"
    -- elseif (self:IsStringCombineRank(info.name, "OfC")) then
    -- 	info.model = "models/metropolice/c08.mdl"
    -- end

    -- if (self:IsStringCombineRank(info.name, "GHOST")) then
    -- 	info.model = "models/metropolice/c08.mdl"
    end
  end

  if character.data['customclass'] then
    info.customClass = character.data['customclass']
  end
end

--- Called after a player has used the radio.
--
-- Sends the message to players near switched-on stationary radios tuned to the player's frequency, within
-- twice the talk radius.
-- @param player [Player The player]
-- @param text [String The message]
-- @param listeners [Map<Player> The players who heard the message]
-- @param eavesdroppers [Map<Player> The players who overheard it]
function Schema:PlayerRadioUsed(player, text, listeners, eavesdroppers)
  local newEavesdroppers = {}
  local talkRadius = config.Get('talk_radius'):Get() * 2
  local frequency = player:GetCharacterData('frequency')

  for k, v in ipairs(ents.FindByClass('cw_radio')) do
    local radioPosition = v:GetPos()
    local radioFrequency = v:GetFrequency()

    if !v:IsOff() and radioFrequency == frequency then
      for k2, v2 in ipairs(_player.GetAll()) do
        if v2:HasInitialized() and !listeners[v2] and !eavesdroppers[v2] then
          if v2:GetPos():Distance(radioPosition) <= talkRadius then
            newEavesdroppers[v2] = v2
          end
        end

        break
      end
    end
  end

  if table.Count(newEavesdroppers) > 0 then
    chatbox.AddText(newEavesdroppers, text, {
      suffix = ' #Suffix_StationaryRadio ',
      sender = player,
      isPlayerMessage = true,
      filter = 'ic',
      radius = 0,
      textColor = Color(255, 255, 200, 255)
    })
  end
end

--- Called when a player's radio message info should be adjusted.
--
-- Combine players reach every Combine player; everyone else reaches untied players with a handheld radio
-- on the same frequency.
-- @param player [Player The player sending the message]
-- @param info [Map The radio info; players are added to its `listeners`]
function Schema:PlayerAdjustRadioInfo(player, info)
  local isCombine = player:IsCombine()

  for k, v in ipairs(_player.GetAll()) do
    if v:HasInitialized() then
      if isCombine and Schema:PlayerIsCombine(v) then
        info.listeners[v] = v
      elseif v:HasItemByID('handheld_radio')
      and v:GetCharacterData('frequency') == player:GetCharacterData('frequency') then
        if v:GetNetVar('tied') == 0 then
          info.listeners[v] = v
        end
      end
    end
  end
end

--- Called when a player attempts to use a tool; Wire tools need the `w` flag.
-- @param player [Player The player]
-- @param trace [Map The player's eye trace]
-- @param tool [String The tool mode]
-- @return [Boolean `false` to block the tool]
function Schema:CanTool(player, trace, tool)
  if !cw.player:HasFlags(player, 'w') then
    if string.sub(tool, 1, 5) == 'wire_' or string.sub(tool, 1, 6) == 'wire2_' then
      player:RunCommand('gmod_toolmode', '')

      return false
    end
  end
end

--- Called when a player has been healed.
--
-- Boosts the healer's Agility and progresses their Medical attribute, more for a health kit than a
-- health vial and least for a bandage.
-- @param player [Player The player who was healed]
-- @param healer [Player The player who healed them]
-- @param itemTable [Item The item used]
function Schema:PlayerHealed(player, healer, itemTable)
  if itemTable.uniqueID == 'health_vial' then
    healer:BoostAttribute(itemTable.PrintName, ATB_AGILITY, 2, 120)
    healer:ProgressAttribute(ATB_MEDICAL, 15, true)
  elseif itemTable.uniqueID == 'health_kit' then
    healer:BoostAttribute(itemTable.PrintName, ATB_AGILITY, 3, 120)
    healer:ProgressAttribute(ATB_MEDICAL, 25, true)
  elseif itemTable.uniqueID == 'bandage' then
    healer:BoostAttribute(itemTable.PrintName, ATB_AGILITY, 1, 120)
    healer:ProgressAttribute(ATB_MEDICAL, 5, true)
  end
end

--- Called every second for each player.
--
-- Networks the custom class, citizen ID, clothes and icon character data, and progresses Strength while
-- the player moves carrying at least a quarter of their maximum weight.
-- @param player [Player The player]
-- @param curTime [Number The current `CurTime()`]
function Schema:OnePlayerSecond(player, curTime)
  player:SetNetVar('customClass', player:GetCharacterData('customclass', ''))
  player:SetNetVar('citizenID', player:GetCharacterData('citizenid', ''))
  player:SetNetVar('clothes', player:GetCharacterData('clothes', 0))
  player:SetNetVar('icon', player:GetCharacterData('icon', ''))

  if player:Alive() and !player:IsRagdolled() and player:GetVelocity():Length() > 0 then
    local inventoryWeight = player:GetInventoryWeight()

    if inventoryWeight >= player:GetMaxWeight() / 4 then
      player:ProgressAttribute(ATB_STRENGTH, inventoryWeight / 400, true)
    end
  end
end

--- Called at an interval while a player is connected.
--
-- Progresses Agility while jumping or running, runs `Schema:CalculateScannerThink` for scanners, and
-- raises carry weight, jump power and run speed from the Strength and Agility attributes. Combine
-- players carry 8 more.
-- @param player [Player The player]
-- @param curTime [Number The current `CurTime()`]
-- @param infoTable [Map The player's movement info, adjusted in place]
function Schema:PlayerThink(player, curTime, infoTable)
  if player:Alive() and !player:IsRagdolled() then
    if !player:InVehicle() and player:GetMoveType() == MOVETYPE_WALK then
      if !player:IsOnGround() then
        player:ProgressAttribute(ATB_AGILITY, 0.1, true)
      elseif infoTable.running then
        player:ProgressAttribute(ATB_AGILITY, 0.05, true)
      end
    end
  end

  if self.scanners[player] then
    self:CalculateScannerThink(player, curTime)
  end

  if self:PlayerIsCombine(player) then
    infoTable.inventoryWeight = infoTable.inventoryWeight + 8
  end

  infoTable.inventoryWeight = infoTable.inventoryWeight + cw.attributes:Fraction(player, ATB_STRENGTH, 8, 4)
  infoTable.jumpPower = infoTable.jumpPower + cw.attributes:Fraction(player, ATB_AGILITY, 100, 50)
  infoTable.runSpeed = infoTable.runSpeed + cw.attributes:Fraction(player, ATB_AGILITY, 50, 25)
end

--- Called when an entity is removed.
--
-- When a ragdoll holding belongings (see `Schema:PermaKillPlayer`) is removed, they are left behind as a
-- `cw_belongings` entity.
-- @param entity [Entity The entity]
function Schema:EntityRemoved(entity)
  if cw.core:IsShuttingDown() then return end

  if IsValid(entity) and entity:GetClass() == 'prop_ragdoll' then
    if entity.areBelongings and entity.cwInventory and entity.cash then
      if table.Count(entity.cwInventory) > 0 or entity.cash > 0 then
        local belongings = ents.Create('cw_belongings')

        belongings:SetAngles(Angle(0, 0, -90))
        belongings:SetData(entity.cwInventory, entity.cash)
        belongings:SetPos(entity:GetPos() + Vector(0, 0, 32))
        belongings:Spawn()

        entity.cwInventory = nil
        entity.cash = nil
      end
    end
  end
end

--- Called when a player attempts to be ragdolled; scanners cannot.
-- @param player [Player The player]
-- @param state [Number The `RAGDOLL_*` state]
-- @param delay [Number How long the ragdoll lasts]
-- @param decay [Number How long the ragdoll takes to decay]
-- @param ragdoll [Entity The existing ragdoll, if any]
-- @return [Boolean `false` to block it]
function Schema:PlayerCanRagdoll(player, state, delay, decay, ragdoll)
  if self.scanners[player] then
    return false
  end
end

--- Called when a player attempts to noclip; scanners cannot.
-- @param player [Player The player]
-- @return [Boolean `false` to block it]
function Schema:PlayerNoClip(player)
  if self.scanners[player] then
    return false
  end
end

--- Called when a player's data should be saved; drops an empty server whitelist.
-- @param player [Player The player]
-- @param data [Map The player data, changed in place]
function Schema:PlayerSaveData(player, data)
  if data['serverwhitelist'] and table.Count(data['serverwhitelist']) == 0 then
    data['serverwhitelist'] = nil
  end
end

--- Called when a player's data is restored.
--
-- Kicks players missing from the whitelist named by the `server_whitelist_identity` config, when set.
-- @param player [Player The player]
-- @param data [Map The player data; `serverwhitelist` is created when missing]
function Schema:PlayerRestoreData(player, data)
  if !data['serverwhitelist'] then
    data['serverwhitelist'] = {}
  end

  local serverWhitelistIdentity = config.Get('server_whitelist_identity'):Get()

  if serverWhitelistIdentity != '' then
    if !data['serverwhitelist'][serverWhitelistIdentity] then
      player:Kick(cw.lang:GetString('en', '#ServerWhitelist_KickReason'))
    end
  end
end

--- Called to check whether a player has a flag.
--
-- When permits are disabled, denies the business flag `x`, the general goods flag `1` and every custom
-- permit flag.
-- @param player [Player The player to check]
-- @param flag [String The flag]
-- @return [Boolean `false` to deny the flag, or `nil` to leave it to the flag system]
function Schema:PlayerDoesHaveFlag(player, flag)
  if !config.Get('permits'):Get() then
    if flag == 'x' or flag == '1' then
      return false
    end

    for k, v in pairs(self.customPermits) do
      if v.flag == flag then
        return false
      end
    end
  end
end

--- Called when a player's attribute is updated; shows an attribute line on a Combine player's display.
-- @param player [Player The player]
-- @param attributeTable [Attribute The attribute]
-- @param amount [Number The change in the attribute]
function Schema:PlayerAttributeUpdated(player, attributeTable, amount)
  if self:PlayerIsCombine(player) and amount and amount > 0 then
    self:AddCombineDisplayLine(L('CombineDisplay_AttributesUpdated'), Color(255, 125, 0, 255), player)
  end
end

--- Called to check whether a player recognises another player.
--
-- Combine players and administrators are always recognised.
-- @param player [Player The player who may recognise the target]
-- @param target [Player The player to be recognised]
-- @param status [Number The `RECOGNISE_*` level being checked]
-- @param isAccurate [Boolean Whether the level must match exactly]
-- @param realValue [Boolean The result of the recognition system]
-- @return [Boolean `true` to recognise the target, or `nil` to keep `realValue`]
function Schema:PlayerDoesRecognisePlayer(player, target, status, isAccurate, realValue)
  if self:PlayerIsCombine(target) or target:GetFaction() == FACTION_ADMIN then
    return true
  end
end

--- Called when a player attempts to delete a character; permakilled characters can always be deleted.
-- @param player [Player The player]
-- @param character [Character The character]
-- @return [Boolean `true` to allow the deletion, or `nil` for the default]
function Schema:PlayerCanDeleteCharacter(player, character)
  if character.data['permakilled'] then
    return true
  end
end

--- Called when a player attempts to use a character.
--
-- Refuses permakilled characters, Civil Protection characters while `Schema:CanUseCP` is `false` (below
-- rank 6) and scanner characters while three scanners are online.
-- @param player [Player The player]
-- @param character [Character The character]
-- @return [String The reason the character cannot be used, or `nil` to allow it]
function Schema:PlayerCanUseCharacter(player, character)
  if character.data['permakilled'] then
    return L('CharIsPermaKilled', character.name)
  -- elseif (character.faction == FACTION_OTA) and !self:IsStringCombineRank(character.name, "GUARD")
  -- and !self.OTACanUse then
  --	return "Overwatch Transhuman Arms сейчас в стазисе!"
  elseif character.faction == FACTION_MPF then
    if !self:CanUseCP(player) and self:GetPlayerCombineRank(player) < 6 then
      return L('TooManyCPOnline')
    end

    if self:IsStringCombineRank(character.name, 'SCN') then
      local amount = 0

      for k, v in ipairs(_player.GetAll()) do
        if v:HasInitialized() and self:PlayerIsCombine(v) then
          if self:IsPlayerCombineRank(v, 'SCN') then
            amount = amount + 1
          end
        end
      end

      if amount >= 3 then
        return L('TooManyScannersOnline')
      end
    end
  end
end

--- Called when a player attempts to use a command.
--
-- Tied players cannot order shipments, broadcast, dispatch, request or use the radio.
-- @param player [Player The player]
-- @param commandTable [Command The command]
-- @param arguments [List<String> The command's arguments]
-- @return [Boolean `false` to block the command]
function Schema:PlayerCanUseCommand(player, commandTable, arguments)
  if player:GetNetVar('tied') != 0 then
    local blacklisted = {
      'OrderShipment',
      'Broadcast',
      'Dispatch',
      'Request',
      'Radio'
    }

    if table.HasValue(blacklisted, commandTable.name) then
      cw.player:Notify(player, L('CantUseCommandWhenTied'))

      return false
    end
  end
end

--- Called when a player attempts to open a door with the use key.
--
-- Only untied Combine players, administrators and holders of a `combine_lock_access_x` card may.
-- @param player [Player The player]
-- @param door [Entity The door]
-- @return [Boolean `false` to block it]
function Schema:PlayerCanUseDoor(player, door)
  if player:GetNetVar('tied') != 0
  or (!self:PlayerIsCombine(player) and player:GetFaction() != FACTION_ADMIN
  and !player:HasItemByID('combine_lock_access_x')) then
    return false
  end
end

--- Called when a player attempts to lock an entity.
--
-- Doors with a Combine lock cannot be locked with keys while the lock is locked or the
-- `combine_lock_overrides` config is enabled.
-- @param player [Player The player]
-- @param entity [Entity The entity]
-- @return [Boolean `false` to block it]
function Schema:PlayerCanLockEntity(player, entity)
  if cw.entity:IsDoor(entity) and IsValid(entity.combineLock) then
    if config.Get('combine_lock_overrides'):Get() or entity.combineLock:IsLocked() then
      return false
    end
  end
end

--- Called when a player attempts to unlock an entity.
--
-- Doors with a Combine lock cannot be unlocked with keys while the lock is locked or the
-- `combine_lock_overrides` config is enabled.
-- @param player [Player The player]
-- @param entity [Entity The entity]
-- @return [Boolean `false` to block it]
function Schema:PlayerCanUnlockEntity(player, entity)
  if cw.entity:IsDoor(entity) and IsValid(entity.combineLock) then
    if config.Get('combine_lock_overrides'):Get() or entity.combineLock:IsLocked() then
      return false
    end
  end
end

--- Called when a player's character has unloaded; removes their scanner.
-- @param player [Player The player]
function Schema:PlayerCharacterUnloaded(player)
  self:ResetPlayerScanner(player)
end

--- Called when a player attempts to change class.
--
-- Tied players cannot, and Combine players can only join the classes their rank allows; the player is
-- told why.
-- @param player [Player The player]
-- @param class [Number The class index]
-- @return [Boolean `false` to block the change]
function Schema:PlayerCanChangeClass(player, class)
  if player:GetNetVar('tied') != 0 then
    cw.player:Notify(player, L('CantChangeClassWhenTied'))

    return false
  elseif self:PlayerIsCombine(player) then
    if class == CLASS_MPS and !self:IsPlayerCombineRank(player, 'SCN') then
      cw.player:Notify(player, L('CombineRank_TooLow'))

      return false
    elseif class == CLASS_MPR and !self:IsPlayerCombineRank(player, 'RCT') then
      cw.player:Notify(player, L('CombineRank_TooLow'))

      return false
    elseif class == CLASS_EMP and !self:IsPlayerCombineRank(player, 'EpU') then
      cw.player:Notify(player, L('CombineRank_TooLow'))

      return false
    elseif class == CLASS_OWS and !self:IsPlayerCombineRank(player, 'OWS') then
      cw.player:Notify(player, L('CombineRank_TooLow'))

      return false
    elseif class == CLASS_EOW and !self:IsPlayerCombineRank(player, 'EOW') then
      cw.player:Notify(player, L('CombineRank_TooLow'))

      return false
    elseif class == CLASS_MPU then
      if self:IsPlayerCombineRank(player, 'EpU') then
        cw.player:Notify(player, L('CombineRank_TooHigh'))

        return false
      elseif self:IsPlayerCombineRank(player, 'RCT') then
        cw.player:Notify(player, L('CombineRank_TooLow'))

        return false
      end
    end
  end
end

--- Called when a player attempts to use an entity.
--
-- Restricts entities whose overlay text contains `CA`, `OTA`, `MPF` or `CWU` to those factions (and
-- those above them), and blocks scanners, busted-down doors and tied players (who may still use seats).
-- Sprint and use toggles a door's Combine lock for players with access, every three seconds at most.
-- @param player [Player The player]
-- @param entity [Entity The entity]
-- @return [Boolean `false` to block the use]
function Schema:PlayerUse(player, entity)
  local overlayText = entity:GetNWString('GModOverlayText')
  local curTime = CurTime()
  local faction = player:GetFaction()

  if string.find(overlayText, 'CA') then
    if faction != FACTION_ADMIN then
      return false
    end
  elseif string.find(overlayText, 'OTA') then
    if faction != FACTION_ADMIN and faction != FACTION_OTA then
      return false
    end
  elseif string.find(overlayText, 'MPF') then
    if faction != FACTION_ADMIN and faction != FACTION_OTA and faction != FACTION_MPF then
      return false
    end
  elseif string.find(overlayText, 'CWU') then
    if faction != FACTION_ADMIN and faction != FACTION_OTA and faction != FACTION_MPF then
      if player:GetCharacterData('customclass') != "Civil Worker's Union" then
        return false
      end
    end
  end

  if self.scanners[player] then
    return false
  end

  if entity.bustedDown then
    return false
  end

  if player:KeyDown(IN_SPEED) and cw.entity:IsDoor(entity) then
    if IsValid(entity.combineLock) then
      if self:PlayerIsCombine(player) or player:GetFaction() == FACTION_ADMIN
      or Schema:PlayerHasCombineLockAccess(player, entity.combineLock.access, entity.combineLock.rank) then
        if !player.nextCombineLock or curTime >= player.nextCombineLock then
          entity.combineLock:ToggleWithChecks(player)

          player.nextCombineLock = curTime + 3
        end

        return false
      end
    end
  end

  if player:GetNetVar('tied') != 0 then
    if entity:IsVehicle() then
      if cw.entity:IsChairEntity(entity) or cw.entity:IsPodEntity(entity) then
        return
      end
    end

    if !player.nextTieNotify or player.nextTieNotify < CurTime() then
      cw.player:Notify(player, '#Err_CantUse_Tied')

      player.nextTieNotify = CurTime() + 2
    end

    return false
  end
end

--- Called when a player attempts to destroy an item; scanners and tied players cannot.
-- @param player [Player The player]
-- @param itemTable [Item The item]
-- @param noMessage [Boolean Whether to skip telling the player why]
-- @return [Boolean `false` to block it]
function Schema:PlayerCanDestroyItem(player, itemTable, noMessage)
  if self.scanners[player] then
    if !noMessage then
      cw.player:Notify(player, L('Scanner_CantDestroyItems'))
    end

    return false
  elseif player:GetNetVar('tied') != 0 then
    if !noMessage then
      cw.player:Notify(player, L('Tied_CantDestroyItems'))
    end

    return false
  end
end

--- Called when a player attempts to drop an item; scanners and tied players cannot.
-- @param player [Player The player]
-- @param itemTable [Item The item]
-- @param noMessage [Boolean Whether to skip telling the player why]
-- @return [Boolean `false` to block it]
function Schema:PlayerCanDropItem(player, itemTable, noMessage)
  if self.scanners[player] then
    if !noMessage then
      cw.player:Notify(player, L('Scanner_CantDropItems'))
    end

    return false
  elseif player:GetNetVar('tied') != 0 then
    if !noMessage then
      cw.player:Notify(player, L('Tied_CantDropItems'))
    end

    return false
  end
end

--- Called when a player attempts to use an item.
--
-- Scanners and tied players cannot use items. Players can equip one secondary weapon (weight 1 to 2), one
-- primary weapon (heavier) and one melee or light weapon (lighter than 1) at a time.
-- @param player [Player The player]
-- @param itemTable [Item The item]
-- @param noMessage [Boolean Whether to skip telling the player why]
-- @return [Boolean `false` to block it]
function Schema:PlayerCanUseItem(player, itemTable, noMessage)
  if self.scanners[player] then
    if !noMessage then
      cw.player:Notify(player, L('Scanner_CantUseItems'))
    end

    return false
  elseif player:GetNetVar('tied') != 0 then
    if !noMessage then
      cw.player:Notify(player, L('Tied_CantUseItems'))
    end

    return false
  end

  if item.IsWeapon(itemTable) then
    local secondaryWeapon
    local primaryWeapon
    local sideWeapon
    local fault

    for k, v in ipairs(player:GetWeapons()) do
      local weaponTable = item.GetByWeapon(v)

      if weaponTable and !weaponTable:IsFakeWeapon() then
        if weaponTable.weight >= 1 and !weaponTable:IsMeleeWeapon() then
          if weaponTable.weight <= 2 then
            secondaryWeapon = true
          else
            primaryWeapon = true
          end
        else
          sideWeapon = true
        end
      end
    end

    if itemTable.weight >= 1 then
      if itemTable.weight <= 2 then
        if secondaryWeapon then
          fault = L('Weapon_CantUseAnotherSecondary')
        end
      elseif primaryWeapon then
        fault = L('Weapon_CantUseAnotherPrimary')
      end
    elseif sideWeapon then
      fault = L('Weapon_CantUseAnotherMelee')
    end

    if fault then
      if !noMessage then
        cw.player:Notify(player, fault)
      end

      return false
    end
  end
end

--- Called when a player attempts to earn cash from a generator; Combine players cannot.
-- @param player [Player The player]
-- @param info [Map The generator info]
-- @param cash [Number The amount]
-- @return [Boolean `false` to block it]
function Schema:PlayerCanEarnGeneratorCash(player, info, cash)
  if self:PlayerIsCombine(player) then
    return false
  end
end

--- Called when a player's death sound should be played.
--
-- For Combine players whose biosignal is still active, every such Combine player hears the lost
-- biosignal announcement with the last three digits of the dead unit's name.
-- @param player [Player The player]
-- @param gender [String The player's gender]
-- @return [String A Civil Protection death sound, or `nil` for the default]
function Schema:PlayerPlayDeathSound(player, gender)
  if self:PlayerIsCombine(player) and !player:GetSharedVar('IsBiosignalGone') then
    local Digits = string.Right(player:Name(), 3)
    local sound = 'npc/metropolice/die'..math.random(1, 4)..'.wav'

    for k, v in ipairs(_player.GetAll()) do
      if v:HasInitialized() then
        if self:PlayerIsCombine(v) and !v:GetSharedVar('IsBiosignalGone') then
          v:EmitSound('npc/overwatch/radiovoice/lostbiosignalforunit.wav')

          timer.Simple(2.3, function()
            for i = 1, #Digits do
              timer.Simple((i - 1) / 3, function()
                local DigitToString = {
                  [1] = 'one',
                  [2] = 'two',
                  [3] = 'three',
                  [4] = 'four',
                  [5] = 'five',
                  [6] = 'six',
                  [7] = 'seven',
                  [8] = 'eight',
                  [9] = 'nine',
                  [0] = 'zero'
                }

                local Digit = tonumber(string.sub(Digits, i, i))

                v:EmitSound('npc/overwatch/radiovoice/'..DigitToString[Digit]..'.wav')

                if i == #Digits then
                  timer.Simple(0.5, function()
                    v:EmitSound('npc/overwatch/radiovoice/remainingunitscontain.wav')
                    timer.Simple(1.4, function()
                      v:EmitSound('npc/metropolice/vo/off'..math.random(1, 4)..'.wav')
                    end)
                  end)
                end
              end)
            end
          end)
        end
      end
    end

    return sound
  end
end

--- Called when a player's pain sound should be played; Combine players use Civil Protection sounds.
-- @param player [Player The player]
-- @param gender [String The player's gender]
-- @param damageInfo [CTakeDamageInfo The damage]
-- @param hitGroup [Number The `HITGROUP_*` hit]
-- @return [String The sound, or `nil` for the default]
function Schema:PlayerPlayPainSound(player, gender, damageInfo, hitGroup)
  if self:PlayerIsCombine(player) then
    return 'npc/metropolice/pain'..math.random(1, 4)..'.wav'
  end
end

local function SplitVoiceCodes(str)
  local chars = string.Explode('', str)
  local exploded = {}
  local curPhrase = ''
  local prevChar = ''
  local curDelay = 0

  for k, v in ipairs(chars) do
    if v == '|' then
      curDelay = curDelay + 1
    elseif v != '|' and prevChar == '|' then
      table.insert(exploded, { curPhrase, curDelay })
      curDelay = 0
      curPhrase = v
    else
      curPhrase = curPhrase..v
    end

    prevChar = v
  end

  if curPhrase != '' then
    table.insert(exploded, { curPhrase, 0 })
  end

  return exploded
end

--- Called when a chat message's info should be adjusted.
--
-- In-character messages starting with `?` are sent anonymously, without the `?`.
-- @param info [Map The message: `filter`, `sender`, `text` and `data`, changed in place]
-- @param listeners [List<Player> The players who will receive it]
function Schema:ChatboxAdjustMessageInfo(info, listeners)
  if info.filter != 'ooc' and info.filter != 'looc' then
    if IsValid(info.sender) and info.sender:HasInitialized() then
      if string.sub(info.text, 1, 1) == '?' then
        info.text = string.sub(info.text, 2)
        info.data.anon = true
      end
    end
  end
end

--- Called when a player destroys a generator.
--
-- Pays a quarter of the generator's cash to the player, or to every Combine player when a Combine
-- player destroyed it.
-- @param player [Player The player]
-- @param entity [Entity The generator entity]
-- @param generator [Map The generator info, with `cash` and `name`]
function Schema:PlayerDestroyGenerator(player, entity, generator)
  local cash = math.Round(generator.cash / 4)

  if self:PlayerIsCombine(player) then
    local players = {}

    for k, v in ipairs(_player.GetAll()) do
      if v:HasInitialized() then
        if self:PlayerIsCombine(v) then
          players[#players + 1] = v
        end
      end
    end

    for k, v in pairs(players) do
      cw.player:GiveCash(v, cash, L('CashReason_DestroyGenerator', string.lower(generator.name)))
    end
  else
    cw.player:GiveCash(player, cash, L('CashReason_DestroyGenerator', string.lower(generator.name)))
  end
end

--- Called just before a player dies.
--
-- Returns worn clothes to the inventory, ends any search and unties the player without a respawn.
-- @param player [Player The player]
-- @param attacker [Entity The attacker]
-- @param damageInfo [CTakeDamageInfo The damage]
function Schema:DoPlayerDeath(player, attacker, damageInfo)
  local clothes = player:GetCharacterData('clothes')

  if clothes then
    player:GiveItem(item.CreateInstance(clothes))
    player:SetCharacterData('clothes', nil)
  end

  player.beingSearched = nil
  player.searching = nil

  self:TiePlayer(player, false, true)
end

--- Called when a player dies.
--
-- Combine deaths trigger the `cwCTO` biosignal loss and a radio announcement, and destroy the unit's
-- scanner. Deaths at the hands of a player or NPC permakill the character when `enable_permakill` is
-- on and the player lacks the `d` flag. Other deaths lose each item with a one in four chance and 40 to
-- 60 percent of the cash.
-- @param player [Player The player]
-- @param inflictor [Entity The inflictor]
-- @param attacker [Entity The attacker]
-- @param damageInfo [CTakeDamageInfo The damage, or `true` when the player's scanner was destroyed]
function Schema:PlayerDeath(player, inflictor, attacker, damageInfo)
  if self:PlayerIsCombine(player) then
    local location = self:PlayerGetLocation(player)

    if !player:GetSharedVar('IsBiosignalGone') then
      cwCTO:DoPostBiosignalLoss(player)
    end

    if self.scanners[player] then
      if IsValid(self.scanners[player][1]) then
        if damageInfo != true then
          self.scanners[player][1]:TakeDamage(self.scanners[player][1]:Health() + 100)
        end
      end
    end

    for k, v in ipairs(_player.GetAll()) do
      if self:PlayerIsCombine(v) then
        v:EmitSound('npc/overwatch/radiovoice/on1.wav')
        v:EmitSound('npc/overwatch/radiovoice/lostbiosignalforunit.wav')
      end
    end

    timer.Simple(1.5, function()
      for k, v in ipairs(_player.GetAll()) do
        if self:PlayerIsCombine(v) then
          v:EmitSound('npc/overwatch/radiovoice/off4.wav')
        end
      end
    end)
  end

  if (attacker:IsPlayer() or attacker:IsNPC()) and damageInfo then
    if config.Get('enable_permakill'):Get() and !player:GetCharacterData('permakilled')
    and !cw.player:HasFlags(player, 'd') then
      local miscellaneousDamage =
        damageInfo:IsBulletDamage() or damageInfo:IsFallDamage() or damageInfo:IsExplosionDamage()
      local meleeDamage = damageInfo:IsDamageType(DMG_CLUB) or damageInfo:IsDamageType(DMG_SLASH)

      if miscellaneousDamage or meleeDamage then
        self:PermaKillPlayer(player, player:GetRagdollEntity())
      end
    end
  else
    local inventory = player:GetInventory()

    for k, v in pairs(cw.inventory:GetAsItemsList(inventory)) do
      if math.random(1, 4) == 1 then
        player:TakeItem(v)
      end
    end

    player:SetCharacterData('cash', math.Round(player:GetCash() * math.random(40, 60) * 0.01), true)

    cw.player:Notify(player, L('Death_LostCashAndItems'))
  end
end

--- Called when a player's character has loaded.
--
-- Resets the permakill and tied state and networks the loyalty, criminal and work points, citizen
-- status, residence, jail state and job from the character data.
-- @param player [Player The player]
function Schema:PlayerCharacterLoaded(player)
  player:SetNetVar('permaKilled', false)
  player:SetNetVar('tied', 0)
  player:SetNetVar('LoyaltyPoints', player:GetCharacterData('LoyaltyPoints') or 0)
  player:SetNetVar('CriminalPoints', player:GetCharacterData('CriminalPoints') or 0)
  player:SetNetVar('CitizenStatus', player:GetCharacterData('CitizenStatus') or 'Unverified')
  player:SetNetVar('Residence', player:GetCharacterData('Residence') or 'Unknown')
  player:SetNetVar('Jailed', player:GetCharacterData('Jailed') or false)
  player:SetNetVar('Job', player:GetCharacterData('Job') or 'None')
  player:SetNetVar('WorkPoints', player:GetCharacterData('WorkPoints') or 0)
end

--- Called just after a player spawns.
--
-- On a full spawn, clears effects and searches and gives Combine and administrators their armour (and
-- Overwatch 150 health). Turns scanner ranks into scanners, re-ties tied players and puts worn clothes
-- back on.
-- @param player [Player The player]
-- @param lightSpawn [Boolean Whether this is a light spawn]
-- @param changeClass [Boolean Whether the player changed class]
-- @param firstSpawn [Boolean Whether this is the character's first spawn]
function Schema:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
  local clothes = player:GetCharacterData('clothes')

  if !lightSpawn then
    player:SetNetVar('antidepressants', 0)

    netstream.Start(player, 'ClearEffects', true)

    player.beingSearched = nil
    player.searching = nil

    if self:PlayerIsCombine(player) or player:GetFaction() == FACTION_ADMIN then
      if player:GetFaction() == FACTION_OTA then
        player:SetMaxHealth(150)
        player:SetMaxArmor(150)
        player:SetHealth(150)
        player:SetArmor(150)
      elseif !self:IsPlayerCombineRank(player, 'RCT') then
        player:SetArmor(100)
      else
        player:SetArmor(50)
      end
    end

    /*if (self:PlayerIsCombine(player) and player:GetAmmoCount("pistol") == 0) then
      if (!player:HasItemByID("ammo_pistol")) then
        player:GiveItem(item.CreateInstance("ammo_pistol"), true)
        player:GiveItem(item.CreateInstance("ammo_pistol"), true)
      end
    end*/
  end

  if self:IsPlayerCombineRank(player, 'SCN') then
    self:MakePlayerScanner(player, true, lightSpawn)
  else
    self:ResetPlayerScanner(player)
  end

  if player:GetNetVar('tied') != 0 then
    self:TiePlayer(player, true)
  end

  if clothes then
    local itemTable = item.FindByID(clothes)

    if itemTable and player:HasItemByID(itemTable.uniqueID) then
      self:PlayerWearClothes(player, itemTable)
    else
      player:SetCharacterData('clothes', nil)
    end
  end
end

--- Called after a player light-spawns; reapplies the clothes they wear.
-- @param player [Player The player]
-- @param weapons [Boolean Whether weapons were restored]
-- @param ammo [Boolean Whether ammunition was restored]
-- @param special [Boolean Whether this was a special light spawn]
function Schema:PostPlayerLightSpawn(player, weapons, ammo, special)
  local clothes = player:GetCharacterData('clothes')

  if clothes then
    local itemTable = item.FindByID(clothes)

    if itemTable then
      itemTable:OnChangeClothes(player, true)
    end
  end
end

--- Called when a player throws a punch; progresses their Strength.
-- @param player [Player The player]
function Schema:PlayerPunchThrown(player)
  player:ProgressAttribute(ATB_STRENGTH, 0.25, true)
end

--- Called when a player punches an entity; progresses Strength, twice as much for players and NPCs.
-- @param player [Player The player]
-- @param entity [Entity The entity]
function Schema:PlayerPunchEntity(player, entity)
  if entity:IsPlayer() or entity:IsNPC() then
    player:ProgressAttribute(ATB_STRENGTH, 1, true)
  else
    player:ProgressAttribute(ATB_STRENGTH, 0.5, true)
  end
end

--- Called when an entity has been breached.
--
-- Opens doors without a Combine lock, busting down rotating doors breached by a player. A Combine lock
-- breached by a Combine player is blown off a rotating door with a smoke charge; otherwise it flashes.
-- @param entity [Entity The breached entity]
-- @param activator [Entity Who breached it, if anyone]
function Schema:EntityBreached(entity, activator)
  if cw.entity:IsDoor(entity) then
    if !IsValid(entity.combineLock) then
      if !IsValid(activator) or string.lower(entity:GetClass()) != 'prop_door_rotating' then
        cw.entity:OpenDoor(entity, 0, true, true)
      else
        self:BustDownDoor(activator, entity)
      end
    elseif IsValid(activator) and activator:IsPlayer() and self:PlayerIsCombine(activator) then
      if string.lower(entity:GetClass()) == 'prop_door_rotating' then
        entity.combineLock:ActivateSmokeCharge((entity:GetPos() - activator:GetPos()):GetNormalized() * 10000)
      else
        entity.combineLock:SetFlashDuration(2)
      end
    else
      entity.combineLock:SetFlashDuration(2)
    end
  end
end

--- Called when a player takes damage; stuns their view, longer when they have armour.
-- @param player [Player The player]
-- @param inflictor [Entity The inflictor]
-- @param attacker [Entity The attacker]
-- @param hitGroup [Number The `HITGROUP_*` hit]
-- @param damageInfo [CTakeDamageInfo The damage]
function Schema:PlayerTakeDamage(player, inflictor, attacker, hitGroup, damageInfo)
  local curTime = CurTime()

  if player:Armor() <= 0 then
    netstream.Start(player, 'Stunned', 0.5)
  else
    netstream.Start(player, 'Stunned', 1)
  end
end

--- Called when a player's limb damage is healed; removes the limb's attribute penalties.
-- @param player [Player The player]
-- @param hitGroup [Number The `HITGROUP_*` limb]
-- @param amount [Number The amount healed]
function Schema:PlayerLimbDamageHealed(player, hitGroup, amount)
  if hitGroup == HITGROUP_HEAD then
    player:BoostAttribute('Limb Damage', ATB_MEDICAL, false)
  elseif hitGroup == HITGROUP_CHEST or hitGroup == HITGROUP_STOMACH then
    player:BoostAttribute('Limb Damage', ATB_ENDURANCE, false)
  elseif hitGroup == HITGROUP_LEFTLEG or hitGroup == HITGROUP_RIGHTLEG then
    player:BoostAttribute('Limb Damage', ATB_AGILITY, false)
  elseif hitGroup == HITGROUP_LEFTARM or hitGroup == HITGROUP_RIGHTARM then
    player:BoostAttribute('Limb Damage', ATB_AGILITY, false)
    player:BoostAttribute('Limb Damage', ATB_STRENGTH, false)
  end
end

--- Called when a player's limb damage is reset; removes every limb damage attribute penalty.
-- @param player [Player The player]
function Schema:PlayerLimbDamageReset(player)
  player:BoostAttribute('Limb Damage', nil, false)
end

--- Called when a player's limb takes damage.
--
-- Lowers the attributes the limb affects by its damage: Medical for the head, Endurance for the body,
-- Agility for the legs and Agility and Strength for the arms.
-- @param player [Player The player]
-- @param hitGroup [Number The `HITGROUP_*` limb]
-- @param damage [Number The damage taken]
function Schema:PlayerLimbTakeDamage(player, hitGroup, damage)
  local limbDamage = cw.limb:GetDamage(player, hitGroup)

  if hitGroup == HITGROUP_HEAD then
    player:BoostAttribute('Limb Damage', ATB_MEDICAL, -limbDamage)
  elseif hitGroup == HITGROUP_CHEST or hitGroup == HITGROUP_STOMACH then
    player:BoostAttribute('Limb Damage', ATB_ENDURANCE, -limbDamage)
  elseif hitGroup == HITGROUP_LEFTLEG or hitGroup == HITGROUP_RIGHTLEG then
    player:BoostAttribute('Limb Damage', ATB_AGILITY, -limbDamage)
  elseif hitGroup == HITGROUP_LEFTARM or hitGroup == HITGROUP_RIGHTARM then
    player:BoostAttribute('Limb Damage', ATB_AGILITY, -limbDamage)
    player:BoostAttribute('Limb Damage', ATB_STRENGTH, -limbDamage)
  end
end

--- Called when a player's damage should be scaled by hit group.
--
-- Scales damage by 1.5 minus up to 0.75 for Endurance, and reduces bullet damage by the `protection` of
-- the clothes the player wears.
-- @param player [Player The player]
-- @param attacker [Entity The attacker]
-- @param hitGroup [Number The `HITGROUP_*` hit]
-- @param damageInfo [CTakeDamageInfo The damage, scaled in place]
-- @param baseDamage [Number The damage before scaling]
function Schema:PlayerScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, baseDamage)
  local endurance = cw.attributes:Fraction(player, ATB_ENDURANCE, 0.75, 0.75)
  local clothes = player:GetCharacterData('clothes')

  damageInfo:ScaleDamage(1.5 - endurance)

  if damageInfo:IsBulletDamage() then
    if clothes and damageInfo:IsBulletDamage() then
      local itemTable = item.FindByID(clothes)

      if itemTable and itemTable.protection then
        damageInfo:ScaleDamage(1 - itemTable.protection)
      end
    end
  end
end

--- Called when an entity takes damage.
--
-- Progresses the victim's Endurance, plays scanner pain sounds and warns the Combine when a unit is
-- attacked. Scales damage by the attacker's weapon, melee Strength and explosions (NPC damage is
-- halved), and lets shots at the handle, shotguns and explosions open or bust down rotating doors.
-- @param entity [Entity The damaged entity]
-- @param damageInfo [CTakeDamageInfo The damage, scaled in place]
function Schema:EntityTakeDamage(entity, damageInfo)
  local player = cw.entity:GetPlayer(entity)
  local attacker = damageInfo:GetAttacker()
  local inflictor = damageInfo:GetInflictor()
  local damage = damageInfo:GetDamage()
  local curTime = CurTime()
  local doDoorDamage = nil

  if player then
    if !player.nextEnduranceTime or CurTime() > player.nextEnduranceTime then
      player:ProgressAttribute(ATB_ENDURANCE, math.Clamp(damageInfo:GetDamage(), 0, 75) / 10, true)
      player.nextEnduranceTime = CurTime() + 2
    end

    if self.scanners[player] then
      entity:EmitSound('npc/scanner/scanner_pain'..math.random(1, 2)..'.wav')

      if entity:Health() > 50 and entity:Health() - damageInfo:GetDamage() <= 50 then
        entity:EmitSound('npc/scanner/scanner_siren1.wav')
      elseif entity:Health() > 25 and entity:Health() - damageInfo:GetDamage() <= 25 then
        entity:EmitSound('npc/scanner/scanner_siren2.wav')
      end
    end

    if attacker:IsPlayer() and self:PlayerIsCombine(player) then
      if attacker != player then
        local location = Schema:PlayerGetLocation(player)

        if !player.nextUnderFire or curTime >= player.nextUnderFire then
          player.nextUnderFire = curTime + 15

          Schema:AddCombineDisplayLine(L('CombineDisplay_TraumaData'), Color(255, 255, 255, 255), nil, player)
          Schema:AddCombineDisplayLine(L('CombineDisplay_UnitTrauma', location), Color(255, 0, 0, 255), nil, player)
        end
      end
    end
  end

  if attacker:IsPlayer() then
    local strength = cw.attributes:Fraction(attacker, ATB_STRENGTH, 1, 0.5)
    local weapon = cw.player:GetWeaponClass(attacker)

    if damageInfo:IsDamageType(DMG_CLUB) or damageInfo:IsDamageType(DMG_SLASH) then
      damageInfo:ScaleDamage(1 + strength)
    end

    if weapon == 'weapon_357' then
      damageInfo:ScaleDamage(0.25)
    elseif weapon == 'weapon_crossbow' then
      damageInfo:ScaleDamage(2)
    elseif weapon == 'weapon_shotgun' then
      damageInfo:ScaleDamage(3)

      doDoorDamage = true
    elseif weapon == 'weapon_crowbar' then
      damageInfo:ScaleDamage(0.25)
    elseif weapon == 'cw_stunstick' then
      if player then
        if player:Health() <= 10 then
          damageInfo:ScaleDamage(0.5)
        end
      end
    end

    if damageInfo:IsBulletDamage() and weapon != 'weapon_shotgun' then
      if !IsValid(entity.combineLock) and !IsValid(entity.breach) then
        if string.lower(entity:GetClass()) == 'prop_door_rotating' then
          if !cw.entity:IsDoorFalse(entity) then
            local damagePosition = damageInfo:GetDamagePosition()

            if entity:WorldToLocal(damagePosition):Distance(Vector(-1.0313, 41.8047, -8.1611)) <= 8 then
              entity.doorHealth = math.max((entity.doorHealth or 50) - damageInfo:GetDamage(), 0)

              local effectData = EffectData()

              effectData:SetStart(damagePosition)
              effectData:SetOrigin(damagePosition)
              effectData:SetScale(8)

              util.Effect('GlassImpact', effectData, true, true)

              if entity.doorHealth <= 0 then
                cw.entity:OpenDoor(entity, 0, true, true, attacker:GetPos())

                entity.doorHealth = 50
              else
                timer.Create('reset_door_health_'..entity:EntIndex(), 60, 1, function()
                  if IsValid(entity) then
                    entity.doorHealth = 50
                  end
                end)
              end
            end
          end
        end
      end
    end

    if damageInfo:IsExplosionDamage() then
      damageInfo:ScaleDamage(2)
    end
  elseif attacker:IsNPC() then
    damageInfo:ScaleDamage(0.5)
  end

  if damageInfo:IsExplosionDamage() or doDoorDamage then
    if !IsValid(entity.combineLock) and !IsValid(entity.breach) then
      if string.lower(entity:GetClass()) == 'prop_door_rotating' then
        if !cw.entity:IsDoorFalse(entity) then
          if attacker:GetPos():Distance(entity:GetPos()) <= 96 then
            entity.doorHealth = math.max((entity.doorHealth or 50) - damageInfo:GetDamage(), 0)

            local damagePosition = damageInfo:GetDamagePosition()
            local effectData = EffectData()

            effectData:SetStart(damagePosition)
            effectData:SetOrigin(damagePosition)
            effectData:SetScale(8)

            util.Effect('GlassImpact', effectData, true, true)

            if entity.doorHealth <= 0 then
              self:BustDownDoor(attacker, entity)

              entity.doorHealth = 50
            else
              timer.Create('reset_door_health_'..entity:EntIndex(), 60, 1, function()
                if IsValid(entity) then
                  entity.doorHealth = 50
                end
              end)
            end
          end
        end
      end
    end
  end
end

do
  local ccaSounds = {
    [1] = {
      'npc/metropolice/gear1.wav',
      'npc/metropolice/gear3.wav',
      'npc/metropolice/gear5.wav'
    },
    [2] = {
      'npc/metropolice/gear2.wav',
      'npc/metropolice/gear4.wav',
      'npc/metropolice/gear6.wav'
    }
  }

  local otaSounds = {
    [1] = {
      'npc/combine_soldier/gear1.wav',
      'npc/combine_soldier/gear3.wav',
      'npc/combine_soldier/gear5.wav'
    },
    [2] = {
      'npc/combine_soldier/gear2.wav',
      'npc/combine_soldier/gear4.wav',
      'npc/combine_soldier/gear6.wav'
    }
  }

  --- Called when a player's footstep sound should be played.
  --
  -- Running Civil Protection and Overwatch players play gear sounds; everyone else plays the normal sound.
  -- @param player [Player The player]
  -- @param position [Vector The footstep position]
  -- @param foot [Number `0` for the left foot, `1` for the right]
  -- @param sound [String The default sound]
  -- @param volume [Number The default volume]
  -- @param recipientFilter [CRecipientFilter Who would hear the sound]
  -- @return [Boolean Always `true`, replacing the engine's sound]
  function Schema:PlayerFootstep(player, position, foot, sound, volume, recipientFilter)
    if player:IsRunning() then
      local faction = player:GetFaction()

      if faction == FACTION_MPF then
        player:EmitSound(table.Random(ccaSounds[foot + 1]), volume * 130)

        return true
      elseif faction == FACTION_OTA then
        player:EmitSound(table.Random(otaSounds[foot + 1]), volume * 100)

        return true
      end
    end

    player:EmitSound(sound)

    return true
  end
end
