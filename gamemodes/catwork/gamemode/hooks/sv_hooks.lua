--- Server-side gamemode hooks of the Catwork framework, defined on `GM`.
--
-- Covers start-up and the database connection (`Initialize`, `ClockworkInitialized`), the player lifecycle
-- (`PlayerInitialSpawn`, `PlayerSpawn`, `PlayerCharacterLoaded`, `PlayerDeath`), the `Tick`-driven `PlayerThink`
-- and `OnePlayerSecond`, the timer-driven `OneSecond`, damage (`EntityTakeDamage`), saving, Sandbox spawning, tool
-- and physgun permissions and `EntityHandleMenuOption`. Most of the rest is the default implementation of the
-- framework's own `PlayerCan*` and `PlayerAdjust*` hooks, which schemas and plugins override.

DEFINE_BASECLASS('gamemode_base')

-- Dispositions for the values of a faction's `entRelationship` table.
local relationTypes = {
  like = D_LI,
  fear = D_FR,
  hate = D_HT
}

-- What NPC classes thought of each player before a faction relationship was applied, by Steam ID and class.
local prevRelation

--- Called when the server has initialized.
--
-- Initializes the item system, imports `gamemodes/catwork/clockwork.cfg`, connects to the
-- database (SQLite when `mysql_host` is empty, `sqlite` or a placeholder, MySQLOO otherwise),
-- restores or derives the in-game date and time (from the machine clock when
-- `use_local_machine_date`/`use_local_machine_time` are set) and creates the `cwLog` ConVar.
-- Finally runs `ClockworkConfigInitialized` for every config key and then `ClockworkInitialized`.
function GM:Initialize()
  item.Initialize()
  config.Import('gamemodes/catwork/clockwork.cfg')

  local useLocalMachineDate = config.GetVal('use_local_machine_date')
  local useLocalMachineTime = config.GetVal('use_local_machine_time')
  local defaultDate = cw.option:GetKey('default_date')
  local defaultTime = cw.option:GetKey('default_time')
  local defaultDays = cw.option:GetKey('default_days')
  local username = config.GetVal('mysql_username')
  local password = config.GetVal('mysql_password')
  local database = config.GetVal('mysql_database')
  local dateInfo = os.date('*t')
  -- Matches at beginning of string, matches http:// or https://, no need to check twice
  local host = string.gsub(config.GetVal('mysql_host') or '', '^http[s]?://', '', 1)
  local port = config.GetVal('mysql_port')

  cw.database.Module = 'mysqloo'

  if host == '' or host == ' ' or host == 'example.com' or host == 'sqlite' or host == 'example' then
    cw.database.Module = 'sqlite'
  end

  cw.database:Connect(host, username, password, database, port)

  if useLocalMachineTime then
    config.Get('minute_time'):Set(60)
  end

  config.SetInitialized(true)

  table.Merge(cw.time, defaultTime)
  table.Merge(cw.date, defaultDate)
  math.randomseed(os.time())

  if useLocalMachineTime then
    local realDay = dateInfo.wday - 1

    if realDay == 0 then
      realDay = #defaultDays
    end

    table.Merge(cw.time, {
      minute = dateInfo.min,
      hour = dateInfo.hour,
      day = realDay
    })

    cw.NextDateTimeThink = SysTime() + (60 - dateInfo.sec)
  else
    table.Merge(cw.time, cw.core:RestoreSchemaData('time'))
  end

  if useLocalMachineDate then
    dateInfo.year = dateInfo.year + (defaultDate.year - dateInfo.year)

    table.Merge(cw.date, {
      month = dateInfo.month,
      year = dateInfo.year,
      day = dateInfo.day
    })
  else
    table.Merge(cw.date, cw.core:RestoreSchemaData('date'))
  end

  CW_CONVAR_LOG = cw.core:CreateConVar('cwLog', 1)

  for k, v in pairs(config.stored) do
    hook.Run('ClockworkConfigInitialized', k, v.value)
  end

  hook.Run('ClockworkInitialized')
end

timer.Create('CW:PlayerWaterChecker', 1, 0, function()
  local curTime = CurTime()

  for k, v in ipairs(_player.GetAll()) do
    if v.submerged and v:HasInitialized() and v:Alive() then
      local stamina = v:GetCharacterData('Stamina')

      -- Stamina is character data of the stamina plugin; without it nobody runs out of breath.
      if stamina then
        if curTime - (v.waterStartTime or curTime) > 5 then
          stamina = math.Clamp(stamina - 6, 0, 100)

          v:SetCharacterData('Stamina', stamina)
        end

        if stamina <= 0 then
          v:TakeDamage(7)
        end
      end
    end
  end
end)

--- Called about once a second for every initialized player, after `GM:PlayerThink`.
--
-- Handles attribute progress and boosts, networks the player's flags, model, name, cash and
-- drunk level, networks or removes clothes, runs `PlayerHealthRegenerate` when health
-- regeneration is enabled and `PlayerShouldHealthRegenerate` allows it and expires drunk
-- entries. When cash is disabled it zeroes the character's cash and wages.
-- @param player [Player The player being updated]
-- @param curTime [Number The current `CurTime()`]
-- @param infoTable [Map The player's per-think info table (`player.cwInfoTable`); fields such as
-- `wages`, `runSpeed` and `inventoryWeight` can be changed to affect the player]
function GM:OnePlayerSecond(player, curTime, infoTable)
  local color = player:GetColor()

  player:HandleAttributeProgress(curTime)
  player:HandleAttributeBoosts(curTime)

  player:SetDTString(STRING_FLAGS, player:GetFlags())
  player:SetNetVar('Model', player:GetDefaultModel())
  player:SetDTString(STRING_NAME, player:Name())
  player:SetNetVar('Cash', player:GetCash())

  local clothesItem = player:IsWearingClothes()

  if clothesItem then
    player:NetworkClothesData()
  else
    player:RemoveClothes()
  end

  if config.GetVal('health_regeneration_enabled') and hook.Run('PlayerShouldHealthRegenerate', player) then
    hook.Run('PlayerHealthRegenerate', player, player:Health(), player:GetMaxHealth())
  end

  if color.r == 255 and color.g == 0 and color.b == 0 and color.a == 0 then
    player:SetColor(Color(255, 255, 255, 255))
  end

  local drunkTab = player.cwDrunkTab

  if drunkTab then
    for i = #drunkTab, 1, -1 do
      if curTime >= drunkTab[i] then
        table.remove(drunkTab, i)
      end
    end
  end

  player:SetNetVar('IsDrunk', cw.player:GetDrunk(player) or 0)

  if !config.GetVal('cash_enabled') then
    player:SetCharacterData('Cash', 0, true)
    infoTable.wages = 0
  end
end

--- Called every 0.15 seconds for every initialized player.
--
-- `GM:Tick` resets `infoTable` to the defaults before calling this, so plugins can adjust it
-- here. Catwork tracks how long the player has been underwater, keeps ragdolled players in
-- observer movement, closes storage when `PlayerStorageShouldClose` says so, networks inventory
-- weight, space and wages, slows the player for leg damage and when walking backwards, updates
-- weapon raising and saves the active weapon item's clip ammo.
-- @param player [Player The player being updated]
-- @param curTime [Number The current `CurTime()`]
-- @param infoTable [Map The player's info table with `inventoryWeight`, `inventorySpace`,
-- `crouchedSpeed`, `jumpPower`, `walkSpeed`, `runSpeed`, `isRunning`, `isJumping` and `wages`]
function GM:PlayerThink(player, curTime, infoTable)
  if player:WaterLevel() >= 3 then
    player.submerged = true
    player.waterStartTime = player.waterStartTime or curTime
  else
    player.submerged = false
    player.waterStartTime = nil
  end

  if player:IsRagdolled() then
    player:SetMoveType(MOVETYPE_OBSERVER)
  end

  local storageTable = player:GetStorageTable()

  if storageTable and hook.Run('PlayerStorageShouldClose', player, storageTable) then
    cw.storage:Close(player)
  end

  player:SetNetVar('InvWeight', math.ceil(infoTable.inventoryWeight))
  player:SetNetVar('InvSpace', math.ceil(infoTable.inventorySpace))
  player:SetNetVar('Wages', math.ceil(infoTable.wages))

  if cw.event:CanRun('limb_damage', 'disability') then
    local leftLeg = cw.limb:GetDamage(player, HITGROUP_LEFTLEG, true)
    local rightLeg = cw.limb:GetDamage(player, HITGROUP_RIGHTLEG, true)
    local legDamage = math.max(leftLeg, rightLeg)

    -- looks like infoTable is necessary here for correct function. ayy...
    if legDamage > 0 then
      player:SetJumpPower(infoTable.jumpPower / (1 + legDamage), true)
      player:SetRunSpeed(infoTable.runSpeed / (1 + legDamage), true)
    else
      player:SetJumpPower(infoTable.jumpPower, true)
      player:SetRunSpeed(infoTable.runSpeed, true)
    end
  end

  if player:KeyDown(IN_BACK) then
    player:SetRunSpeed(player:GetRunSpeed() * 0.5, true)
  end

  if player:GetRunSpeed() < player:GetWalkSpeed() then
    player:SetRunSpeed(player:GetWalkSpeed(), true)
  end

  --[[ Update whether the weapon has fired, or is being raised. --]]
  player:UpdateWeaponFired()
  player:SetDTBool(BOOL_ISRUNNING, infoTable.isRunning)

  local activeWeapon = player:GetActiveWeapon()
  local weaponItemTable = item.GetByWeapon(activeWeapon)

  if weaponItemTable and weaponItemTable:IsInstance() then
    local clipOne = activeWeapon:Clip1()
    local clipTwo = activeWeapon:Clip2()

    if clipOne >= 0 then
      weaponItemTable:SetData('ClipOne', clipOne)
    end

    if clipTwo >= 0 then
      weaponItemTable:SetData('ClipTwo', clipTwo)
    end
  end
end

--- Called when a player has disconnected.
--
-- For initialized players, saves the character unless `PlayerCharacterUnloaded` returns `true`,
-- then logs the disconnect and announces it in the chatbox.
-- @param player [Player The player who disconnected]
function GM:PlayerDisconnected(player)
  if IsValid(player) and player:HasInitialized() then
    if hook.Run('PlayerCharacterUnloaded', player) != true then
      player:SaveCharacter()
    end

    cw.core:PrintLog(
      LOGTYPE_MINOR,
      player:Name()..' ('..player:SteamID()..' / '..player:IPAddress()..') has disconnected.'
    )
    chatbox.AddText(nil, player:SteamName()..L'PlayerDisconnected', {
      filter = 'events',
      icon = 'icon16/user_delete.png',
      textColor = Color(180, 80, 150)
    })
  end
end

--- Called when Catwork has initialized, at the end of `GM:Initialize`.
--
-- Hides the cash commands and zeroes prop and door costs when cash is disabled, hides the group
-- commands when `use_own_group_system` is set, adds the gradient, schema logo and intro image
-- materials to the download list, registers Catwork tools with `gmod_tool` and sets `sv_maxrate`
-- to 80000.
function GM:ClockworkInitialized()
  RunConsoleCommand('sv_maxrate', '80000')

  if !config.GetVal('cash_enabled') then
    cw.command:SetHidden('GiveCash', true)
    cw.command:SetHidden('DropCash', true)
    cw.command:SetHidden('StorageTakeCash', true)
    cw.command:SetHidden('StorageGiveCash', true)

    config.Get('scale_prop_cost'):Set(0, nil, true, true)
    config.Get('door_cost'):Set(0, nil, true, true)
  end

  if config.GetVal('use_own_group_system') then
    cw.command:SetHidden('PlySetGroup', true)
    cw.command:SetHidden('PlyDemote', true)
  end

  local gradientTexture = cw.option:GetKey('gradient')
  local schemaLogo = cw.option:GetKey('schema_logo')
  local introImage = cw.option:GetKey('intro_image')

  if gradientTexture != 'gui/gradient_up' then
    cw.core:AddFile('materials/'..gradientTexture..'.png')
  end

  if schemaLogo != '' then
    cw.core:AddFile('materials/'..schemaLogo..'.png')
  end

  if introImage != '' then
    cw.core:AddFile('materials/'..introImage..'.png')
  end

  for k, v in pairs(cw.tool:GetAll()) do
    weapons.GetStored('gmod_tool').Tool[v.Mode] = v
  end
end

--- Called when the Catwork database has connected; loads the ban list with `cw.bans:Load`.
function GM:DatabaseConnected()
  cw.bans:Load()
end

--- Called when the Catwork database connection fails; reports it with `cw.database:Error`.
-- @param errText [String The error message from the database module]
function GM:DatabaseConnectionFailed(errText)
  cw.database:Error(errText)
end

--- Called after a player's model has changed; updates the player's hands model to match.
--
-- This server-side definition replaces the shared `GM:PlayerModelChanged` from `sh_hooks.lua`.
-- @param player [Player The player whose model changed]
-- @param model [String Path of the new model]
function GM:PlayerModelChanged(player, model)
  local hands = player:GetHands()

  if IsValid(hands) then
    self:PlayerSetHandsModel(player, hands)
  end
end

--- Called when a player's inventory is being saved, to add items that are not in it.
--
-- Catwork adds the item of every weapon the player is holding, so equipped weapons are saved.
-- @param player [Player The player whose inventory is saved]
-- @param character [Character The character being saved]
-- @param Callback [Function Call with an `Item` to add it to the saved inventory]
function GM:PlayerAddToSavedInventory(player, character, Callback)
  for k, v in pairs(player:GetWeapons()) do
    local weaponItemTable = item.GetByWeapon(v)

    if weaponItemTable then
      Callback(weaponItemTable)
    end
  end
end

--- Called when a player tries to unlock an entity with the keys, to get how it is unlocked.
--
-- For doors the time is the `unlock_time` config, multiplied by `1 + arm damage` when limb
-- damage is enabled, and the callback fires the door's `unlock` input.
-- @param player [Player The player unlocking]
-- @param entity [Entity The entity being unlocked]
-- @return [Map `duration` in seconds and `Callback(player, entity)` run when it finishes, or `nil`
-- if the entity cannot be unlocked]
function GM:PlayerGetUnlockInfo(player, entity)
  if cw.entity:IsDoor(entity) then
    local unlockTime = config.GetVal('unlock_time')

    if cw.event:CanRun('limb_damage', 'unlock_time') then
      local leftArm = cw.limb:GetDamage(player, HITGROUP_LEFTARM, true)
      local rightArm = cw.limb:GetDamage(player, HITGROUP_RIGHTARM, true)
      local armDamage = math.max(leftArm, rightArm)

      if armDamage > 0 then
        unlockTime = unlockTime * (1 + armDamage)
      end
    end

    return {
      duration = unlockTime,
      Callback = function(player, entity)
        entity:Fire('unlock', '', 0)
      end
    }
  end
end

--- Called when a player tries to lock an entity with the keys, to get how it is locked.
--
-- For doors the time is the `lock_time` config, multiplied by `1 + arm damage` when limb damage
-- is enabled, and the callback fires the door's `lock` input.
-- @param player [Player The player locking]
-- @param entity [Entity The entity being locked]
-- @return [Map `duration` in seconds and `Callback(player, entity)` run when it finishes, or `nil`
-- if the entity cannot be locked]
function GM:PlayerGetLockInfo(player, entity)
  if cw.entity:IsDoor(entity) then
    local lockTime = config.GetVal('lock_time')

    if cw.event:CanRun('limb_damage', 'lock_time') then
      local leftArm = cw.limb:GetDamage(player, HITGROUP_LEFTARM, true)
      local rightArm = cw.limb:GetDamage(player, HITGROUP_RIGHTARM, true)
      local armDamage = math.max(leftArm, rightArm)

      if armDamage > 0 then
        lockTime = lockTime * (1 + armDamage)
      end
    end

    return {
      duration = lockTime,
      Callback = function(player, entity)
        entity:Fire('lock', '', 0)
      end
    }
  end
end

do
  local meleeWeapons = {
    ['weapon_hl2axe'] = 10,
    ['weapon_hl2bottle'] = 5,
    ['weapon_hl2brokenbottle'] = 5,
    ['weapon_hl2hook'] = 15,
    ['weapon_knife'] = 5,
    ['weapon_hl2pan'] = 10,
    ['weapon_hl2pickaxe'] = 15,
    ['weapon_hl2pipe'] = 10,
    ['weapon_hl2pot'] = 10,
    ['weapon_hl2shovel'] = 15
  }

  --- Called to check whether a player can fire their weapon; returning `false` delays the shot.
  --
  -- Catwork blocks firing when the player lacks the stamina a melee weapon needs, is sprinting with
  -- `sprint_lowers_weapon` set, holds the weapon lowered and `PlayerCanUseLoweredWeapon` refuses,
  -- or is still on `player.cwNextShootTime`. With limb damage enabled, arm damage randomly stops
  -- the player from firing for a while.
  -- @param player [Player The player firing]
  -- @param bIsRaised [Boolean Whether the weapon is raised]
  -- @param weapon [Weapon The weapon being fired]
  -- @param bIsSecondary=nil [Boolean Whether this is the secondary attack]
  -- @return [Boolean Whether the weapon can fire]
  function GM:PlayerCanFireWeapon(player, bIsRaised, weapon, bIsSecondary)
    local canShootTime = player.cwNextShootTime
    local curTime = CurTime()
    local weaponClass = weapon:GetClass()

    if meleeWeapons[weaponClass] then
      if player:GetCharacterData('Stamina') < meleeWeapons[weaponClass] then
        return false
      end
    end

    if player:IsRunning() and config.GetVal('sprint_lowers_weapon') then
      return false
    end

    if !bIsRaised and !hook.Run('PlayerCanUseLoweredWeapon', player, weapon, bIsSecondary) then
      return false
    end

    if canShootTime and canShootTime > curTime then
      return false
    end

    if cw.event:CanRun('limb_damage', 'weapon_fire') then
      local leftArm = cw.limb:GetDamage(player, HITGROUP_LEFTARM, true)
      local rightArm = cw.limb:GetDamage(player, HITGROUP_RIGHTARM, true)
      local armDamage = math.max(leftArm, rightArm)

      if armDamage == 0 then return true end

      if player.cwArmDamageNoFire then
        if curTime >= player.cwArmDamageNoFire then
          player.cwArmDamageNoFire = nil
        end

        return false
      else
        if !player.cwNextArmDamage then
          player.cwNextArmDamage = curTime + (1 - (armDamage * 0.5))
        end

        if curTime >= player.cwNextArmDamage then
          player.cwNextArmDamage = nil

          if math.random() <= armDamage * 0.75 then
            player.cwArmDamageNoFire = curTime + (1 + (armDamage * 2))
          end
        end
      end
    end

    return true
  end
end

--- Called to check whether a player can fire a weapon while it is lowered.
--
-- Allowed when the weapon, or its `Primary`/`Secondary` table, has `NeverRaised` set.
-- @param player [Player The player firing]
-- @param weapon [Weapon The lowered weapon]
-- @param secondary [Boolean Whether this is the secondary attack]
-- @return [Boolean Whether the lowered weapon can fire]
function GM:PlayerCanUseLoweredWeapon(player, weapon, secondary)
  if secondary then
    return weapon.NeverRaised or (weapon.Secondary and weapon.Secondary.NeverRaised)
  else
    return weapon.NeverRaised or (weapon.Primary and weapon.Primary.NeverRaised)
  end
end

--- Called when a player has been given flags.
--
-- Gives the physgun for `p` and the toolgun for `t` if the player is alive, and networks the
-- player's flags.
-- @param player [Player The player given the flags]
-- @param flags [String The flags that were given]
function GM:PlayerFlagsGiven(player, flags)
  if string.find(flags, 'p') and player:Alive() then
    cw.player:GiveSpawnWeapon(player, 'weapon_physgun')
  end

  if string.find(flags, 't') and player:Alive() then
    cw.player:GiveSpawnWeapon(player, 'gmod_tool')
  end

  player:SetDTString(STRING_FLAGS, player:GetFlags())
end

--- Called when a player has had flags taken.
--
-- Takes the physgun for `p` and the toolgun for `t` unless the player still has the flag (for
-- example from the default flags), and networks the player's flags.
-- @param player [Player The player whose flags were taken]
-- @param flags [String The flags that were taken]
function GM:PlayerFlagsTaken(player, flags)
  if string.find(flags, 'p') and player:Alive() then
    if !cw.player:HasFlags(player, 'p') then
      cw.player:TakeSpawnWeapon(player, 'weapon_physgun')
    end
  end

  if string.find(flags, 't') and player:Alive() then
    if !cw.player:HasFlags(player, 't') then
      cw.player:TakeSpawnWeapon(player, 'gmod_tool')
    end
  end

  player:SetDTString(STRING_FLAGS, player:GetFlags())
end

--- Called to get a player's default skin, from `cw.class:GetAppropriateModel` for their team.
-- @param player [Player The player to get the skin for]
-- @return [Number The default skin]
function GM:GetPlayerDefaultSkin(player)
  local model, skin = cw.class:GetAppropriateModel(player:Team(), player)
  return skin
end

--- Called to get a player's default model, from `cw.class:GetAppropriateModel` for their team.
-- @param player [Player The player to get the model for]
-- @return [String The default model path]
function GM:GetPlayerDefaultModel(player)
  local model, skin = cw.class:GetAppropriateModel(player:Team(), player)
  return model
end

--- Called to fill a new character's starting inventory.
--
-- Adds the items in the character's faction `startingInv` table (`{ [uniqueID] = amount }`).
-- @param player [Player The player creating the character]
-- @param character [Character The character being created]
-- @param inventory [Inventory The inventory to add items to]
function GM:GetPlayerDefaultInventory(player, character, inventory)
  local factionTable = faction.FindByID(character.faction)
  local startingInv = factionTable and factionTable.startingInv

  if istable(startingInv) then
    for k, v in pairs(startingInv) do
      cw.inventory:AddInstance(
        inventory, item.CreateInstance(k), v
      )
    end
  end
end

--- Called to get whether a player's weapon is raised.
--
-- Default weapons and zoomed or scoped weapons are always raised and sprinting lowers weapons
-- when `sprint_lowers_weapon` is set. With `raised_weapon_system` enabled, a weapon is only
-- raised if the player raised it (`player.cwWeaponRaiseClass`) or it was raised automatically
-- (`player.cwAutoWepRaised`); otherwise every weapon is raised.
-- @param player [Player The player holding the weapon]
-- @param class [String The weapon's class]
-- @param weapon [Weapon The weapon]
-- @return [Boolean Whether the weapon is raised]
function GM:GetPlayerWeaponRaised(player, class, weapon)
  if cw.core:IsDefaultWeapon(weapon) then
    return true
  end

  if player:IsRunning() and config.GetVal('sprint_lowers_weapon') then
    return false
  end

  if weapon:GetNWInt('Zoom') != 0 then
    return true
  end

  if weapon:GetNWBool('Scope') then
    return true
  end

  if config.GetVal('raised_weapon_system') then
    if player.cwWeaponRaiseClass == class then
      return true
    else
      player.cwWeaponRaiseClass = nil
    end

    if player.cwAutoWepRaised == class then
      return true
    else
      player.cwAutoWepRaised = nil
    end

    return false
  end

  return true
end

--- Called to check whether a player can put an item in storage.
--
-- Catwork always allows it and tags the item with the character's key and unique ID so other
-- characters cannot take it back out.
-- @param player [Player The player storing the item]
-- @param storageTable [Map The open storage]
-- @param itemTable [Item The item being stored]
-- @return [Boolean Return `false` to block storing the item]
function GM:PlayerCanGiveToStorage(player, storageTable, itemTable)
  itemTable.cwPropertyTab = itemTable.cwPropertyTab or {}
  itemTable.cwPropertyTab.key = player:GetCharacterKey()
  itemTable.cwPropertyTab.uniqueID = player:UniqueID()

  return true
end

--- Called to check whether a player can take an item out of storage.
--
-- Refuses, with a notification and a log entry, when the item was stored by another character
-- (see `cw.entity:BelongsToAnotherCharacter`); otherwise clears the item's owner tag.
-- @param player [Player The player taking the item]
-- @param storageTable [Map The open storage]
-- @param itemTable [Item The item being taken]
-- @return [Boolean Whether the item can be taken]
function GM:PlayerCanTakeFromStorage(player, storageTable, itemTable)
  if itemTable.cwPropertyTab then
    if cw.entity:BelongsToAnotherCharacter(player, itemTable) then
      cw.player:Notify(player, L'CantTakeOthersCharactersItems')
      cw.core:PrintLog(LOGTYPE_MAJOR, player:Name()..' has attempted to take an item stored by another character.')

      return false
    else
      itemTable.cwPropertyTab = nil
    end
  end

  return true
end

--- Called after a player has put an item in storage; takes it off if it was worn as clothes or an accessory.
-- @param player [Player The player who stored the item]
-- @param storageTable [Map The open storage]
-- @param itemTable [Item The stored item]
function GM:PlayerGiveToStorage(player, storageTable, itemTable)
  if player:IsWearingItem(itemTable) then
    player:RemoveClothes()
  end

  if player:IsWearingAccessory(itemTable) then
    player:RemoveAccessory(itemTable)
  end
end

--- Called after a player is given an item; syncs it with their open storage via `cw.storage:SyncItem`.
-- @param player [Player The player given the item]
-- @param itemTable [Item The item given]
-- @param bForce [Boolean Whether the item was forced into the inventory regardless of weight]
function GM:PlayerItemGiven(player, itemTable, bForce)
  cw.storage:SyncItem(player, itemTable)
end

--- Called after a player has an item taken.
--
-- Syncs the item with their open storage and takes it off if it was worn as clothes or an
-- accessory.
-- @param player [Player The player the item was taken from]
-- @param itemTable [Item The item taken]
function GM:PlayerItemTaken(player, itemTable)
  cw.storage:SyncItem(player, itemTable)

  if player:IsWearingItem(itemTable) then
    player:RemoveClothes()
  end

  if player:IsWearingAccessory(itemTable) then
    player:RemoveAccessory(itemTable)
  end
end

--- Called after a player's cash has changed; syncs it with their open storage via `cw.storage:SyncCash`.
-- @param player [Player The player whose cash changed]
-- @param amount [Number The amount given (negative when taken)]
-- @param reason [String Why the cash changed, or `nil`]
-- @param bNoMsg [Boolean Whether the change should be silent]
function GM:PlayerCashUpdated(player, amount, reason, bNoMsg)
  cw.storage:SyncCash(player)
end

--- Called to scale damage a player takes by hit group.
--
-- Catwork cuts damage from vehicles and from players in vehicles to a quarter.
-- @param player [Player The player taking damage]
-- @param attacker [Entity The attacker]
-- @param hitGroup [Number The hit group (`HITGROUP_*`)]
-- @param damageInfo [CTakeDamageInfo The damage to scale in place]
-- @param baseDamage [Number The damage before scaling]
function GM:PlayerScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, baseDamage)
  if attacker:IsVehicle() or (attacker:IsPlayer() and attacker:InVehicle()) then
    damageInfo:ScaleDamage(0.25)
  end
end

--- Called when a player switches their flashlight on or off; ragdolled players cannot turn it on.
-- @param player [Player The player toggling the flashlight]
-- @param bIsOn [Boolean Whether the flashlight is being turned on]
-- @return [Boolean Whether the switch is allowed]
function GM:PlayerSwitchFlashlight(player, bIsOn)
  if player:HasInitialized() and bIsOn
  and player:IsRagdolled() then
    return false
  end

  return true
end

--- Called for each config key once the config has initialized, from `GM:Initialize`.
--
-- Zeroes every item's cost when `cash_enabled` is off and turns off `sv_alltalk` when
-- `local_voice` is on.
-- @param key [String The config key]
-- @param value [Any The config value]
function GM:ClockworkConfigInitialized(key, value)
  if key == 'cash_enabled' and !value then
    for k, v in pairs(item.GetAll()) do
      v.cost = 0
    end
  elseif key == 'local_voice' then
    if value then
      RunConsoleCommand('sv_alltalk', '0')
    end
  end
end

--- Called when a ConVar created with `cw.core:CreateConVar` has changed.
--
-- Sets `sv_alltalk` to 1 when the changed ConVar is `local_voice` and the new value is truthy.
-- @param name [String The ConVar name]
-- @param previousValue [String The previous value]
-- @param newValue [String The new value]
function GM:ClockworkConVarChanged(name, previousValue, newValue)
  if name == 'local_voice' and newValue then
    RunConsoleCommand('sv_alltalk', '1')
  end
end

--- Called when a config value has changed.
--
-- Applies the change to connected players: gives or takes the physgun and toolgun when the
-- `p`/`t` default flags change, shows or hides the group commands for `use_own_group_system`,
-- resets OOC cooldowns for `ooc_interval` and updates movement for `crouched_speed`,
-- `jump_power`, `walk_speed` and `run_speed`.
-- @param key [String The config key]
-- @param data [Map The config entry]
-- @param previousValue [Any The previous value]
-- @param newValue [Any The new value]
function GM:ClockworkConfigChanged(key, data, previousValue, newValue)
  local plyTable = _player.GetAll()

  if key == 'default_flags' then
    for k, v in ipairs(plyTable) do
      if v:HasInitialized() and v:Alive() then
        if string.find(previousValue, 'p') then
          if !string.find(newValue, 'p') then
            if !cw.player:HasFlags(v, 'p') then
              cw.player:TakeSpawnWeapon(v, 'weapon_physgun')
            end
          end
        elseif !string.find(previousValue, 'p') then
          if string.find(newValue, 'p') then
            cw.player:GiveSpawnWeapon(v, 'weapon_physgun')
          end
        end

        if string.find(previousValue, 't') then
          if !string.find(newValue, 't') then
            if !cw.player:HasFlags(v, 't') then
              cw.player:TakeSpawnWeapon(v, 'gmod_tool')
            end
          end
        elseif !string.find(previousValue, 't') then
          if string.find(newValue, 't') then
            cw.player:GiveSpawnWeapon(v, 'gmod_tool')
          end
        end
      end
    end
  elseif key == 'use_own_group_system' then
    if newValue then
      cw.command:SetHidden('PlySetGroup', true)
      cw.command:SetHidden('PlyDemote', true)
    else
      cw.command:SetHidden('PlySetGroup', false)
      cw.command:SetHidden('PlyDemote', false)
    end
  elseif key == 'crouched_speed' then
    for k, v in ipairs(plyTable) do
      v:SetCrouchedWalkSpeed(newValue / math.max(config.GetVal('walk_speed'), 1))
    end
  elseif key == 'ooc_interval' then
    for k, v in ipairs(plyTable) do
      v.cwNextTalkOOC = nil
    end
  elseif key == 'jump_power' then
    for k, v in ipairs(plyTable) do
      v:SetJumpPower(newValue)
    end
  elseif key == 'walk_speed' then
    for k, v in ipairs(plyTable) do
      v:SetCrouchedWalkSpeed(config.GetVal('crouched_speed') / math.max(newValue, 1))
      v:SetWalkSpeed(newValue)
      v:SetSlowWalkSpeed(newValue)
    end
  elseif key == 'run_speed' then
    for k, v in ipairs(plyTable) do
      v:SetRunSpeed(newValue)
    end
  end
end

--- Called when a player attempts to spray their tag.
--
-- Dead and ragdolled players cannot spray; otherwise the `disable_sprays` config decides, unless
-- the `config`/`player_spray` event is disabled.
-- @param player [Player The player spraying]
-- @return [Boolean `true` to block the spray]
function GM:PlayerSpray(player)
  if !player:Alive() or player:IsRagdolled() then
    return true
  elseif cw.event:CanRun('config', 'player_spray') then
    return config.GetVal('disable_sprays')
  end
end

--- Called when a player attempts to use an entity; players who have fallen over cannot use anything.
-- @param player [Player The player using the entity]
-- @param entity [Entity The entity being used]
-- @return [Boolean Whether the use is allowed]
function GM:PlayerUse(player, entity)
  if player:IsRagdolled(RAGDOLL_FALLENOVER) then
    return false
  else
    return true
  end
end

--- Called when a player's move data is set up; overridden to do nothing.
-- @param player [Player The player moving]
-- @param moveData [CMoveData The move data]
function GM:SetupMove(player, moveData) end

--- Called to check whether a recognised name may be saved with the character.
--
-- Only asked when `save_recognised_names` is enabled and a player recognises someone with
-- `RECOGNISE_SAVE`; when it does not return `true` the recognition only lasts for the session
-- (`RECOGNISE_TOTAL`). Catwork allows it for anyone but the player themselves.
-- @param player [Player The player recognising]
-- @param target [Player The player being recognised]
-- @return [Boolean `true` to save the name]
function GM:PlayerCanSaveRecognisedName(player, target)
  if player != target then return true end
end

--- Called to check whether a saved recognised name is restored when both players are on.
--
-- When it does not return `true` the saved name is forgotten. Catwork allows it for anyone but
-- the player themselves.
-- @param player [Player The player who recognised the target]
-- @param target [Player The player who was recognised]
-- @return [Boolean `true` to restore the name]
function GM:PlayerCanRestoreRecognisedName(player, target)
  if player != target then return true end
end

--- Called when a player attempts to order an item shipment; refuses while `player.cwNextOrderTime` has not passed.
-- @param player [Player The player ordering]
-- @param itemTable [Item The item being ordered]
-- @return [Boolean Whether the order is allowed]
function GM:PlayerCanOrderShipment(player, itemTable)
  local curTime = CurTime()

  if player.cwNextOrderTime and curTime < player.cwNextOrderTime then
    return false
  end

  return true
end

--- Called when a player who has fallen over attempts to get up with `/CharGetUp`; always allows it.
--
-- On the client it is called without a player to decide whether to show the get up hint.
-- @param player [Player The player getting up]
-- @return [Boolean Whether the player can get up]
function GM:PlayerCanGetUp(player) return true end

--- Called when a player attempts to throw a punch with `cw_hands`; always allows it.
-- @param player [Player The player punching]
-- @return [Boolean Whether the punch is thrown]
function GM:PlayerCanThrowPunch(player) return true end

--- Called when a punch with `cw_hands` hits an entity, to check whether it damages it; never does by default.
-- @param player [Player The player punching]
-- @param entity [Entity The entity hit]
-- @return [Boolean Whether the punch damages the entity]
function GM:PlayerCanPunchEntity(player, entity) return false end

--- Called when a punch with `cw_hands` hits a player, to check whether it knocks them out.
--
-- Catwork allows it on head hits. A knockout ragdolls the target for 15 seconds and runs
-- `PlayerPunchKnockout`.
-- @param player [Player The player punching]
-- @param target [Player The player hit]
-- @param trace [Map The punch trace result]
-- @return [Boolean `true` to knock the target out]
function GM:PlayerCanPunchKnockout(player, target, trace)
  if trace.HitGroup == HITGROUP_HEAD then
    return true
  end
end

--- Called to check whether a player can use a character in a faction that is at its player limit; never by default.
-- @param player [Player The player choosing the character]
-- @param character [Character The character being used]
-- @return [Boolean `true` to ignore the faction limit]
function GM:PlayerCanBypassFactionLimit(player, character) return false end

--- Called to check whether a player can join a class that is at its player limit; never by default.
-- @param player [Player The player joining]
-- @param class [Number The class index]
-- @return [Boolean `true` to ignore the class limit]
function GM:PlayerCanBypassClassLimit(player, class) return false end

--- Called to choose the pain sound a player makes when hurt.
--
-- Half of bullet hits play a hit group specific HL2 citizen line (head, gut, leg, arm, gear);
-- everything else plays a random `pain` line.
-- @param player [Player The hurt player]
-- @param gender [String The player's gender, `male` or `female`]
-- @param damageInfo [CTakeDamageInfo The damage taken]
-- @param hitGroup [Number The hit group (`HITGROUP_*`)]
-- @return [String The sound path, or `nil` for no sound]
function GM:PlayerPlayPainSound(player, gender, damageInfo, hitGroup)
  if damageInfo:IsBulletDamage() and math.random() <= 0.5 then
    if hitGroup == HITGROUP_HEAD then
      return 'vo/npc/'..gender..'01/ow0'..math.random(1, 2)..'.wav'
    elseif hitGroup == HITGROUP_CHEST or hitGroup == HITGROUP_GENERIC then
      return 'vo/npc/'..gender..'01/hitingut0'..math.random(1, 2)..'.wav'
    elseif hitGroup == HITGROUP_LEFTLEG or hitGroup == HITGROUP_RIGHTLEG then
      return 'vo/npc/'..gender..'01/myleg0'..math.random(1, 2)..'.wav'
    elseif hitGroup == HITGROUP_LEFTARM or hitGroup == HITGROUP_RIGHTARM then
      return 'vo/npc/'..gender..'01/myarm0'..math.random(1, 2)..'.wav'
    elseif hitGroup == HITGROUP_GEAR then
      return 'vo/npc/'..gender..'01/startle0'..math.random(1, 2)..'.wav'
    end
  end

  return 'vo/npc/'..gender..'01/pain0'..math.random(1, 9)..'.wav'
end

--- Called when a player has spawned.
--
-- Uninitialized players are killed silently. For a full spawn (not a light spawn from
-- `cw.player:LightSpawn`) Catwork resets ragdoll, action, drunk, boosts and limb damage, sets
-- the model and loadout, applies config movement speeds and the faction or rank's health and
-- armor, gives the faction's `respawnInv` items, applies the faction's NPC relationships and
-- restores saved ammo on the first spawn. It then runs the light spawn callback, runs
-- `PostPlayerSpawn`, and re-applies clothes and accessories.
-- @param player [Player The player who spawned]
function GM:PlayerSpawn(player)
  if player:HasInitialized() then
    player:ShouldDropWeapon(false)

    if !player.cwLightSpawn then
      local FACTION = faction.FindByID(player:GetFaction())
      local relation = FACTION.entRelationship
      local playerRank, rank = player:GetFactionRank()

      cw.player:SetWeaponRaised(player, false)
      cw.player:SetRagdollState(player, RAGDOLL_RESET)
      cw.player:SetAction(player, false)
      cw.player:SetDrunk(player, false)

      cw.attributes:ClearBoosts(player)
      cw.limb:ResetDamage(player)

      self:PlayerSetModel(player)
      self:PlayerLoadout(player)

      if player:FlashlightIsOn() then
        player:Flashlight(false)
      end

      player:SetForcedAnimation(false)
      player:SetCollisionGroup(COLLISION_GROUP_PLAYER)
      player:SetMaterial('')
      player:SetMoveType(MOVETYPE_WALK)
      player:Extinguish()
      player:UnSpectate()
      player:GodDisable()
      player:RunCommand('-duck')
      player:SetColor(Color(255, 255, 255, 255))
      player:SetupHands()

      player:SetCrouchedWalkSpeed(config.GetVal('crouched_speed') / config.GetVal('walk_speed'))
      player:SetWalkSpeed(config.GetVal('walk_speed'))
      -- +walk (IN_WALK) is a native slow-walk now: keep it equal to the normal walk speed.
      player:SetSlowWalkSpeed(config.GetVal('walk_speed'))
      player:SetJumpPower(config.GetVal('jump_power'))
      player:SetRunSpeed(config.GetVal('run_speed'))
      player:CrosshairDisable()

      player:SetMaxHealth(FACTION.maxHealth or 100)
      player:SetMaxArmor(FACTION.maxArmor or 0)
      player:SetHealth(FACTION.maxHealth or 100)
      player:SetArmor(FACTION.maxArmor or 0)

      if rank then
        player:SetMaxHealth(rank.maxHealth or player:GetMaxHealth())
        player:SetMaxArmor(rank.maxArmor or player:GetMaxArmor())
        player:SetHealth(rank.maxHealth or player:GetMaxHealth())
        player:SetArmor(rank.maxArmor or player:GetMaxArmor())
      end

      if istable(FACTION.respawnInv) then
        local inventory = player:GetInventory()

        for k, v in pairs(FACTION.respawnInv) do
          local itemTable = item.FindByID(k)

          if itemTable then
            local owned = inventory[itemTable.uniqueID]

            -- Top the item up to the faction's amount.
            for i = (owned and table.Count(owned) or 0) + 1, v do
              player:GiveItem(item.CreateInstance(k), true)
            end
          end
        end
      end

      local steamID = player:SteamID()
      local prevRelations = prevRelation and prevRelation[steamID]

      if prevRelations then
        for k, v in ipairs(ents.GetAll()) do
          if v:IsNPC() then
            local prevRelationVal = prevRelations[v:GetClass()]

            if prevRelationVal then
              v:AddEntityRelationship(player, prevRelationVal, 1)
            end
          end
        end
      end

      if istable(relation) then
        prevRelation = prevRelation or {}
        prevRelation[steamID] = prevRelation[steamID] or {}

        for k, v in pairs(relation) do
          local disposition = relationTypes[string.lower(v)]

          if disposition then
            for k2, v2 in ipairs(ents.FindByClass(k)) do
              prevRelation[steamID][k] = v2:Disposition(player)
              v2:AddEntityRelationship(player, disposition, 1)
            end
          else
            ErrorNoHalt(
              "Attempting to add relationship using invalid relation '"..v.."' towards faction '"..FACTION.name..
                "'.\r\n"
            )
          end
        end
      end

      if player.cwFirstSpawn then
        local ammo = player:GetSavedAmmo()

        for k, v in pairs(ammo) do
          if !string.find(k, 'p_') and !string.find(k, 's_') then
            player:GiveAmmo(v, k) ammo[k] = nil
          end
        end
      else
        player:UnLock()
      end
    end

    if player.cwLightSpawn and player.cwSpawnCallback then
      player.cwSpawnCallback(player, true)
      player.cwSpawnCallback = nil
    end

    hook.Run('PostPlayerSpawn', player, player.cwLightSpawn, player.cwChangeClass, player.cwFirstSpawn)
    cw.player:SetRecognises(player, player, RECOGNISE_TOTAL)

    local accessoryData = player:GetAccessoryData()
    local clothesItem = player:GetClothesItem()

    if clothesItem then
      player:SetClothesData(clothesItem)
    end

    for k, v in pairs(accessoryData) do
      local itemTable = player:FindItemByID(v, k)

      if itemTable then
        itemTable:OnWearAccessory(player, true)
      else
        accessoryData[k] = nil
      end
    end

    player.cwChangeClass = false
    player.cwLightSpawn = false
  else
    player:KillSilent()
  end
end

--- Called to choose the hands model for a player's player model.
--
-- Uses `cw.animation:GetHandsInfo`, falling back to GMod's player hands, sets the model, skin and
-- bodygroups, then runs `PostCModelHandsSet`.
-- @param player [Player The player whose hands are set]
-- @param entity [Entity The hands entity]
function GM:PlayerSetHandsModel(player, entity)
  local model = player:GetModel()
  local simpleModel = player_manager.TranslateToPlayerModelName(model)
  local info = cw.animation:GetHandsInfo(model) or player_manager.TranslatePlayerHands(simpleModel)

  if info then
    entity:SetModel(info.model)
    entity:SetSkin(info.skin)

    local bodyGroups = tostring(info.body)

    if bodyGroups then
      bodyGroups = string.Explode('', bodyGroups)

      for k, v in pairs(bodyGroups) do
        local num = tonumber(v)

        if num then
          entity:SetBodygroup(k, num)
        end
      end
    end
  end

  hook.Run('PostCModelHandsSet', player, model, entity, info)
end

--- Called when a player attempts to connect; refuses banned players.
--
-- Looks the player up by IP (with and without the port) and Steam ID in `cw.bans.stored`.
-- Temporary bans show the `banned_message` config with `!t`/`!f` replaced by the time left,
-- permanent bans show the reason, and expired bans are removed. Everyone else is checked
-- against the server password by the base gamemode.
-- @param steamID64 [String The connecting player's 64-bit Steam ID]
-- @param ipAddress [String The player's IP address and port]
-- @param svPassword [String The server password]
-- @param clPassword [String The password the client sent]
-- @param name [String The player's Steam name]
-- @return [Boolean Whether the player may join, String The kick message when banned]
function GM:CheckPassword(steamID64, ipAddress, svPassword, clPassword, name)
  local steamID = util.SteamIDFrom64(steamID64)
  -- The engine passes `ip:port`, while a ban on an offline player's IP is stored without the port.
  local ip = string.match(ipAddress, '^[^:]+') or ipAddress
  local unixTime = os.time()

  -- Each identifier is judged on its own, so an expired ban never lifts a live one.
  for _, identifier in ipairs({ ipAddress, ip, steamID }) do
    local banTable = cw.bans.stored[identifier]

    if banTable then
      local unbanTime = tonumber(banTable.unbanTime) or 0

      if unbanTime == 0 then
        return false, banTable.reason
      elseif unixTime < unbanTime then
        local timeLeft = unbanTime - unixTime
        local hoursLeft = math.Round(timeLeft / 3600)
        local minutesLeft = math.Round(timeLeft / 60)
        local bannedMessage = config.Get('banned_message'):Get()

        if hoursLeft >= 1 then
          bannedMessage = string.gsub(bannedMessage, '!t', tostring(hoursLeft))
          bannedMessage = string.gsub(bannedMessage, '!f', 'hour(s)')
        elseif minutesLeft >= 1 then
          bannedMessage = string.gsub(bannedMessage, '!t', tostring(minutesLeft))
          bannedMessage = string.gsub(bannedMessage, '!f', 'minute(s)')
        else
          bannedMessage = string.gsub(bannedMessage, '!t', tostring(timeLeft))
          bannedMessage = string.gsub(bannedMessage, '!f', 'second(s)')
        end

        return false, bannedMessage
      else
        cw.bans:Remove(identifier)
      end
    end
  end

  return BaseClass.CheckPassword(self, steamID64, ipAddress, svPassword, clPassword, name)
end

--- Called when Catwork data is saved.
--
-- Saves every initialized player's character and, unless they follow the machine clock, the
-- in-game time and date.
function GM:SaveData()
  for k, v in ipairs(_player.GetAll()) do
    if v:HasInitialized() then
      v:SaveCharacter()
    end
  end

  if !config.GetVal('use_local_machine_time') then
    cw.core:SaveSchemaData('time', cw.time:GetSaveData())
  end

  if !config.GetVal('use_local_machine_date') then
    cw.core:SaveSchemaData('date', cw.date:GetSaveData())
  end
end

--- Called when a player attempts to use, delete or otherwise act on one of their characters from the menu.
--
-- Catwork refuses while the quiz is enabled and the player has not completed it.
-- @param player [Player The player acting]
-- @param action [String The action, such as `use` or `delete`]
-- @param character [Character The character acted on]
-- The caller only reads the first return value, so return the fault string itself to show it;
-- `false` shows the generic `CharFault_CannotInteract` fault.
-- @return [Any `false` or a fault string to refuse, anything else to allow]
function GM:PlayerCanInteractCharacter(player, action, character)
  if cw.quiz:GetEnabled() and !cw.quiz:GetCompleted(player) then
    return L'CharFault_QuizFailed'
  else
    return true
  end
end

--- Called when the map entities are initialized.
--
-- Marks every map entity with a model as a map entity and records its start position and
-- angles, makes chairs non-colliding and frozen, collects doors into `cw.entity.DoorEntities`,
-- networks `NoMySQL` and runs `ClockworkInitPostEntity`. Finally sets the `negated` key value
-- on wooden and furniture-like props.
function GM:InitPostEntity()
  for k, v in pairs(ents.GetAll()) do
    if IsValid(v) then
      if v:GetModel() then
        cw.entity:SetMapEntity(v, true)
        cw.entity:SetStartAngles(v, v:GetAngles())
        cw.entity:SetStartPosition(v, v:GetPos())

        if cw.entity:SetChairAnimations(v) then
          v:SetCollisionGroup(COLLISION_GROUP_WEAPON)

          local physicsObject = v:GetPhysicsObject()

          if IsValid(physicsObject) then
            physicsObject:EnableMotion(false)
          end
        end
      end

      if cw.entity:IsDoor(v) then
        local entIndex = v:EntIndex()

        if !cw.entity.DoorEntities then cw.entity.DoorEntities = {} end

        local doorEnts = cw.entity.DoorEntities

        if !doorEnts[entIndex] then
          doorEnts[entIndex] = v
        end
      end
    end
  end

  netvars.SetNetVar('NoMySQL', cw.NoMySQL)
  hook.Run('ClockworkInitPostEntity')

  for k, v in ipairs(ents.GetAll()) do
    local model = v:GetModel()

    if !v:IsPlayer() and model and (model:find('wood') or model:find('table') or model:find('bench')
    or model:find('chair') or model:find('box') or model:find('cardboard') or model:find('pallet')) then
      v:SetKeyValue('negated', '1')
    end
  end
end

--- Called when a player initially spawns.
--
-- Sets up the player's character list and shared variables, kills them silently until a
-- character is loaded, sends the config to bots, and logs and announces the connection unless
-- the player is being kicked.
-- @param player [Player The player who joined]
function GM:PlayerInitialSpawn(player)
  player.cwCharacterList = player.cwCharacterList or {}
  player.cwHasSpawned = true
  player.cwSharedVars = player.cwSharedVars or {}

  if IsValid(player) then
    player:KillSilent()
  end

  if player:IsBot() then
    config.Send(player)
  end

  if !player:IsKicked() then
    cw.core:PrintLog(
      LOGTYPE_MINOR,
      player:SteamName()..' ('..player:SteamID()..' / '..player:IPAddress()..') has connected.'
    )
    chatbox.AddText(nil, player:SteamName()..L'PlayerConnected', {
      filter = 'events',
      icon = 'icon16/user_add.png',
      textColor = Color(150, 80, 210)
    })
  end
end

--- Called every frame while a player is dead.
--
-- Respawns the player as soon as they have a usable character, unless their character is banned,
-- the character menu has been reset, or a `spawn` action (the respawn timer) is running.
-- @param player [Player The dead player]
-- @return [Boolean `true` to keep the player dead this frame]
function GM:PlayerDeathThink(player)
  if !player:HasInitialized() or player:GetCharacterData('CharBanned') then
    return true
  end

  if player:IsCharacterMenuReset() then
    return true
  end

  if cw.player:GetAction(player) == 'spawn' then
    return true
  else
    player:Spawn()
  end
end

--- Called when a player's data has loaded.
--
-- Shows the Catwork intro once per player when `clockwork_intro_enabled` is set.
-- @param player [Player The player whose data loaded]
function GM:PlayerDataLoaded(player)
  if config.GetVal('clockwork_intro_enabled') then
    if !player:GetData('ClockworkIntro') then
      cable.send(player, 'ClockworkIntro', true)

      player:SetData('ClockworkIntro', true)
    end
  end
end

--- Called before a player is given a weapon with `Player:Give`; return `false` to block it.
-- @param player [Player The player receiving the weapon]
-- @param class [String The weapon class]
-- @param itemTable [Item The weapon's item, or `nil`]
-- @return [Boolean Whether the weapon can be given]
function GM:PlayerCanBeGivenWeapon(player, class, itemTable)
  return true
end

--- Called after a player has been given a weapon.
--
-- Rebuilds the inventory menu and attaches visible gear for weapon items: `Throwable`, `Melee`,
-- `Secondary` (weight 2 or less) or `Primary`.
-- @param player [Player The player given the weapon]
-- @param class [String The weapon class]
-- @param itemTable [Item The weapon's item, or `nil`]
function GM:PlayerGivenWeapon(player, class, itemTable)
  cw.inventory:Rebuild(player)

  if item.IsWeapon(itemTable) and !itemTable:IsFakeWeapon() then
    if !itemTable:IsMeleeWeapon() and !itemTable:IsThrowableWeapon() then
      if itemTable.weight <= 2 then
        cw.player:CreateGear(player, 'Secondary', itemTable)
      else
        cw.player:CreateGear(player, 'Primary', itemTable)
      end
    elseif itemTable:IsThrowableWeapon() then
      cw.player:CreateGear(player, 'Throwable', itemTable)
    else
      cw.player:CreateGear(player, 'Melee', itemTable)
    end
  end
end

--- Called when a player attempts to create a character.
--
-- Catwork refuses while the quiz is enabled and not completed.
-- @param player [Player The player creating the character]
-- @param character [Character The new character's data]
-- @param characterID [Number The ID the character will get]
-- @return [Any `false` to refuse with a generic fault, a fault string to refuse with that message, or
-- `true` to allow]
function GM:PlayerCanCreateCharacter(player, character, characterID)
  if cw.quiz:GetEnabled() and !cw.quiz:GetCompleted(player) then
    return L'CharFault_QuizNotCompleted'
  else
    return true
  end
end

--- Called when a player fires bullets, to adjust the bullet table in place; does nothing by default.
-- @param player [Player The player firing]
-- @param bulletInfo [Map The `Bullet` structure passed to `Entity:FireBullets`]
function GM:PlayerAdjustBulletInfo(player, bulletInfo) end

--- Called when an entity fires bullets; overridden to do nothing.
-- @param entity [Entity The entity firing]
-- @param bulletInfo [Map The `Bullet` structure]
function GM:EntityFireBullets(entity, bulletInfo) end

--- Called to get the fall damage a player takes.
--
-- Damage grows above 464 units/s and is scaled by `scale_fall_damage`. With `wood_breaks_fall`,
-- landing on a wooden physics prop breaks it and cuts the damage to a quarter. Falls dealing more
-- than 30 damage make the player fall over.
-- @param player [Player The falling player]
-- @param velocity [Number The fall speed]
-- @return [Number The damage to deal]
function GM:GetFallDamage(player, velocity)
  local ragdollEntity = nil
  local position = player:GetPos()
  local damage = math.max((velocity - 464) * 0.225225225, 0) * config.GetVal('scale_fall_damage')
  local filter = { player }

  if config.GetVal('wood_breaks_fall') then
    if player:IsRagdolled() then
      ragdollEntity = player:GetRagdollEntity()
      position = ragdollEntity:GetPos()
      filter = { player, ragdollEntity }
    end

    local traceLine = util.TraceLine({
      endpos = position - Vector(0, 0, 64),
      start = position,
      filter = filter
    })

    if IsValid(traceLine.Entity) and traceLine.MatType == MAT_WOOD then
      if string.find(traceLine.Entity:GetClass(), 'prop_physics') then
        traceLine.Entity:Fire('break', '', 0)
        damage = damage * 0.25
      end
    end
  end

  if damage > 30 then
    timer.Simple(0, function()
      -- The fall may have killed the player, and a knocked out player must not get to stand up.
      if IsValid(player) and player:Alive() and player:GetRagdollState() != RAGDOLL_KNOCKEDOUT then
        cw.player:SetRagdollState(player, RAGDOLL_FALLENOVER, nil)

        player:SetDTBool(BOOL_FALLENOVER, true)
      end
    end)
  end

  return damage
end

--- Called after a player's initial data stream info has been sent.
--
-- Bots get a random faction, gender and model and load a character straight away. Real players
-- have their data loaded (running `PlayerDataLoaded`), their whitelists sent and their characters
-- added to the character menu. A character for which `PlayerAdjustCharacterTable` returns `true`
-- is deleted instead.
-- @param player [Player The player the data was sent to]
function GM:PlayerDataStreamInfoSent(player)
  if player:IsBot() then
    cw.player:LoadData(player, function(player)
      hook.Run('PlayerDataLoaded', player)

      local factions = table.ClearKeys(faction.GetAll(), true)
      local faction = factions[math.random(1, #factions)]

      if faction then
        local genders = { GENDER_MALE, GENDER_FEMALE }
        local gender = faction.singleGender or genders[math.random(1, #genders)]
        local models = faction.models[string.lower(gender)]
        local model = models[math.random(1, #models)]

        cw.player:LoadCharacter(player, 1, {
          faction = faction.name,
          gender = gender,
          model = model,
          name = player:Name(),
          data = {}
        }, function()
          cw.player:LoadCharacter(player, 1)
        end)
      end
    end)
  elseif table.Count(faction.GetAll()) > 0 then
    cw.player:LoadData(player, function()
      hook.Run('PlayerDataLoaded', player)

      local whitelisted = player:GetData('Whitelisted')
      local steamName = player:SteamName()
      local unixTime = os.time()

      cw.player:SetCharacterMenuState(player, CHARACTER_MENU_OPEN)

      if whitelisted then
        for k, v in pairs(whitelisted) do
          if _faction.GetStored()[v] then
            cable.send(player, 'SetWhitelisted', { v, true })
          else
            whitelisted[k] = nil
          end
        end
      end

      cw.player:GetCharacters(player, function(characters)
        if characters then
          for k, v in pairs(characters) do
            cw.player:ConvertCharacterMySQL(v)
            player.cwCharacterList[v.characterID] = {}

            for k2, v2 in pairs(v) do
              if k2 == 'timeCreated' then
                if v2 == '' then
                  player.cwCharacterList[v.characterID][k2] = unixTime
                else
                  player.cwCharacterList[v.characterID][k2] = v2
                end
              elseif k2 == 'lastPlayed' then
                player.cwCharacterList[v.characterID][k2] = unixTime
              elseif k2 == 'steamName' then
                player.cwCharacterList[v.characterID][k2] = steamName
              else
                player.cwCharacterList[v.characterID][k2] = v2
              end
            end
          end

          for k, v in pairs(player.cwCharacterList) do
            local bDelete = hook.Run('PlayerAdjustCharacterTable', player, v)

            if !bDelete then
              cw.player:CharacterScreenAdd(player, v)
            else
              cw.player:ForceDeleteCharacter(player, k)
            end
          end
        end

        cw.player:SetCharacterMenuState(player, CHARACTER_MENU_LOADED)
      end)
    end)
  end
end

--- Called when a player's initial data stream info should be sent; sends the shared tables and any colour mod override.
-- @param player [Player The player to send the data to]
function GM:PlayerSendDataStreamInfo(player)
  cable.send(player, 'SharedTables', cw.SharedTables)

  if cw.OverrideColorMod and cw.OverrideColorMod != nil then
    cable.send(player, 'SystemColGet', cw.OverrideColorMod)
  end
end

--- Called to choose the sound a player makes when they die; returns a random HL2 citizen pain line.
-- @param player [Player The dying player]
-- @param gender [String The player's gender]
-- @return [String The sound path, or `nil` for no sound]
function GM:PlayerPlayDeathSound(player, gender)
  return 'vo/npc/'..string.lower(gender)..'01/pain0'..math.random(1, 9)..'.wav'
end

--- Called when a player's character data is restored as the character loads.
--
-- Cleans up the physical description and makes sure `LimbData`, `Clothes` and `Accessories`
-- exist before passing the data to `cw.player:RestoreCharacterData`.
-- @param player [Player The player loading the character]
-- @param data [Map The character's saved data, modified in place]
function GM:PlayerRestoreCharacterData(player, data)
  if data['PhysDesc'] then
    data['PhysDesc'] = cw.core:ModifyPhysDesc(data['PhysDesc'])
  end

  if !data['LimbData'] then
    data['LimbData'] = {}
  end

  if !data['Clothes'] then
    data['Clothes'] = {}
  end

  if !data['Accessories'] then
    data['Accessories'] = {}
  end

  cw.player:RestoreCharacterData(player, data)
end

--- Called when a player's limb damage is healed; does nothing by default.
-- @param player [Player The healed player]
-- @param hitGroup [Number The hit group (`HITGROUP_*`)]
-- @param amount [Number The limb's new damage amount]
function GM:PlayerLimbDamageHealed(player, hitGroup, amount) end

--- Called when a player's limb takes damage; does nothing by default.
-- @param player [Player The hurt player]
-- @param hitGroup [Number The hit group (`HITGROUP_*`)]
-- @param damage [Number The damage taken]
function GM:PlayerLimbTakeDamage(player, hitGroup, damage) end

--- Called when a player's limb damage is reset; does nothing by default.
-- @param player [Player The player whose limb damage was reset]
function GM:PlayerLimbDamageReset(player) end

--- Called when a player's character data is about to be saved.
--
-- Saves attribute boosts when `save_attribute_boosts` is set, and health and armor when they are
-- above 1.
-- @param player [Player The player whose character is saved]
-- @param data [Map The character data to save, modified in place]
function GM:PlayerSaveCharacterData(player, data)
  if config.Get('save_attribute_boosts'):Get() then
    cw.core:SavePlayerAttributeBoosts(player, data)
  end

  data['Health'] = player:Health()
  data['Armor'] = player:Armor()

  if data['Health'] <= 1 then
    data['Health'] = nil
  end

  if data['Armor'] <= 1 then
    data['Armor'] = nil
  end
end

--- Called when a player's (not character's) data is about to be saved; drops an empty `Whitelisted` table.
-- @param player [Player The player whose data is saved]
-- @param data [Map The player data to save, modified in place]
function GM:PlayerSaveData(player, data)
  if data['Whitelisted'] and table.Count(data['Whitelisted']) == 0 then
    data['Whitelisted'] = nil
  end
end

--- Called every player think while a player has storage open, to check whether it should close.
--
-- Closes it when the player is ragdolled or dead, the storage entity is gone or out of
-- `storageTable.distance`, or the storage's own `ShouldClose` callback returns `true`.
-- @param player [Player The player with storage open]
-- @param storageTable [Map The open storage]
-- @return [Boolean `true` to close the storage]
function GM:PlayerStorageShouldClose(player, storageTable)
  local entity = player:GetStorageEntity()

  if player:IsRagdolled() or !player:Alive() or (storageTable.entity and !entity)
  or (storageTable.entity and storageTable.distance
  and player:GetShootPos():Distance(entity:GetPos()) > storageTable.distance) then
    return true
  elseif storageTable.ShouldClose and storageTable.ShouldClose(player, storageTable) then
    return true
  end
end

--- Called when a player attempts to pick up a weapon.
--
-- Only allowed when the weapon is being given (`player.cwForceGive`) or the player is looking at
-- it and holding use.
-- @param player [Player The player picking up]
-- @param weapon [Weapon The weapon]
-- @return [Boolean Whether the weapon can be picked up]
function GM:PlayerCanPickupWeapon(player, weapon)
  if player.cwForceGive or (player:GetEyeTraceNoCursor().Entity == weapon and player:KeyDown(IN_USE)) then
    return true
  else
    return false
  end
end

--- Called when the next wages payout is scheduled, to change the interval; does nothing by default.
-- @param info [Map Has `interval`, the seconds until the next payout, which can be changed]
function GM:ModifyWagesInterval(info) end

--- Called before a player is paid wages, to change the amount; does nothing by default.
-- @param player [Player The player being paid]
-- @param info [Map Has `wages`, the amount to pay, which can be changed]
function GM:PlayerModifyWagesInfo(player, info) end

--- Called once a second on the server, from the `cw.OneSecondTimer` timer.
--
-- Distributes hints every `hint_interval` and wages every `wages_interval` (adjustable through
-- `ModifyWagesInterval`), advances the in-game clock every `minute_time`, runs `PreSaveData`,
-- `SaveData` and `PostSaveData` every `save_data_interval`, and changes to the same map after
-- 20 minutes with no players.
function GM:OneSecond()
  local sysTime = SysTime()
  local curTime = CurTime()

  if !cw.NextHint or curTime >= cw.NextHint then
    cw.hint:Distribute()
    cw.NextHint = curTime + config.Get('hint_interval'):Get()
  end

  if !cw.NextWagesTime or curTime >= cw.NextWagesTime then
    cw.core:DistributeWagesCash()

    local info = {
      interval = config.GetVal('wages_interval')
    }

    hook.Run('ModifyWagesInterval', info)

    cw.NextWagesTime = curTime + info.interval
  end

  if !cw.NextDateTimeThink or sysTime >= cw.NextDateTimeThink then
    cw.core:PerformDateTimeThink()
    cw.NextDateTimeThink = sysTime + config.Get('minute_time'):Get()
  end

  if !cw.NextSaveData or sysTime >= cw.NextSaveData then
    hook.Run('PreSaveData')
      hook.Run('SaveData')
    hook.Run('PostSaveData')

    cw.NextSaveData = sysTime + config.Get('save_data_interval'):Get()
  end

  if !cw.NextCheckEmpty then
    cw.NextCheckEmpty = sysTime + 1200
  end

  if sysTime >= cw.NextCheckEmpty then
    cw.NextCheckEmpty = nil

    if #_player.GetAll() == 0 then
      RunConsoleCommand('changelevel', game.GetMap())
    end
  end
end

do
  local thinkRate = 0.150
  local cwNextThink = 0
  local cwNextSecond = 0

  --- Called each tick; drives the per-player think hooks.
  --
  -- Every 0.15 seconds it resets each initialized player's `cwInfoTable` (the `default_inv_weight`
  -- and `default_inv_space` configs, the player's base speeds, running and jumping state and class
  -- wages) and runs `PlayerThink`; once a second it also runs `OnePlayerSecond`.
  function GM:Tick()
    local curTime = CurTime()

    if curTime >= cwNextThink then
      local defaultInvWeight = config.GetVal('default_inv_weight')
      local defaultInvSpace = config.GetVal('default_inv_space')
      local bIsSecond = curTime >= cwNextSecond

      for k, v in ipairs(_player.GetAll()) do
        if v:HasInitialized() then
          local infoTable = v.cwInfoTable

          infoTable.inventoryWeight = defaultInvWeight
          infoTable.inventorySpace = defaultInvSpace
          infoTable.crouchedSpeed = v.cwCrouchedSpeed
          infoTable.jumpPower = v.cwJumpPower
          infoTable.walkSpeed = v.cwWalkSpeed
          infoTable.isRunning = v:IsRunning()
          infoTable.isJumping = v:IsJumping()
          infoTable.runSpeed = v.cwRunSpeed
          infoTable.wages = cw.class:Query(v:Team(), 'wages', 0)

          hook.Run('PlayerThink', v, curTime, infoTable)

          if bIsSecond then
            hook.Run('OnePlayerSecond', v, curTime, infoTable)
          end
        end
      end

      cwNextThink = curTime + thinkRate

      if bIsSecond then
        cwNextSecond = curTime + 1
      end
    end
  end
end

--- Called every frame; overridden to do nothing, Catwork's periodic work runs from `GM:Tick`.
function GM:Think() end

--- Called once a second, when health regeneration is enabled, to check whether a player regenerates.
--
-- Always allows it.
-- @param player [Player The player]
-- @return [Boolean Whether `PlayerHealthRegenerate` runs for the player]
function GM:PlayerShouldHealthRegenerate(player)
  return true
end

--- Called by `Player:GetHoldingEntity` to get the entity a player is holding.
--
-- Return an entity to override `player.cwIsHoldingEnt`.
-- @param player [Player The player]
-- @return [Entity The held entity, or `nil` to use the default]
function GM:PlayerGetHoldingEntity(player) end

--- Called once a second to regenerate a living player's health.
--
-- Heals 2 health every 5 seconds while above half health, otherwise every 10 seconds.
-- @param player [Player The player to heal]
-- @param health [Number The player's health]
-- @param maxHealth [Number The player's maximum health]
function GM:PlayerHealthRegenerate(player, health, maxHealth)
  local curTime = CurTime()

  if player:Alive() and (!player.cwNextHealthRegen or curTime >= player.cwNextHealthRegen) then
    if health >= (maxHealth / 2) and (health < maxHealth) then
      player:SetHealth(math.Clamp(
        health + 2, 0, maxHealth)
      )

      player.cwNextHealthRegen = curTime + 5
    elseif health > 0 then
      player:SetHealth(
        math.Clamp(health + 2, 0, maxHealth)
      )

      player.cwNextHealthRegen = curTime + 10
    end
  end
end

--- Called after a player picks up an item entity; does nothing by default.
-- @param player [Player The player who picked it up]
-- @param itemTable [Item The item]
-- @param itemEntity [Entity The item entity that was picked up]
-- @param bQuickUse [Boolean Whether the item was used straight away instead of taken]
function GM:PlayerPickupItem(player, itemTable, itemEntity, bQuickUse) end

--- Called after a player uses an item; does nothing by default.
-- @param player [Player The player who used it]
-- @param itemTable [Item The item]
-- @param itemEntity [Entity The item entity it was used from, or `nil` when used from the inventory]
function GM:PlayerUseItem(player, itemTable, itemEntity) end

--- Called after a player drops an item; does nothing by default.
-- @param player [Player The player who dropped it]
-- @param itemTable [Item The item]
-- @param position [Vector Where it was dropped]
-- @param entity [Entity The spawned item entity]
function GM:PlayerDropItem(player, itemTable, position, entity) end

--- Called after a player destroys an item; does nothing by default.
-- @param player [Player The player who destroyed it]
-- @param itemTable [Item The item]
function GM:PlayerDestroyItem(player, itemTable) end

--- Called after a player drops a weapon; saves the weapon's clip ammo on its item.
-- @param player [Player The player who dropped it]
-- @param itemTable [Item The weapon's item]
-- @param entity [Entity The spawned item entity]
-- @param weapon [Weapon The weapon that was dropped]
function GM:PlayerDropWeapon(player, itemTable, entity, weapon)
  if itemTable:IsInstance() and IsValid(weapon) then
    local clipOne = weapon:Clip1()
    local clipTwo = weapon:Clip2()

    if clipOne > 0 then
      itemTable:SetData('ClipOne', clipOne)
    end

    if clipTwo > 0 then
      itemTable:SetData('ClipTwo', clipTwo)
    end
  end
end

--- Called when a player's (not character's) data is restored; makes sure `Whitelisted` exists.
-- @param player [Player The player]
-- @param data [Map The player's saved data, modified in place]
function GM:PlayerRestoreData(player, data)
  if !data['Whitelisted'] then
    data['Whitelisted'] = {}
  end
end

--- Called when a player attempts to pick up an entity with use; always refuses, Catwork handles picking up itself.
-- @param player [Player The player]
-- @param entity [Entity The entity]
-- @return [Boolean Always `false`]
function GM:AllowPlayerPickup(player, entity)
  return false
end

--- Called when a player selects a custom character option; does nothing by default.
--
-- The character menu actually runs `PlayerSelectCustomCharacterOption` for options other than
-- `use` and `delete`.
-- @param player [Player The player]
-- @param character [Character The character]
-- @param option [String The option]
function GM:PlayerSelectCharacterOption(player, character, option) end

--- Called for every initialized player when an admin runs `cwStatus`, to get the status line shown for them.
-- @param player [Player The admin running the command]
-- @param target [Player The player listed]
-- @return [String The line to print (user ID, name, Steam name, Steam ID and IP), or `nil` to hide the player]
function GM:PlayerCanSeeStatus(player, target)
  return '# '..target:UserID()..' | '..target:Name()..' | '..target:SteamName()..' | '..target:SteamID()..' | '..
    target:IPAddress()
end

--- Called when a player attempts to see another player's chat; always allows it.
-- @param text [String The message]
-- @param teamOnly [Boolean Whether it was sent to the team only]
-- @param listener [Player The player receiving the message]
-- @param speaker [Player The player who sent it]
-- @return [Boolean Whether the listener sees the message]
function GM:PlayerCanSeePlayersChat(text, teamOnly, listener, speaker)
  return true
end

--- Called when a player attempts to hear another player's voice.
--
-- Refuses when voice is disabled, the speaker is voice banned or lacks the `x` flag. With
-- `local_voice`, both players must also be alive, conscious and within `talk_radius`.
-- @param listener [Player The player listening]
-- @param speaker [Player The player talking]
-- @return [Boolean Whether the listener hears the speaker, Boolean Whether the voice is 3D]
function GM:PlayerCanHearPlayersVoice(listener, speaker)
  if !config.GetVal('voice_enabled') or speaker:GetData('VoiceBan') then
    return false
  end

  -- The engine asks for every pair of players, so the cheap checks come before the flag lookup.
  if config.GetVal('local_voice') then
    local talkRadius = config.GetVal('talk_radius')

    if listener:GetPos():DistToSqr(speaker:GetPos()) > talkRadius * talkRadius then
      return false
    elseif listener:IsRagdolled(RAGDOLL_KNOCKEDOUT) or !listener:Alive() then
      return false
    elseif speaker:IsRagdolled(RAGDOLL_KNOCKEDOUT) or !speaker:Alive() then
      return false
    end
  end

  if !cw.player:HasFlags(speaker, 'x') then
    return false
  end

  return true, true
end

--- Called when a player attempts to delete a character; allows it by default.
-- @param player [Player The player]
-- @param character [Character The character to delete]
-- @return [Any `nil` or `true` to allow; anything else refuses, and a string is shown as the reason]
function GM:PlayerCanDeleteCharacter(player, character) end

--- Called when a player who already has a character loaded attempts to switch to another.
--
-- Refuses while dead (unless the character menu was reset or the character is banned) and
-- while knocked out.
-- @param player [Player The player]
-- @param character [Character The character to switch to]
-- @return [Any `nil` or `true` to allow; anything else refuses, and a string is shown as the reason]
function GM:PlayerCanSwitchCharacter(player, character)
  if !player:Alive() and !player:IsCharacterMenuReset() and !player:GetNetVar('CharBanned') then
    return L'CantSwitchWhenDead'
  elseif player:GetRagdollState() == RAGDOLL_KNOCKEDOUT then
    return L'CantSwitchWhenUnc'
  end

  return true
end

--- Called when a player attempts to use a character.
--
-- Refuses banned characters and characters whose faction or faction rank is at its
-- `playerLimit`.
-- @param player [Player The player]
-- @param character [Character The character to use]
-- @return [Any `nil` or `true` to allow; anything else refuses, and a string is shown as the reason]
function GM:PlayerCanUseCharacter(player, character)
  if character.data['CharBanned'] then
    return character.name..L'CharIsBanned'
  end

  local faction = faction.FindByID(character.faction)
  local playerRank, rank = player:GetFactionRank(character)
  local factionCount = 0
  local rankCount = 0

  for k, v in ipairs(_player.GetAll()) do
    if v:HasInitialized() then
      if v:GetFaction() == character.faction then
        if player != v then
          if rank and v:GetFactionRank() == playerRank then
            rankCount = rankCount + 1
          end

          factionCount = factionCount + 1
        end
      end
    end
  end

  if faction.playerLimit and factionCount >= faction.playerLimit then
    return L'TooManyCharFaction'
  end

  if rank and rank.playerLimit and rankCount >= rank.playerLimit then
    return L'TooManyCharClass'
  end
end

--- Called when a player's spawn weapons should be given; gives the weapons listed by their faction rank and faction.
-- @param player [Player The player]
function GM:PlayerGiveWeapons(player)
  local rankName, rank = player:GetFactionRank()
  local faction = faction.FindByID(player:GetFaction())

  if rank and rank.weapons then
    for k, v in pairs(rank.weapons) do
      cw.player:GiveSpawnWeapon(player, v)
    end
  end

  if faction and faction.weapons then
    for k, v in pairs(faction.weapons) do
      cw.player:GiveSpawnWeapon(player, v)
    end
  end
end

--- Called after a player deletes a character; does nothing by default.
-- @param player [Player The player]
-- @param character [Character The deleted character]
function GM:PlayerDeleteCharacter(player, character) end

--- Called when a player's armor is set; keeps a ragdolled player's stored armor in sync.
-- @param player [Player The player]
-- @param newArmor [Number The new armor]
-- @param oldArmor [Number The previous armor]
function GM:PlayerArmorSet(player, newArmor, oldArmor)
  if player:IsRagdolled() then
    player:GetRagdollTable().armor = newArmor
  end
end

--- Called when a player's health is set.
--
-- Healing also heals limb damage by half the amount gained; reaching full health heals every
-- limb and removes decals from the player and their ragdoll. Keeps a ragdolled player's stored
-- health in sync.
-- @param player [Player The player]
-- @param newHealth [Number The new health]
-- @param oldHealth [Number The previous health]
function GM:PlayerHealthSet(player, newHealth, oldHealth)
  local bIsRagdolled = player:IsRagdolled()
  local maxHealth = player:GetMaxHealth()

  if newHealth > oldHealth then
    cw.limb:HealBody(player, (newHealth - oldHealth) / 2)
  end

  if newHealth >= maxHealth then
    cw.limb:HealBody(player, 100)
    player:RemoveAllDecals()

    if bIsRagdolled then
      player:GetRagdollEntity():RemoveAllDecals()
    end
  end

  if bIsRagdolled then
    player:GetRagdollTable().health = newHealth
  end
end

--- Called when a player attempts to own a door; refuses doors marked unownable.
-- @param player [Player The player]
-- @param door [Entity The door]
-- @return [Boolean Whether the door can be owned]
function GM:PlayerCanOwnDoor(player, door)
  if cw.entity:IsDoorUnownable(door) then
    return false
  else
    return true
  end
end

--- Called when a player attempts to view a door's menu; refuses doors marked unownable.
-- @param player [Player The player]
-- @param door [Entity The door]
-- @return [Boolean Whether the door menu opens]
function GM:PlayerCanViewDoor(player, door)
  if cw.entity:IsDoorUnownable(door) then
    return false
  end

  return true
end

--- Called when a player attempts to holster a weapon back into their inventory.
--
-- Spawn weapons (from the faction or rank) cannot be holstered; otherwise the item's own
-- `CanHolsterWeapon` decides when it has one.
-- @param player [Player The player]
-- @param itemTable [Item The weapon's item]
-- @param weapon [Weapon The weapon]
-- @param bForce [Boolean Whether the holster is forced]
-- @param bNoMsg [Boolean Whether to skip notifying the player]
-- @return [Boolean Whether the weapon can be holstered]
function GM:PlayerCanHolsterWeapon(player, itemTable, weapon, bForce, bNoMsg)
  if cw.player:GetSpawnWeapon(player, itemTable:GetWeaponClass()) then
    if !bNoMsg then
      cw.player:Notify(player, L(player, 'CannotHolsterWeapon'))
    end

    return false
  elseif itemTable.CanHolsterWeapon then
    return itemTable:CanHolsterWeapon(player, weapon, bForce, bNoMsg)
  else
    return true
  end
end

--- Called when a player attempts to drop a weapon.
--
-- Spawn weapons cannot be dropped; otherwise the item's own `CanDropWeapon` decides when it has
-- one.
-- @param player [Player The player]
-- @param itemTable [Item The weapon's item]
-- @param weapon [Weapon The weapon]
-- @param bNoMsg [Boolean Whether to skip notifying the player]
-- @return [Boolean Whether the weapon can be dropped]
function GM:PlayerCanDropWeapon(player, itemTable, weapon, bNoMsg)
  if cw.player:GetSpawnWeapon(player, itemTable:GetWeaponClass()) then
    if !bNoMsg then
      cw.player:Notify(player, L(player, 'CannotDropWeapon'))
    end

    return false
  elseif itemTable.CanDropWeapon then
    return itemTable:CanDropWeapon(player, bNoMsg)
  else
    return true
  end
end

--- Called when a player attempts to use an item from their inventory.
--
-- Catwork refuses, with a notification unless `bNoMsg` is set, when the item is a weapon the
-- player already has as a spawn weapon. Return `false` to block the use.
-- @param player [Player The player]
-- @param itemTable [Item The item]
-- @param bNoMsg=nil [Boolean Whether to skip notifying the player]
-- @return [Boolean Whether the item can be used]
function GM:PlayerCanUseItem(player, itemTable, bNoMsg)
  local isWeapon = item.IsWeapon(itemTable)
  local isSpawnWeapon = false

  if isWeapon then
    item.Validate(itemTable)

    isSpawnWeapon = cw.player:GetSpawnWeapon(player, itemTable:GetWeaponClass())
  end

  if isWeapon and isSpawnWeapon then
    if !bNoMsg then
      cw.player:Notify(player, L(player, 'CannotUseWeapon'))
    end

    return false
  else
    return true
  end
end

--- Called when a player attempts to drop an item; always allows it.
--
-- Return `false` to block the drop.
--
-- @param player [Player The player]
-- @param itemTable [Item The item]
-- @param bNoMsg [Any Whether to skip notifying the player; the inventory command passes the drop position here]
-- @return [Boolean Whether the item can be dropped]
function GM:PlayerCanDropItem(player, itemTable, bNoMsg) return true end

--- Called when a player attempts to destroy an item; always allows it.
--
-- Return `false` to block it.
--
-- @param player [Player The player]
-- @param itemTable [Item The item]
-- @param bNoMsg [Boolean Whether to skip notifying the player]
-- @return [Boolean Whether the item can be destroyed]
function GM:PlayerCanDestroyItem(player, itemTable, bNoMsg) return true end

--- Called when a player attempts to knock out another player; always allows it.
-- @param player [Player The player]
-- @param target [Player The target]
-- @return [Boolean Whether the knockout is allowed]
function GM:PlayerCanKnockout(player, target) return true end

--- Called when a player attempts to speak on the radio; always allows it.
--
-- Return `false` to block the message.
--
-- @param player [Player The player speaking]
-- @param text [String The message]
-- @param listeners [List<Player> Players who will hear it over the radio, can be changed]
-- @param eavesdroppers [List<Player> Players nearby who will overhear it, can be changed]
-- @return [Boolean Whether the message is sent]
function GM:PlayerCanRadio(player, text, listeners, eavesdroppers) return true end

--- Called when a player dies, to check whether everyone forgets their name; never by default.
-- @param player [Player The player who died]
-- @param attacker [Entity The killer]
-- @param damageInfo [CTakeDamageInfo The fatal damage]
-- @return [Boolean `true` to clear the name with `cw.player:ClearName`]
function GM:PlayerCanDeathClearName(player, attacker, damageInfo) return false end

--- Called when a player dies, to check whether they forget everyone they recognised; never by default.
-- @param player [Player The player who died]
-- @param attacker [Entity The killer]
-- @param damageInfo [CTakeDamageInfo The fatal damage]
-- @return [Boolean `true` to clear the player's recognised names]
function GM:PlayerCanDeathClearRecognisedNames(player, attacker, damageInfo) return false end

--- Called when a ragdolled player's ragdoll attempts to take damage.
--
-- Damage from non-players is ignored while the ragdoll's `immunity` time has not passed.
-- @param player [Player The ragdolled player]
-- @param ragdoll [Entity The ragdoll]
-- @param inflictor [Entity The inflictor]
-- @param attacker [Entity The attacker]
-- @param hitGroup [Number The hit group (`HITGROUP_*`)]
-- @param damageInfo [CTakeDamageInfo The damage]
-- @return [Boolean Whether the damage is applied to the player]
function GM:PlayerRagdollCanTakeDamage(player, ragdoll, inflictor, attacker, hitGroup, damageInfo)
  if !attacker:IsPlayer() and player:GetRagdollTable().immunity then
    if CurTime() <= player:GetRagdollTable().immunity then
      return false
    end
  end

  return true
end

--- Called when a player attempts to be ragdolled; always allows it.
-- @param player [Player The player]
-- @param state [Number The ragdoll state (`RAGDOLL_*`)]
-- @param delay [Number Seconds until the player gets up, or `nil`]
-- @param decay [Number Seconds until the ragdoll decays, or `nil`]
-- @param ragdoll [Map The existing ragdoll table when changing state while ragdolled, otherwise `nil`]
-- @return [Boolean Whether the player is ragdolled]
function GM:PlayerCanRagdoll(player, state, delay, decay, ragdoll)
  return true
end

--- Called when a player attempts to be unragdolled; always allows it.
-- @param player [Player The player]
-- @param state [Number The ragdoll state (`RAGDOLL_*`)]
-- @param ragdoll [Map The player's ragdoll table]
-- @return [Boolean Whether the player gets up]
function GM:PlayerCanUnragdoll(player, state, ragdoll)
  return true
end

--- Called after a player has been ragdolled; clears the fallen over flag.
-- @param player [Player The player]
-- @param state [Number The ragdoll state (`RAGDOLL_*`)]
-- @param ragdoll [Map The player's ragdoll table]
function GM:PlayerRagdolled(player, state, ragdoll)
  player:SetDTBool(BOOL_FALLENOVER, false)
end

--- Called after a player has been unragdolled; clears the fallen over flag.
-- @param player [Player The player]
-- @param state [Number The ragdoll state (`RAGDOLL_*`)]
-- @param ragdoll [Map The player's ragdoll table]
function GM:PlayerUnragdolled(player, state, ragdoll)
  player:SetDTBool(BOOL_FALLENOVER, false)
end

--- Called by `cw.player:HasFlags` to check whether a player has a flag they do not hold themselves.
--
-- Catwork grants the flags in the `default_flags` config to everyone.
-- @param player [Player The player]
-- @param flag [String A single flag]
-- @return [Boolean `true` to grant the flag, `false` to deny it, `nil` to fall through]
function GM:PlayerDoesHaveFlag(player, flag)
  if string.find(config.Get('default_flags'):Get(), flag, 1, true) then
    return true
  end
end

--- Called when a player's model should be set; applies their default model and skin.
-- @param player [Player The player]
function GM:PlayerSetModel(player)
  cw.player:SetDefaultModel(player)
  cw.player:SetDefaultSkin(player)
end

--- Called by `cw.player:HasDoorAccess` to check whether a player has an access level on a door.
--
-- The door's owner always has access; other characters need an entry in `door.accessList`.
-- @param player [Player The player]
-- @param door [Entity The door, or the door's parent when it has one]
-- @param access [Number The access level required (`DOOR_ACCESS_*`)]
-- @param isAccurate [Boolean `true` to require exactly that level instead of at least it]
-- @return [Boolean Whether the player has the access]
function GM:PlayerDoesHaveDoorAccess(player, door, access, isAccurate)
  if cw.entity:GetOwner(door) != player then
    local key = player:GetCharacterKey()

    if door.accessList and door.accessList[key] then
      if isAccurate then
        return door.accessList[key] == access
      else
        return door.accessList[key] >= access
      end
    end

    return false
  else
    return true
  end
end

--- Called after recognition is worked out, to override whether a player recognises another.
--
-- Catwork returns the computed value unchanged.
-- @param player [Player The player who may recognise the target]
-- @param target [Player The player who may be recognised]
-- @param status [Number The recognition level asked about (`RECOGNISE_*`)]
-- @param isAccurate [Boolean Whether the level must match exactly]
-- @param realValue [Boolean Whether the player recognises the target according to the saved names]
-- @return [Boolean Whether the player recognises the target]
function GM:PlayerDoesRecognisePlayer(player, target, status, isAccurate, realValue)
  return realValue
end

--- Called when a player attempts to lock an entity with the keys; doors need door access, other entities are allowed.
-- @param player [Player The player]
-- @param entity [Entity The entity]
-- @return [Boolean Whether the entity can be locked]
function GM:PlayerCanLockEntity(player, entity)
  if cw.entity:IsDoor(entity) then
    return cw.player:HasDoorAccess(player, entity)
  else
    return true
  end
end

--- Called after a player's class has been set; saves the class name in the character data.
-- @param player [Player The player]
-- @param newClass [Class The new class]
-- @param oldClass [Class The previous class]
-- @param noRespawn [Boolean Whether the player is not respawned]
-- @param addDelay [Boolean Whether a class change delay is added]
-- @param noModelChange [Boolean Whether the model is kept]
function GM:PlayerClassSet(player, newClass, oldClass, noRespawn, addDelay, noModelChange)
  player:SetCharacterData('Class', newClass.name)
end

--- Called when a player attempts to unlock an entity with the keys; doors need door access, other entities are allowed.
-- @param player [Player The player]
-- @param entity [Entity The entity]
-- @return [Boolean Whether the entity can be unlocked]
function GM:PlayerCanUnlockEntity(player, entity)
  if cw.entity:IsDoor(entity) then
    return cw.player:HasDoorAccess(player, entity)
  else
    return true
  end
end

--- Called when a player presses use on a door, to check whether they can open it.
--
-- Owned doors need door access and false doors cannot be used. When allowed, `PlayerUseDoor`
-- runs and the door is opened.
-- @param player [Player The player]
-- @param door [Entity The door]
-- @return [Boolean Whether the door opens]
function GM:PlayerCanUseDoor(player, door)
  if cw.entity:GetOwner(door) and !cw.player:HasDoorAccess(player, door) then
    return false
  end

  if cw.entity:IsDoorFalse(door) then
    return false
  end

  return true
end

--- Called when a player opens a door with use, just before it opens; does nothing by default.
-- @param player [Player The player]
-- @param door [Entity The door]
function GM:PlayerUseDoor(player, door) end

--- Called to check whether a player in a vehicle can use the entity they look at.
--
-- Allowed for doors and entities with `UsableInVehicle` set; while it returns `true` for the
-- looked at entity, the use key does not exit the vehicle.
-- @param player [Player The player]
-- @param entity [Entity The entity looked at]
-- @param vehicle [Vehicle The player's vehicle]
-- @return [Boolean Whether the entity can be used]
function GM:PlayerCanUseEntityInVehicle(player, entity, vehicle)
  if entity.UsableInVehicle or cw.entity:IsDoor(entity) then
    return true
  end
end

--- Called when a dead player's ragdoll is about to be set to decay; always allows it.
-- @param player [Player The player]
-- @param ragdoll [Entity The ragdoll]
-- @param seconds [Number The decay time]
-- @return [Boolean Whether the ragdoll decays]
function GM:PlayerCanRagdollDecay(player, ragdoll, seconds)
  return true
end

--- Called when a player attempts to exit a vehicle.
--
-- Refuses during `player.cwNextExitVehicle` and while the player looks at an entity they can
-- use from the vehicle. For chairs without a parent the player exits where they look, if that
-- is within 192 units; otherwise they cannot get out.
-- @param vehicle [Vehicle The vehicle]
-- @param player [Player The player]
-- @return [Boolean Whether the player can exit]
function GM:CanExitVehicle(vehicle, player)
  if player.cwNextExitVehicle and player.cwNextExitVehicle > CurTime() then
    return false
  end

  if IsValid(player) and player:IsPlayer() then
    local trace = player:GetEyeTraceNoCursor()

    if IsValid(trace.Entity) and !trace.Entity:IsVehicle() then
      if hook.Run('PlayerCanUseEntityInVehicle', player, trace.Entity, vehicle) then
        return false
      end
    end
  end

  if cw.entity:IsChairEntity(vehicle) and !IsValid(vehicle:GetParent()) then
    local trace = player:GetEyeTraceNoCursor()

    if trace.HitPos:Distance(player:GetShootPos()) <= 192 then
      trace = {
        start = trace.HitPos,
        endpos = trace.HitPos - Vector(0, 0, 1024),
        filter = { player, vehicle }
      }

      player.cwExitVehiclePos = util.TraceLine(trace).HitPos

      player:SetMoveType(MOVETYPE_NOCLIP)
    else
      return false
    end
  end

  return true
end

--- Called when a player leaves a vehicle; moves players leaving a chair to a safe position near where they looked.
-- @param player [Player The player]
-- @param vehicle [Vehicle The vehicle left]
function GM:PlayerLeaveVehicle(player, vehicle)
  timer.Simple(FrameTime() * 0.5, function()
    if IsValid(player) and !player:InVehicle() then
      if IsValid(vehicle) then
        if cw.entity:IsChairEntity(vehicle) then
          local position = player.cwExitVehiclePos or vehicle:GetPos()
          local targetPosition = cw.player:GetSafePosition(player, position, vehicle)

          if targetPosition then
            player:SetMoveType(MOVETYPE_NOCLIP)
            player:SetPos(targetPosition)
          end

          player:SetMoveType(MOVETYPE_WALK)
          player.cwExitVehiclePos = nil
        end
      end
    end
  end)
end

--- Called when a player attempts to enter a vehicle; always allows it.
-- @param player [Player The player]
-- @param vehicle [Vehicle The vehicle]
-- @param role [Number The seat role]
-- @return [Boolean Whether the player can enter]
function GM:CanPlayerEnterVehicle(player, vehicle, role)
  return true
end

--- Called when a player enters a vehicle; offsets human models (not `/player/` models) so they sit correctly.
-- @param player [Player The player]
-- @param vehicle [Vehicle The vehicle]
-- @param class [Number The seat role]
function GM:PlayerEnteredVehicle(player, vehicle, class)
  timer.Simple(FrameTime() * 0.5, function()
    if IsValid(player) then
      local model = player:GetModel()
      local class = cw.animation:GetModelClass(model)

      if IsValid(vehicle) and !string.find(model, '/player/') then
        if class == 'maleHuman' or class == 'femaleHuman' then
          if cw.entity:IsChairEntity(vehicle) then
            player:SetLocalPos(Vector(16.5438, -0.1642, -20.5493))
          else
            player:SetLocalPos(Vector(30.1880, 4.2020, -6.6476))
          end
        end
      end

      player:SetCollisionGroup(COLLISION_GROUP_PLAYER)
    end
  end)
end

--- Called when a player attempts to change class with `/SetClass`; refuses during the class change cooldown.
-- @param player [Player The player]
-- @param class [Class The class]
-- @return [Boolean Whether the class can be changed]
function GM:PlayerCanChangeClass(player, class)
  local curTime = CurTime()

  if player.cwNextChangeClass and curTime < player.cwNextChangeClass then
    cw.player:Notify(player, L(player, 'CannotChangeClassFor',
      math.ceil(player.cwNextChangeClass - curTime))
    )

    return false
  else
    return true
  end
end

--- Called on each wages payout, to check whether a player earns wages; always allows it.
-- @param player [Player The player]
-- @param cash [Number The wages amount]
-- @return [Boolean Whether the player earns wages; `PlayerEarnWagesCash` only runs when allowed]
function GM:PlayerCanEarnWagesCash(player, cash)
  return true
end

--- Called before positive wages are given to a player; return `false` to keep the cash from being given.
-- @param player [Player The player]
-- @param cash [Number The wages amount]
-- @param wagesName [String The name the wages are given under]
-- @return [Boolean Whether the cash is given]
function GM:PlayerGiveWagesCash(player, cash, wagesName)
  return true
end

--- Called after a player has earned wages; does nothing by default.
-- @param player [Player The player]
-- @param cash [Number The wages amount]
function GM:PlayerEarnWagesCash(player, cash) end

--- Called after Catwork has processed the map entities in `GM:InitPostEntity`; does nothing by default.
function GM:ClockworkInitPostEntity() end

--- Called when a player attempts to say something in character.
--
-- Dead or fallen over players cannot talk, unless they have a death code (for the death code
-- prompt). Return `false` to block the message.
-- @param player [Player The player]
-- @param text [String The message]
-- @return [Boolean Whether the message is sent]
function GM:PlayerCanSayIC(player, text)
  if (!player:Alive() or player:IsRagdolled(RAGDOLL_FALLENOVER)) and !cw.player:GetDeathCode(player, true) then
    cw.player:Notify(player, L(player, 'CannotActionRightNow'))

    return false
  else
    return true
  end
end

--- Called when a player attempts to say something out of character; always allows it.
-- @param player [Player The player]
-- @param text [String The message]
-- @return [Boolean Whether the message is sent]
function GM:PlayerCanSayOOC(player, text) return true end

--- Called when a player attempts to say something local out of character; always allows it.
-- @param player [Player The player]
-- @param text [String The message]
-- @return [Boolean Whether the message is sent]
function GM:PlayerCanSayLOOC(player, text) return true end

--- Called when a player attempts to use a command, before argument and access checks; always allows it.
-- @param player [Player The player]
-- @param commandTable [Command The command]
-- @param arguments [List<String> The command arguments]
-- @return [Boolean Whether the command runs]
function GM:PlayerCanUseCommand(player, commandTable, arguments)
  return true
end

--- Called when a player sends a chat message; replaces a command alias after the prefix with the real command.
-- @param player [Player The player]
-- @param text [String The message]
-- @param bPublic [Boolean Whether the message is not team only]
-- @return [String The rewritten message, or `nil` to leave it unchanged]
function GM:PlayerSay(player, text, bPublic)
  local prefix = config.Get('command_prefix'):Get()
  local prefixLength = string.len(prefix)

  if string.sub(text, 1, prefixLength) == prefix then
    local arguments = cw.core:ExplodeByTags(text, ' ', '"', '"', true)
    local command = string.sub(arguments[1] or '', prefixLength + 1)
    local realCommand = cw.command:GetAlias()[command]
    local commandEnd = prefixLength + string.len(command)

    -- Only the command itself is replaced, not the same text further into the message.
    if realCommand and string.sub(text, prefixLength + 1, commandEnd) == command then
      return prefix..realCommand..string.sub(text, commandEnd + 1)
    end
  end
end

--- Called when a player attempts to suicide; always refuses.
-- @param player [Player The player]
-- @return [Boolean Always `false`]
function GM:CanPlayerSuicide(player) return false end

--- Called when a player attempts to punt an entity with the gravity gun; allowed when `enable_gravgun_punt` is set.
-- @param player [Player The player]
-- @param entity [Entity The entity]
-- @return [Boolean Whether the punt is allowed]
function GM:GravGunPunt(player, entity)
  return config.Get('enable_gravgun_punt'):Get()
end

--- Called when a player attempts to pick up an entity with the gravity gun.
--
-- Non-admins can only pick up interactable entities (see `cw.entity:IsInteractable`); the base
-- gamemode decides the rest.
-- @param player [Player The player]
-- @param entity [Entity The entity]
-- @return [Boolean Whether the pickup is allowed]
function GM:GravGunPickupAllowed(player, entity)
  if IsValid(entity) then
    if !cw.player:IsAdmin(player) and !cw.entity:IsInteractable(entity) then
      return false
    else
      return self.BaseClass:GravGunPickupAllowed(player, entity)
    end
  end

  return false
end

--- Called when a player picks up an entity with the gravity gun; records who holds what.
-- @param player [Player The player]
-- @param entity [Entity The entity]
function GM:GravGunOnPickedUp(player, entity)
  player.cwIsHoldingEnt = entity
  entity.cwIsBeingHeld = player
end

--- Called when a player drops an entity with the gravity gun; clears who holds what.
-- @param player [Player The player]
-- @param entity [Entity The entity]
function GM:GravGunOnDropped(player, entity)
  player.cwIsHoldingEnt = nil
  entity.cwIsBeingHeld = nil
end

--- Called when a player attempts to unfreeze an entity.
--
-- Non-admins cannot unfreeze another character's props when prop protection is enabled, nor
-- non-interactable entities. Nobody can unfreeze a vehicle with a driver.
-- @param player [Player The player]
-- @param entity [Entity The entity]
-- @param physicsObject [PhysObj The physics object]
-- @return [Boolean Whether the entity can be unfrozen]
function GM:CanPlayerUnfreeze(player, entity, physicsObject)
  local bIsAdmin = cw.player:IsAdmin(player)

  if config.Get('enable_prop_protection'):Get() and !bIsAdmin then
    local ownerKey = entity:GetOwnerKey()

    if ownerKey and player:GetCharacterKey() != ownerKey then
      return false
    end
  end

  if !bIsAdmin and !cw.entity:IsInteractable(entity) then
    return false
  end

  if entity:IsVehicle() then
    if IsValid(entity:GetDriver()) then
      return false
    end
  end

  return true
end

--- Called when a player attempts to freeze an entity with the physics gun.
--
-- Players with the `o` flag can always freeze persistent entities. Otherwise non-admins cannot
-- freeze other characters' props under prop protection, chairs near doors, entities with
-- `PhysgunDisabled` or non-interactable entities, and nobody can freeze a penetrating entity.
-- @param weapon [Weapon The physics gun]
-- @param physicsObject [PhysObj The physics object]
-- @param entity [Entity The entity]
-- @param player [Player The player]
-- @return [Boolean Whether the entity is frozen]
function GM:OnPhysgunFreeze(weapon, physicsObject, entity, player)
  local bIsAdmin = cw.player:IsAdmin(player)

  -- Let operators freeze static entities.
  if IsValid(entity) and entity:GetPersistent() and cw.player:HasFlags(player, 'o') then
    return BaseClass.OnPhysgunFreeze(self, weapon, physicsObject, entity, player)
  end

  if config.GetVal('enable_prop_protection') and !bIsAdmin then
    local ownerKey = entity:GetOwnerKey()

    if ownerKey and player:GetCharacterKey() != ownerKey then
      return false
    end
  end

  if !bIsAdmin and cw.entity:IsChairEntity(entity) then
    local entities = ents.FindInSphere(entity:GetPos(), 64)

    for k, v in pairs(entities) do
      if cw.entity:IsDoor(v) then
        return false
      end
    end
  end

  if entity:GetPhysicsObject():IsPenetrating() then
    return false
  end

  if !bIsAdmin and entity.PhysgunDisabled then
    return false
  end

  if !bIsAdmin and !cw.entity:IsInteractable(entity) then
    return false
  else
    return self.BaseClass:OnPhysgunFreeze(weapon, physicsObject, entity, player)
  end
end

--- Called when a player attempts to pick up an entity with the physics gun.
--
-- Non-admins cannot pick up non-interactable entities, player ragdolls, other characters'
-- ragdolls or (under prop protection) props, chairs near doors, or map props unless
-- `enable_map_props_physgrab` is set, and nobody can grab players in vehicles or observers. On
-- pickup props lose collision while held when `prop_kill_protection` is set and get 60 seconds
-- of damage immunity; picked up players are switched to noclip movement.
-- @param player [Player The player]
-- @param entity [Entity The entity]
-- @return [Boolean Whether the pickup is allowed]
function GM:PhysgunPickup(player, entity)
  local bCanPickup = nil
  local bIsAdmin = cw.player:IsAdmin(player)

  if !bIsAdmin and !cw.entity:IsInteractable(entity) then
    return false
  end

  if !bIsAdmin and !config.Get('enable_map_props_physgrab'):Get() and cw.entity:IsMapEntity(entity) then
    return false
  end

  if !bIsAdmin and cw.entity:IsPlayerRagdoll(entity) then
    return false
  end

  if !bIsAdmin and entity:GetClass() == 'prop_ragdoll' then
    local ownerKey = entity:GetOwnerKey()

    if ownerKey and player:GetCharacterKey() != ownerKey then
      return false
    end
  end

  if !bIsAdmin then
    bCanPickup = self.BaseClass:PhysgunPickup(player, entity)
  else
    bCanPickup = true
  end

  if cw.entity:IsChairEntity(entity) and !bIsAdmin then
    local entities = ents.FindInSphere(entity:GetPos(), 256)

    for k, v in pairs(entities) do
      if cw.entity:IsDoor(v) then
        return false
      end
    end
  end

  if config.Get('enable_prop_protection'):Get() and !bIsAdmin then
    local ownerKey = entity:GetOwnerKey()

    if ownerKey and player:GetCharacterKey() != ownerKey then
      bCanPickup = false
    end
  end

  if entity:IsPlayer() and entity:InVehicle() or entity.cwObserverMode then
    bCanPickup = false
  end

  if bCanPickup then
    player.cwIsHoldingEnt = entity
    entity.cwIsBeingHeld = player

    if !entity:IsPlayer() then
      if config.Get('prop_kill_protection'):Get()
      and !entity.cwLastCollideGroup then
        cw.entity:StopCollisionGroupRestore(entity)
        entity.cwLastCollideGroup = entity:GetCollisionGroup()
        entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
      end

      entity.cwDamageImmunity = CurTime() + 60
    elseif !entity.cwMoveType then
      entity.cwMoveType = entity:GetMoveType()
      entity:SetMoveType(MOVETYPE_NOCLIP)
    end

    return true
  else
    return false
  end
end

--- Called when a player drops an entity with the physics gun.
--
-- Restores the prop's collision group or the player's movement and gives the entity 60 seconds
-- of damage immunity.
-- @param player [Player The player]
-- @param entity [Entity The entity]
function GM:PhysgunDrop(player, entity)
  if !entity:IsPlayer() and entity.cwLastCollideGroup then
    cw.entity:ReturnCollisionGroup(
      entity, entity.cwLastCollideGroup
    )

    entity.cwLastCollideGroup = nil
  elseif entity.cwMoveType then
    entity:SetMoveType(MOVETYPE_WALK)
    entity.cwMoveType = nil
  end

  entity.cwDamageImmunity = CurTime() + 60
  player.cwIsHoldingEnt = nil
  entity.cwIsBeingHeld = nil
end

--- Called when a player attempts to spawn an NPC.
--
-- Requires the `n` flag, a living, standing player, and admin rights.
-- @param player [Player The player]
-- @param model [String The NPC class]
-- @return [Boolean Whether the NPC can be spawned]
function GM:PlayerSpawnNPC(player, model)
  if !cw.player:HasFlags(player, 'n') then
    return false
  end

  if !player:Alive() or player:IsRagdolled() then
    cw.player:Notify(player, L(player, 'CannotActionRightNow'))

    return false
  end

  if !cw.player:IsAdmin(player) then
    return false
  else
    return true
  end
end

--- Called when an NPC has been killed; overridden to do nothing (no kill notice).
-- @param entity [NPC The NPC]
-- @param attacker [Entity The attacker]
-- @param inflictor [Entity The inflictor]
function GM:OnNPCKilled(entity, attacker, inflictor) end

--- Called to get who is holding an entity.
-- @param entity [Entity The entity]
-- @return [Any The player holding it with a gravity or physics gun, or whether a player holds it with use]
function GM:GetEntityBeingHeld(entity)
  return entity.cwIsBeingHeld or entity:IsPlayerHolding()
end

--- Called when an entity is removed, except while the server shuts down.
--
-- A belongings ragdoll with items or cash spawns a `cw_belongings` entity with them. Props
-- removed within their refund window refund their cost to the character that spawned them, and
-- the entity is removed from the property lists.
-- @param entity [Entity The entity]
function GM:EntityRemoved(entity)
  if !cw.core:IsShuttingDown() then
    if IsValid(entity) then
      if entity:GetClass() == 'prop_ragdoll' then
        if entity.cwIsBelongings and entity.cwInventory and entity.cwCash
        and (!cw.inventory:IsEmpty(entity.cwInventory) or entity.cwCash > 0) then
          local belongings = ents.Create('cw_belongings')

          belongings:SetAngles(Angle(0, 0, -90))
          belongings:SetData(entity.cwInventory, entity.cwCash)
          belongings:SetPos(entity:GetPos() + Vector(0, 0, 32))
          belongings:Spawn()

          entity.cwInventory = nil
          entity.cwCash = nil
        end
      end

      local allProperty = cw.player:GetAllProperty()
      local entIndex = entity:EntIndex()
      local refundTab = entity.cwGiveRefundTab

      -- Only the character that paid for the prop gets the refund.
      if refundTab and CurTime() <= refundTab[1] and IsValid(refundTab[2])
      and refundTab[2]:GetCharacterKey() == refundTab[4] then
        cw.player:GiveCash(refundTab[2], refundTab[3], L'PropRefund')
      end

      allProperty[entIndex] = nil
    end

    cw.entity:ClearProperty(entity)
  end
end

--- Called when a player picks an option from an entity's menu.
--
-- Handles taking, using, examining and unloading ammo from `cw_item` entities (refusing to
-- take, use or unload items dropped by another character, and running `PlayerPickupItem`),
-- forwards other item options to the item's `EntityHandleMenuOption`, opens `cw_belongings` and
-- `cw_shipment` storage, and takes `cw_cash`.
-- @param player [Player The player]
-- @param entity [Entity The entity]
-- @param option [String The option's display name]
-- @param arguments [String The option's argument, such as `cw.itemTake`]
function GM:EntityHandleMenuOption(player, entity, option, arguments)
  local class = entity:GetClass()

  if class == 'cw_item' and (arguments == 'cw.itemTake' or arguments == 'cw.itemUse') then
    if cw.entity:BelongsToAnotherCharacter(player, entity) then
      cw.player:Notify(player, L(player, 'DroppedItemsOtherChar'))
      return
    end

    local itemTable = entity.cwItemTable
    local bQuickUse = (arguments == 'cw.itemUse')

    if itemTable then
      local bDidPickupItem = true
      local bCanPickup = (!itemTable.CanPickup or itemTable:CanPickup(player, bQuickUse, entity))

      if bCanPickup != false then
        player:SetItemEntity(entity)

        if bQuickUse then
          itemTable = player:GiveItem(itemTable, true)

          if !cw.player:InventoryAction(player, itemTable, 'use') then
            player:TakeItem(itemTable, true)
            bDidPickupItem = false
          else
            player:FakePickup(entity)
          end
        else
          local bSuccess, fault = player:GiveItem(itemTable)

          if !bSuccess then
            cw.player:Notify(player, fault)
            bDidPickupItem = false
          else
            player:FakePickup(entity)
          end
        end

        hook.Run(
          'PlayerPickupItem', player, itemTable, entity, bQuickUse
        )

        if bDidPickupItem then
          if !itemTable.OnPickup or itemTable:OnPickup(player, bQuickUse, entity) != false then
            entity:Remove()
          end
        end

        local pickupSound = itemTable.pickupSound or 'physics/body/body_medium_impact_soft'..math.random(1, 7)..'.wav'

        if type(pickupSound) == 'table' then
          pickupSound = pickupSound[math.random(1, #pickupSound)]
        end

        player:EmitSound(pickupSound)

        player:SetItemEntity(nil)
      end
    end
  elseif class == 'cw_item' and arguments == 'cw.itemExamine' then
    local itemTable = entity.cwItemTable

    if itemTable then
      local examineText = itemTable.description

      if itemTable.GetEntityExamineText then
        examineText = itemTable:GetEntityExamineText(entity)
      end

      cw.player:Notify(player, examineText)
    end
  elseif class == 'cw_item' and arguments == 'cw.itemAmmo' then
    if cw.entity:BelongsToAnotherCharacter(player, entity) then
      cw.player:Notify(player, L(player, 'DroppedItemsOtherChar'))
      return
    end

    local itemTable = entity.cwItemTable

    if item.IsWeapon(itemTable) then
      if itemTable:HasSecondaryClip() or itemTable:HasPrimaryClip() then
        local clipOne = tonumber(itemTable:GetData('ClipOne')) or 0
        local clipTwo = tonumber(itemTable:GetData('ClipTwo')) or 0

        if clipTwo > 0 then
          player:GiveAmmo(clipTwo, itemTable.secondaryAmmoClass)
        end

        if clipOne > 0 then
          player:GiveAmmo(clipOne, itemTable.primaryAmmoClass)
        end

        itemTable:SetData('ClipOne', 0)
        itemTable:SetData('ClipTwo', 0)

        player:FakePickup(entity)
      end
    end
  elseif class == 'cw_item' then
    local itemTable = entity.cwItemTable

    if itemTable and itemTable.EntityHandleMenuOption then
      itemTable:EntityHandleMenuOption(player, entity, option, arguments)
    end
  elseif entity:GetClass() == 'cw_belongings' and arguments == 'cwBelongingsOpen' then
    player:EmitSound('physics/body/body_medium_impact_soft'..math.random(1, 7)..'.wav')

    cw.storage:Open(player, {
      name = '#Storage_Belongings',
      cash = entity.cwCash,
      weight = 100,
      space = 200,
      entity = entity,
      distance = 192,
      inventory = entity.cwInventory,
      isOneSided = true,
      OnGiveCash = function(player, storageTable, cash)
        entity.cwCash = storageTable.cash
      end,
      OnTakeCash = function(player, storageTable, cash)
        entity.cwCash = storageTable.cash
      end,
      OnClose = function(player, storageTable, entity)
        -- Taking the last item of a kind leaves its empty list behind, so the lists are not just counted.
        if IsValid(entity) and cw.inventory:IsEmpty(entity.cwInventory) and (entity.cwCash or 0) == 0 then
          entity:Explode(entity:BoundingRadius() * 2)
          entity:Remove()
        end
      end,
      CanGiveItem = function(player, storageTable, itemTable)
        return false
      end
    })
  elseif class == 'cw_shipment' and arguments == 'cwShipmentOpen' then
    player:EmitSound('physics/body/body_medium_impact_soft'..math.random(1, 7)..'.wav')
    player:FakePickup(entity)

    cw.storage:Open(player, {
      name = '#Storage_Shipment',
      weight = entity.cwWeight,
      space = entity.cwSpace,
      entity = entity,
      distance = 192,
      inventory = entity.cwInventory,
      isOneSided = true,
      OnClose = function(player, storageTable, entity)
        if IsValid(entity) and cw.inventory:IsEmpty(entity.cwInventory) then
          entity:Explode(entity:BoundingRadius() * 2)
          entity:Remove()
        end
      end,
      CanGiveItem = function(player, storageTable, itemTable)
        return false
      end
    })
  elseif class == 'cw_cash' and arguments == 'cwCashTake' then
    if cw.entity:BelongsToAnotherCharacter(player, entity) then
      cw.player:Notify(player, L(player, 'DroppedCashOtherChar', cw.option:GetKey('name_cash', true)))
      return
    end

    cw.player:GiveCash(player, entity.cwAmount, cw.option:GetKey('name_cash'))
    player:EmitSound('physics/body/body_medium_impact_soft'..math.random(1, 7)..'.wav')
    player:FakePickup(entity)

    entity:Remove()
  end
end

--- Called after a player has spawned a prop.
--
-- When `scale_prop_cost` is above zero (and the player is not observing), charges a cost based
-- on the prop's size, adjustable through `PlayerAdjustPropCostInfo`, and removes the prop if the
-- player cannot afford it. The cost is refunded if the prop is removed within 10 seconds. Sets
-- the prop's owner key, logs the spawn and gives prop kill protection immunity.
-- @param player [Player The player]
-- @param model [String The prop model]
-- @param entity [Entity The prop]
function GM:PlayerSpawnedProp(player, model, entity)
  if IsValid(entity) then
    local scalePropCost = config.Get('scale_prop_cost'):Get()

    if player.cwObserverMode then scalePropCost = 0 end

    if scalePropCost > 0 then
      local cost = math.ceil(math.max((entity:BoundingRadius() / 2) * scalePropCost, 1))
      local info = { cost = cost, name = L'PropCost_Name' }

      hook.Run('PlayerAdjustPropCostInfo', player, entity, info)

      if cw.player:CanAfford(player, info.cost) then
        cw.player:GiveCash(player, -info.cost, info.name)
        entity.cwGiveRefundTab = { CurTime() + 10, player, info.cost, player:GetCharacterKey() }
      else
        cw.player:Notify(
          player,
          L(player, 'YouNeedAnother', cw.core:FormatCash(info.cost - player:GetCash(), nil, true))
        )
        entity:Remove()
        return
      end
    end

    if IsValid(entity) then
      self.BaseClass:PlayerSpawnedProp(player, model, entity)
      entity:SetOwnerKey(player:GetCharacterKey())

      if IsValid(entity) then
        cw.core:PrintLog(LOGTYPE_URGENT, player:Name().." has spawned '"..tostring(model).."'.")

        if config.Get('prop_kill_protection'):Get() then
          entity.cwDamageImmunity = CurTime() + 60
        end
      end
    end
  end
end

--- Called when a player attempts to spawn a prop; requires the `e` flag and a living, standing player.
-- @param player [Player The player]
-- @param model [String The prop model]
-- @return [Boolean Whether the prop can be spawned]
function GM:PlayerSpawnProp(player, model)
  if !cw.player:HasFlags(player, 'e') then
    return false
  end

  if !player:Alive() or player:IsRagdolled() then
    cw.player:Notify(player, L(player, 'CannotActionRightNow'))
    return false
  end

  if cw.player:IsAdmin(player) then
    return true
  end

  return self.BaseClass:PlayerSpawnProp(player, model)
end

--- Called when a player attempts to spawn a ragdoll; requires the `r` flag, admin rights and a living, standing player.
-- @param player [Player The player]
-- @param model [String The ragdoll model]
-- @return [Boolean Whether the ragdoll can be spawned]
function GM:PlayerSpawnRagdoll(player, model)
  if !cw.player:HasFlags(player, 'r') then return false end

  if !player:Alive() or player:IsRagdolled() then
    cw.player:Notify(player, L(player, 'CannotActionRightNow'))

    return false
  end

  if !cw.player:IsAdmin(player) then
    return false
  else
    return true
  end
end

--- Called when a player attempts to spawn an effect; requires a living, standing player and admin rights.
-- @param player [Player The player]
-- @param model [String The effect model]
-- @return [Boolean Whether the effect can be spawned]
function GM:PlayerSpawnEffect(player, model)
  if !player:Alive() or player:IsRagdolled() then
    cw.player:Notify(player, L(player, 'CannotActionRightNow'))

    return false
  end

  if !cw.player:IsAdmin(player) then
    return false
  else
    return true
  end
end

--- Called when a player attempts to spawn a vehicle.
--
-- Chairs and seats need the `c` flag, other vehicles the `C` flag, and the player must be alive
-- and standing. Admins can always spawn; others are subject to the base gamemode's limits.
-- @param player [Player The player]
-- @param model [String The vehicle model]
-- @return [Boolean Whether the vehicle can be spawned]
function GM:PlayerSpawnVehicle(player, model)
  if !string.find(model, 'chair') and !string.find(model, 'seat') then
    if !cw.player:HasFlags(player, 'C') then
      return false
    end
  elseif !cw.player:HasFlags(player, 'c') then
    return false
  end

  if !player:Alive() or player:IsRagdolled() then
    cw.player:Notify(player, L(player, 'CannotActionRightNow'))

    return false
  end

  if cw.player:IsAdmin(player) then
    return true
  end

  return self.BaseClass:PlayerSpawnVehicle(player, model)
end

--- Called when a player attempts to use a tool.
--
-- Admins can always use tools. Others cannot target non-interactable entities, player ragdolls
-- or (under prop protection) other characters' props, cannot nail into such entities, cannot
-- remove map entities or contraptions containing them, and cannot use `dynamite` or
-- `duplicator`; the base gamemode decides the rest.
-- @param player [Player The player]
-- @param trace [Map The tool trace result]
-- @param tool [String The tool mode]
-- @param toolTable [Map The tool object]
-- @param button [Number The mouse button used]
-- @return [Boolean Whether the tool can be used]
function GM:CanTool(player, trace, tool, toolTable, button)
  local bIsAdmin = cw.player:IsAdmin(player)

  if IsValid(trace.Entity) then
    local bPropProtectionEnabled = config.Get('enable_prop_protection'):Get()
    local characterKey = player:GetCharacterKey()

    if !bIsAdmin and !cw.entity:IsInteractable(trace.Entity) then
      return false
    end

    if !bIsAdmin and cw.entity:IsPlayerRagdoll(trace.Entity) then
      return false
    end

    if bPropProtectionEnabled and !bIsAdmin then
      local ownerKey = trace.Entity:GetOwnerKey()

      if ownerKey and characterKey != ownerKey then
        return false
      end
    end

    if !bIsAdmin then
      if tool == 'nail' then
        local newTrace = {}

        newTrace.start = trace.HitPos
        newTrace.endpos = trace.HitPos + player:GetAimVector() * 16
        newTrace.filter = { player, trace.Entity }

        newTrace = util.TraceLine(newTrace)

        if IsValid(newTrace.Entity) then
          if !cw.entity:IsInteractable(newTrace.Entity) or cw.entity:IsPlayerRagdoll(newTrace.Entity) then
            return false
          end

          if bPropProtectionEnabled then
            local ownerKey = newTrace.Entity:GetOwnerKey()

            if ownerKey and characterKey != ownerKey then
              return false
            end
          end
        end
      elseif tool == 'remover' and player:KeyDown(IN_ATTACK2) and !player:KeyDownLast(IN_ATTACK2) then
        if !trace.Entity:IsMapEntity() then
          local entities = constraint.GetAllConstrainedEntities(trace.Entity)

          for k, v in pairs(entities) do
            if v:IsMapEntity() or cw.entity:IsPlayerRagdoll(v) then
              return false
            end

            if bPropProtectionEnabled then
              local ownerKey = v:GetOwnerKey()

              if ownerKey and characterKey != ownerKey then
                return false
              end
            end
          end
        else
          return false
        end
      end
    end
  end

  if !bIsAdmin then
    if tool == 'dynamite' or tool == 'duplicator' then
      return false
    end

    return self.BaseClass:CanTool(player, trace, tool, toolTable, button)
  else
    return true
  end
end

--- Called when a player attempts to use the property menu; only living, standing admins can.
-- @param player [Player The player]
-- @param property [String The property name]
-- @param entity [Entity The entity]
-- @return [Boolean Whether the property can be used]
function GM:CanProperty(player, property, entity)
  local bIsAdmin = cw.player:IsAdmin(player)

  if !player:Alive() or player:IsRagdolled() or !bIsAdmin then
    return false
  end

  return self.BaseClass:CanProperty(player, property, entity)
end

--- Called when a player attempts to drive an entity; only living, standing admins can.
-- @param player [Player The player]
-- @param entity [Entity The entity]
-- @return [Boolean Whether the entity can be driven]
function GM:CanDrive(player, entity)
  local bIsAdmin = cw.player:IsAdmin(player)

  if !player:Alive() or player:IsRagdolled() or !bIsAdmin then
    return false
  end

  return self.BaseClass:CanDrive(player, entity)
end

--- Called when a player attempts to noclip; only super admins who are not ragdolled can.
-- @param player [Player The player]
-- @return [Boolean Whether noclip toggles]
function GM:PlayerNoClip(player)
  if player:IsRagdolled() then
    return false
  elseif player:IsSuperAdmin() then
    return true
  else
    return false
  end
end

--- Called when a player's character has initialized, while it loads.
--
-- Clears and resends the player's inventory, attributes and limb damage, assigns the default
-- class when needed, queues the starter hints, sends `CharacterInit` to the client, and sets the
-- faction rank (the default or lowest one, or `SCN` when the name contains `SCN`), applying the
-- rank's class and model.
-- @param player [Player The player]
function GM:PlayerCharacterInitialized(player)
  cable.send(player, 'InvClear', true)
  cable.send(player, 'AttrClear', true)
  cable.send(player, 'ReceiveLimbDamage', player:GetCharacterData('LimbData'))

  if !cw.class:FindByID(player:Team()) and !player:GetCharacterData('Class') then
    cw.class:AssignToDefault(player)
  end

  player.cwAttrProgress = player.cwAttrProgress or {}
  player.cwAttrProgressTime = 0

  for k, v in pairs(cw.attribute:GetAll()) do
    player:UpdateAttribute(k)
  end

  for k, v in pairs(player:GetAttributes()) do
    player.cwAttrProgress[k] = math.floor(v.progress)
  end

  local startHintsDelay = 4
  local starterHintsTable = {
    'Directory',
    'Give Name',
    'Target Recognises',
    'Raise Weapon'
  }

  for k, v in pairs(starterHintsTable) do
    local hintTable = cw.hint:Find(v)

    if hintTable and !player:GetData('Hint'..k) then
      if !hintTable.Callback or hintTable.Callback(player) != false then
        timer.Simple(startHintsDelay, function()
          if IsValid(player) then
            cw.hint:Send(player, hintTable.text, 30)
            player:SetData('Hint'..k, true)
          end
        end)

        startHintsDelay = startHintsDelay + 30
      end
    end
  end

  if startHintsDelay > 4 then
    player.cwViewStartHints = true

    timer.Simple(startHintsDelay, function()
      if IsValid(player) then
        player.cwViewStartHints = false
      end
    end)
  end

  timer.Simple(FrameTime() * 0.5, function()
    if IsValid(player) and player:HasInitialized() then
      cw.inventory:SendUpdateAll(player)
      player:NetworkAccessories()
    end
  end)

  cable.send(player, 'CharacterInit', player:GetCharacterKey())

  local playerFaction = player:GetFaction()
  local spawnRank = _faction.GetDefaultRank(playerFaction) or _faction.GetLowestRank(playerFaction)

  player:SetFactionRank(player:GetFactionRank() or spawnRank)

  if string.find(player:Name(), 'SCN') then
    player:SetFactionRank('SCN')
  end

  local rankName, rankTable = player:GetFactionRank()

  if rankTable then
    if rankTable.class and cw.class:GetAll()[rankTable.class] then
      cw.class:Set(player, rankTable.class)
    end

    if rankTable.model then
      player:SetModel(rankTable.model)
    end
  end
end

--- Called when a player has used their death code, before it is taken; does nothing by default.
-- @param player [Player The player]
-- @param commandTable [Command The command that used the death code]
-- @param arguments [List<String> The command arguments]
function GM:PlayerDeathCodeUsed(player, commandTable, arguments) end

--- Called after a player has created a character, before it is added to the character menu; does nothing by default.
-- @param player [Player The player]
-- @param character [Character The new character]
function GM:PlayerCharacterCreated(player, character) end

--- Called when a player's character has unloaded.
--
-- Schedules the character's property for removal, disables it, resets the ragdoll, closes
-- storage and unassigns the team. When called by `GM:PlayerDisconnected`, returning `true`
-- keeps the character from being saved.
-- @param player [Player The player]
function GM:PlayerCharacterUnloaded(player)
  cw.player:SetupRemovePropertyDelays(player)
  cw.player:DisableProperty(player)
  cw.player:SetRagdollState(player, RAGDOLL_RESET)
  cw.storage:Close(player, true)
  player:SetTeam(TEAM_UNASSIGNED)
end

--- Called when a player's character has loaded.
--
-- Resets the player's per-character state and movement values, runs
-- `PlayerRestoreCharacterData` and `PlayerCharacterInitialized`, restores recognised names and
-- property, and marks the player initialized. Clears any stored `OnNextLoad` payload without
-- running it, runs each item's `OnRestorePlayerGear`, gives the saved player flags and restores
-- the saved class.
-- @param player [Player The player]
function GM:PlayerCharacterLoaded(player)
  player:SetNetVar('InvWeight', config.Get('default_inv_weight'):Get())
  player:SetNetVar('InvSpace', config.Get('default_inv_space'):Get())
  player.cwCharLoadedTime = CurTime()
  player.cwCrouchedSpeed = config.Get('crouched_speed'):Get()
  player.cwClipTwoInfo = { weapon = NULL, ammo = 0 }
  player.cwClipOneInfo = { weapon = NULL, ammo = 0 }
  player.cwInitialized = true
  player.cwAttrBoosts = player.cwAttrBoosts or {}
  player.cwRagdollTab = player.cwRagdollTab or {}
  player.cwSpawnWeps = player.cwSpawnWeps or {}
  player.cwFirstSpawn = true
  player.cwLightSpawn = false
  player.cwChangeClass = false
  player.cwInfoTable = player.cwInfoTable or {}
  player.cwSpawnAmmo = player.cwSpawnAmmo or {}
  player.cwJumpPower = config.Get('jump_power'):Get()
  player.cwWalkSpeed = config.Get('walk_speed'):Get()
  player.cwRunSpeed = config.Get('run_speed'):Get()

  hook.Run('PlayerRestoreCharacterData', player, player:QueryCharacter('Data'))

  cw.player:SetCharacterMenuState(player, CHARACTER_MENU_CLOSE)

  hook.Run('PlayerCharacterInitialized', player)

  cw.player:RestoreRecognisedNames(player)
  cw.player:ReturnProperty(player)
  cw.player:SetInitialized(player, true)

  player.cwFirstSpawn = false

  local charactersTable = config.Get('mysql_characters_table'):Get()
  local schemaFolder = cw.core:GetSchemaFolder()
  local characterID = player:GetCharacterID()
  local onNextLoad = player:QueryCharacter('OnNextLoad')
  local steamID = player:SteamID()
  local playerFlags = player:GetPlayerFlags()

  -- Stored OnNextLoad payloads are no longer executed: the column is only cleared.
  if onNextLoad != nil and onNextLoad != '' then
    local queryObj = cw.database:Update(charactersTable)
      queryObj:Update('_OnNextLoad', '')
      queryObj:Where('_Schema', schemaFolder)
      queryObj:Where('_SteamID', steamID)
      queryObj:Where('_CharacterID', characterID)
    queryObj:Execute()

    player:SetCharacterData('OnNextLoad', '', true)

    ErrorNoHalt(
      '[Catwork] Discarded a stored OnNextLoad payload ('..#tostring(onNextLoad)..' bytes) for '
      ..steamID..' (character #'..tostring(characterID)..').\n'
    )
  end

  local itemsList = cw.inventory:GetAsItemsList(
    player:GetInventory()
  )

  for k, v in pairs(itemsList) do
    if v.OnRestorePlayerGear then
      v:OnRestorePlayerGear(player)
    end
  end

  if playerFlags then
    cw.player:GiveFlags(player, playerFlags)
  end

  local className = player:GetCharacterData('Class')

  if className then
    local class = cw.class:FindByID(className)

    -- The saved class may have been removed from the schema since.
    if class then
      cw.class:Set(player, class.index, nil, true)
    end
  end
end

--- Called after a player's property has been returned to their character; does nothing by default.
-- @param player [Player The player]
function GM:PlayerReturnProperty(player) end

--- Called when the config has been sent to a player.
--
-- Runs `PlayerSendDataStreamInfo`, then tells clients to start data streaming; bots skip
-- straight to `PlayerDataStreamInfoSent`.
-- @param player [Player The player]
function GM:PlayerConfigInitialized(player)
  hook.Run('PlayerSendDataStreamInfo', player)

  if !player:IsBot() then
    timer.Simple(FrameTime() * 32, function()
      if IsValid(player) then
        cable.send(player, 'DataStreaming', true)
      end
    end)
  else
    hook.Run('PlayerDataStreamInfoSent', player)
  end
end

--- Called after a player has spoken on the radio; does nothing by default.
-- @param player [Player The player]
-- @param text [String The message]
-- @param listeners [List<Player> Players who heard it over the radio]
-- @param eavesdroppers [List<Player> Players nearby who overheard it]
function GM:PlayerRadioUsed(player, text, listeners, eavesdroppers) end

--- Called for each weapon a dead player drops, to adjust how it is dropped.
-- @param player [Player The player]
-- @param info [Map `itemTable`, `position` and `angles` of the dropped item, which can be changed]
-- @return [Boolean Whether the weapon item entity is created]
function GM:PlayerAdjustDropWeaponInfo(player, info)
  return true
end

--- Called when a player creates a character, to adjust or refuse the new character; does nothing by default.
-- @param player [Player The player]
-- @param info [Map The new character, which can be changed]
-- @param data [Map The data the client sent]
-- @return [Any `false` to refuse with a generic fault, or a fault string to refuse with that message]
function GM:PlayerAdjustCharacterCreationInfo(player, info, data) end

--- Called when a player orders a shipment with `/OrderShipment`, to adjust the ordered item; does nothing by default.
-- @param player [Player The player]
-- @param itemTable [Item The item being ordered]
function GM:PlayerAdjustOrderItemTable(player, itemTable) end

--- Called after a player punches with `cw_hands`, to adjust the delay before the next punch; does nothing by default.
-- @param player [Player The player]
-- @param info [Map `primaryFire` and `secondaryFire`, the delays in seconds, which can be changed]
function GM:PlayerAdjustNextPunchInfo(player, info) end

--- Called when a player runs an inventory action that Catwork does not handle; does nothing by default.
-- @param player [Player The player]
-- @param itemTable [Item The item]
-- @param itemFunction [String The action name]
function GM:PlayerUseUnknownItemFunction(player, itemTable, itemFunction) end

--- Called for each of a player's characters as they are loaded into the character menu; does nothing by default.
-- @param player [Player The player]
-- @param character [Character The character, which can be changed]
-- @return [Boolean `true` to delete the character instead of listing it]
function GM:PlayerAdjustCharacterTable(player, character) end

--- Called before a character is sent to the character menu, to adjust how it is shown.
--
-- Catwork uses the faction rank's model if it has one.
-- @param player [Player The player]
-- @param character [Character The character]
-- @param info [Map What the menu shows: `name`, `model`, `banned`, `faction`, `characterID`, `details` and so on]
function GM:PlayerAdjustCharacterScreenInfo(player, character, info)
  local playerRank, rank = player:GetFactionRank(character)

  if rank and rank.model then
    info.model = rank.model
  end
end

--- Called when a player spawns a prop that costs cash, to adjust the cost; does nothing by default.
-- @param player [Player The player]
-- @param entity [Entity The prop]
-- @param info [Map `cost` and `name` (the reason shown for the payment), which can be changed]
function GM:PlayerAdjustPropCostInfo(player, entity, info) end

--- Called when a player dies, to adjust their respawn time; does nothing by default.
-- @param player [Player The player]
-- @param info [Map `attacker`, `inflictor`, `damageInfo` and `spawnTime`, which can be changed]
function GM:PlayerAdjustDeathInfo(player, info) end

--- Called when chat box info should be adjusted; logs in-character and LOOC messages.
-- @param info [Map The message info, with `class`, `speaker` and `text`]
function GM:ChatBoxAdjustInfo(info)
  if info.class == 'ic' then
    cw.core:PrintLog(LOGTYPE_GENERIC, info.speaker:Name()..' says: "'..info.text..'"')
  elseif info.class == 'looc' then
    cw.core:PrintLog(LOGTYPE_GENERIC, '[LOOC] '..info.speaker:Name()..': '..info.text)
  end
end

--- Called when a player speaks on the radio, to choose who hears it; does nothing by default.
-- @param player [Player The player]
-- @param info [Map `text`, `noEavesdrop` and `listeners`; add players to `listeners` to let them hear it]
function GM:PlayerAdjustRadioInfo(player, info) end

--- Called when a player kills another player, to check whether the killer gains a frag; always allows it.
-- @param player [Player The killer]
-- @param victim [Player The victim]
-- @return [Boolean Whether a frag is added]
function GM:PlayerCanGainFrag(player, victim) return true end

--- Called just after a player spawns, from `GM:PlayerSpawn`.
--
-- On the first spawn of a character it restores saved health, armor and attribute boosts;
-- later spawns clear them from the character data. Sets the player's target name to their
-- faction.
-- @param player [Player The player]
-- @param lightSpawn [Boolean Whether this was a light spawn]
-- @param changeClass [Boolean Whether the spawn is from a class change]
-- @param firstSpawn [Boolean Whether this is the character's first spawn]
function GM:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
  if firstSpawn then
    local attrBoosts = player:GetCharacterData('AttrBoosts')
    local health = player:GetCharacterData('Health')
    local armor = player:GetCharacterData('Armor')

    if health and health > 1 then
      player:SetHealth(health)
    end

    if armor and armor > 1 then
      player:SetArmor(armor)
    end

    if attrBoosts then
      for k, v in pairs(attrBoosts) do
        for k2, v2 in pairs(v) do
          cw.attributes:Boost(player, k2, k, v2.amount, v2.duration)
        end
      end
    end
  else
    player:SetCharacterData('AttrBoosts', nil)
    player:SetCharacterData('Health', nil)
    player:SetCharacterData('Armor', nil)
  end

  player:Fire('targetname', player:GetFaction(), 0)
end

--- Called just before a player would take damage; does nothing by default.
-- @param player [Player The player]
-- @param attacker [Entity The attacker]
-- @param inflictor [Entity The inflictor]
-- @param damageInfo [CTakeDamageInfo The damage]
function GM:PrePlayerTakeDamage(player, attacker, inflictor, damageInfo) end

--- Called when a player would take damage; players in noclip take none.
-- @param player [Player The player]
-- @param attacker [Entity The attacker]
-- @param inflictor [Entity The inflictor]
-- @param damageInfo [CTakeDamageInfo The damage]
-- @return [Boolean Whether the damage is applied]
function GM:PlayerShouldTakeDamage(player, attacker, inflictor, damageInfo)
  return !cw.player:IsNoClipping(player)
end

--- Called when a player is hit by a trace attack; remembers the hit group for limb damage and pain sounds.
-- @param player [Player The player]
-- @param damageInfo [CTakeDamageInfo The damage]
-- @param direction [Vector The attack direction]
-- @param trace [Map The trace result]
-- @return [Boolean Always `false`]
function GM:PlayerTraceAttack(player, damageInfo, direction, trace)
  player.cwLastHitGroup = trace.HitGroup
  return false
end

--- Called just before a player dies.
--
-- Drops the player's weapons, clears action and drunkenness, turns the body into a knocked out
-- ragdoll that decays after `body_decay_time` (600 seconds when that is 0), clears recognised
-- names and the name when the death hooks allow, plays the death sound, strips weapons and ammo,
-- adds a death and gives the killer a frag when `PlayerCanGainFrag` allows.
-- @param player [Player The player]
-- @param attacker [Entity The killer]
-- @param damageInfo [CTakeDamageInfo The fatal damage]
function GM:DoPlayerDeath(player, attacker, damageInfo)
  cw.player:DropWeapons(player, attacker)
  cw.player:SetAction(player, false)
  cw.player:SetDrunk(player, false)

  local deathSound = hook.Run('PlayerPlayDeathSound', player, player:GetGender())
  local decayTime = config.Get('body_decay_time'):Get()

  if decayTime > 0 then
    cw.player:SetRagdollState(
      player,
      RAGDOLL_KNOCKEDOUT,
      nil,
      decayTime,
      cw.core:ConvertForce(damageInfo:GetDamageForce() * 32)
    )
  else
    cw.player:SetRagdollState(
      player,
      RAGDOLL_KNOCKEDOUT,
      nil,
      600,
      cw.core:ConvertForce(damageInfo:GetDamageForce() * 32)
    )
  end

  if hook.Run('PlayerCanDeathClearRecognisedNames', player, attacker, damageInfo) then
    cw.player:ClearRecognisedNames(player)
  end

  if hook.Run('PlayerCanDeathClearName', player, attacker, damageInfo) then
    cw.player:ClearName(player)
  end

  if deathSound then
    player:EmitSound('physics/flesh/flesh_impact_hard'..math.random(1, 5)..'.wav', 150)

    timer.Simple(FrameTime() * 25, function()
      if IsValid(player) then
        player:EmitSound(deathSound)
      end
    end)
  end

  player:SetForcedAnimation(false)
  player:SetCharacterData('Ammo', {}, true)
  player:StripWeapons()
  player:Extinguish()
  player.cwSpawnAmmo = {}
  player:StripAmmo()
  player:AddDeaths(1)
  player:UnLock()

  if IsValid(attacker) and attacker:IsPlayer() and player != attacker then
    if hook.Run('PlayerCanGainFrag', attacker, player) then
      attacker:AddFrags(1)
    end
  end
end

--- Called when a player dies.
--
-- Starts the respawn timer with `cw.core:CalculateSpawnTime`, disintegrates the ragdoll when
-- killed by a combine ball, and logs the kill.
-- @param player [Player The player]
-- @param inflictor [Entity The inflictor]
-- @param attacker [Entity The killer]
-- @param damageInfo [CTakeDamageInfo The fatal damage, or `nil`]
function GM:PlayerDeath(player, inflictor, attacker, damageInfo)
  cw.core:CalculateSpawnTime(player, inflictor, attacker, damageInfo)

  local ragdoll = player:GetRagdollEntity()

  if ragdoll then
    if IsValid(inflictor) and inflictor:GetClass() == 'prop_combine_ball' then
      if damageInfo then
        cw.entity:Disintegrate(ragdoll, 3, damageInfo:GetDamageForce() * 32)
      else
        cw.entity:Disintegrate(ragdoll, 3)
      end
    end
  end

  if attacker:IsPlayer() and damageInfo then
    if IsValid(attacker:GetActiveWeapon()) then
      local weapon = attacker:GetActiveWeapon()
      local itemTable = item.GetByWeapon(weapon)

      if IsValid(weapon) and itemTable then
        cw.core:PrintLog(
          LOGTYPE_CRITICAL,
          attacker:Name()..' has dealt '..tostring(math.ceil(damageInfo:GetDamage()))..' damage to '..player:Name()..
            ' with '..itemTable.name..', killing them!'
        )
      else
        cw.core:PrintLog(
          LOGTYPE_CRITICAL,
          attacker:Name()..' has dealt '..tostring(math.ceil(damageInfo:GetDamage()))..' damage to '..player:Name()..
            ' with '..cw.player:GetWeaponClass(attacker)..', killing them!'
        )
      end
    else
      cw.core:PrintLog(
        LOGTYPE_CRITICAL,
        attacker:Name()..' has dealt '..tostring(math.ceil(damageInfo:GetDamage()))..' damage to '..player:Name()..
          ', killing them!'
      )
    end
  else
    if damageInfo then
      cw.core:PrintLog(
        LOGTYPE_CRITICAL,
        attacker:GetClass()..' has dealt '..tostring(math.ceil(damageInfo:GetDamage()))..' damage to '..player:Name()..
          ', killing them!'
      )
    end
  end
end

--- Called when an item entity has taken damage, before its health drops; does nothing by default.
-- @param itemEntity [Entity The `cw_item` entity]
-- @param itemTable [Item The item]
-- @param damageInfo [CTakeDamageInfo The damage, which can be changed]
-- @return [Boolean The return value is ignored]
function GM:ItemEntityTakeDamage(itemEntity, itemTable, damageInfo)
  return false
end

--- Called when an item entity has been destroyed by damage, before it explodes; does nothing by default.
-- @param itemEntity [Entity The `cw_item` entity]
-- @param itemTable [Item The item]
function GM:ItemEntityDestroyed(itemEntity, itemTable) end

--- Called when an item's data changes, to pick who receives the update.
--
-- Items with a world entity are sent to everyone; otherwise the players who carry the item,
-- hold it as a weapon or have it in their open storage are added as observers.
-- @param itemTable [Item The item]
-- @param info [Map `observers` (a `Map` of player to player) and `sendToAll`, which can be changed]
-- @return [Boolean `true` to send the update to everyone]
function GM:ItemGetNetworkObservers(itemTable, info)
  local uniqueID = itemTable.uniqueID
  local itemID = itemTable.itemID
  local entity = item.FindEntityByInstance(itemTable)

  if entity then
    info.sendToAll = true
    return false
  end

  for k, v in ipairs(_player.GetAll()) do
    if v:HasInitialized() then
      local inventory = cw.storage:Query(v, 'inventory')

      if (inventory and inventory[uniqueID]
      and inventory[uniqueID][itemID]) or v:HasItemInstance(itemTable) then
        info.observers[v] = v
      elseif v:HasItemAsWeapon(itemTable) then
        info.observers[v] = v
      end
    end
  end
end

--- Called when a player's spawn weapons should be given.
--
-- Gives the toolgun and physgun for the `t` and `p` flags (with the player's weapon colour when
-- `custom_weapon_color` is set), the gravity gun, `cw_hands` and `cw_keys` when configured, and
-- the class's weapons and ammo, then runs `PlayerGiveWeapons` and selects the hands.
-- @param player [Player The player]
function GM:PlayerLoadout(player)
  local weapons = cw.class:Query(player:Team(), 'weapons')
  local ammo = cw.class:Query(player:Team(), 'ammo')

  player.cwSpawnWeps = {}
  player.cwSpawnAmmo = {}

  if cw.player:HasFlags(player, 't') then
    cw.player:GiveSpawnWeapon(player, 'gmod_tool')
  end

  if cw.player:HasFlags(player, 'p') then
    cw.player:GiveSpawnWeapon(player, 'weapon_physgun')

    if config.Get('custom_weapon_color'):Get() then
      local weaponColor = player:GetInfo('cl_weaponcolor')

      player:SetWeaponColor(Vector(weaponColor))
    end
  end

  cw.player:GiveSpawnWeapon(player, 'weapon_physcannon')

  if config.Get('give_hands'):Get() then
    cw.player:GiveSpawnWeapon(player, 'cw_hands')
  end

  if config.Get('give_keys'):Get() then
    cw.player:GiveSpawnWeapon(player, 'cw_keys')
  end

  if weapons then
    for k, v in pairs(weapons) do
      if !player:HasItemByID(v) then
        local itemTable = item.CreateInstance(v)

        if !cw.player:GiveSpawnItemWeapon(player, itemTable) then
          player:Give(v)
        end
      end
    end
  end

  if ammo then
    for k, v in pairs(ammo) do
      cw.player:GiveSpawnAmmo(player, k, v)
    end
  end

  hook.Run('PlayerGiveWeapons', player)

  if config.Get('give_hands'):Get() then
    player:SelectWeapon('cw_hands')
  end
end

--- Called when the server shuts down; saves all data through `PreSaveData`, `SaveData` and `PostSaveData`.
function GM:ShutDown()
  hook.Run('PreSaveData')
    hook.Run('SaveData')
  hook.Run('PostSaveData')

  cw.ShuttingDown = true
end

--- Called when a player presses F1; toggles their information menu.
-- @param player [Player The player]
function GM:ShowHelp(player)
  cable.send(player, 'InfoToggle', true)
end

--- Called when a player presses F2.
--
-- Looking at a door within 192 units that they can view and use, the player gets the door
-- management menu (with complete access to an owned door) or the purchase prompt (for an unowned
-- door). Otherwise the recognise menu opens when `recognise_system` is enabled. Does nothing in
-- noclip.
-- @param ply [Player The player]
function GM:ShowTeam(ply)
  if !cw.player:IsNoClipping(ply) then
    local doRecogniseMenu = true
    local entity = ply:GetEyeTraceNoCursor().Entity
    local plyTable = _player.GetAll()

    if IsValid(entity) and cw.entity:IsDoor(entity) then
      if entity:GetPos():Distance(ply:GetShootPos()) <= 192 then
        if hook.Run('PlayerCanViewDoor', ply, entity) then
          if hook.Run('PlayerUse', ply, entity) then
            local owner = cw.entity:GetOwner(entity)

            if IsValid(owner) then
              if cw.player:HasDoorAccess(ply, entity, DOOR_ACCESS_COMPLETE) then
                local data = {
                  sharedAccess = cw.entity:DoorHasSharedAccess(entity),
                  sharedText = cw.entity:DoorHasSharedText(entity),
                  unsellable = cw.entity:IsDoorUnsellable(entity),
                  accessList = {},
                  isParent = cw.entity:IsDoorParent(entity),
                  entity = entity,
                  owner = owner
                }

                for k, v in ipairs(plyTable) do
                  if v != ply and v != owner then
                    if cw.player:HasDoorAccess(v, entity, DOOR_ACCESS_COMPLETE) then
                      data.accessList[v] = DOOR_ACCESS_COMPLETE
                    elseif cw.player:HasDoorAccess(v, entity, DOOR_ACCESS_BASIC) then
                      data.accessList[v] = DOOR_ACCESS_BASIC
                    end
                  end
                end

                cable.send(ply, 'DoorManagement', data)
              end
            else
              cable.send(ply, 'PurchaseDoor', entity)
            end
          end
        end

        doRecogniseMenu = false
      end
    end

    if config.Get('recognise_system'):Get() then
      if doRecogniseMenu then
        cable.send(ply, 'RecogniseMenu', true)
      end
    end
  end
end

--- Called when a player picks a character menu action other than `use` or `delete`; does nothing by default.
-- @param player [Player The player]
-- @param action [String The action]
-- @param character [Character The character]
function GM:PlayerSelectCustomCharacterOption(player, action, character) end

--- Called when a player (or their ragdoll) takes damage that does not kill them.
--
-- With limb damage stumbling enabled, a bullet to the legs while both legs are above 50 damage
-- makes the player fall over for 8 seconds.
-- @param player [Player The player]
-- @param inflictor [Entity The inflictor]
-- @param attacker [Entity The attacker]
-- @param hitGroup [Number The hit group (`HITGROUP_*`)]
-- @param damageInfo [CTakeDamageInfo The damage]
-- @return [Boolean `true` to suppress the pain sound]
function GM:PlayerTakeDamage(player, inflictor, attacker, hitGroup, damageInfo)
  if damageInfo:IsBulletDamage() and cw.event:CanRun('limb_damage', 'stumble') then
    if hitGroup == HITGROUP_LEFTLEG or hitGroup == HITGROUP_RIGHTLEG then
      local rightLeg = cw.limb:GetDamage(player, HITGROUP_RIGHTLEG)
      local leftLeg = cw.limb:GetDamage(player, HITGROUP_LEFTLEG)

      if rightLeg > 50 and leftLeg > 50 and !player:IsRagdolled() then
        cw.player:SetRagdollState(
          player, RAGDOLL_FALLENOVER, 8, nil, cw.core:ConvertForce(damageInfo:GetDamageForce() * 32)
        )
        damageInfo:ScaleDamage(0.25)
      end
    end
  end
end

--- Called when an entity takes damage; Catwork's central damage handler.
--
-- Lets `cw.core:DoEntityTakeDamageHook` handle it first. With `prop_kill_protection`, damage from
-- immune or held props is cancelled. Damage to players and player ragdolls is scaled by
-- `GM:ScaleDamageByHitGroup` and applied through `cw.core:CalculatePlayerDamage`; fatal damage
-- runs `DoPlayerDeath` and `PlayerDeath`, other damage runs `PlayerTakeDamage`, plays
-- `PlayerPlayPainSound` and is logged. Ragdoll damage is filtered by
-- `PlayerRagdollCanTakeDamage`. Plain ragdolls bleed and are disintegrated by combine balls, and
-- crowbar damage to NPCs is quartered.
-- @param entity [Entity The damaged entity]
-- @param damageInfo [CTakeDamageInfo The damage]
function GM:EntityTakeDamage(entity, damageInfo)
  if cw.core:DoEntityTakeDamageHook(entity, damageInfo) then
    return
  end

  local inflictor = damageInfo:GetInflictor()
  local attacker = damageInfo:GetAttacker()
  local amount = damageInfo:GetDamage()

  if config.Get('prop_kill_protection'):Get() then
    local curTime = CurTime()

    if (IsValid(inflictor) and inflictor.cwDamageImmunity and inflictor.cwDamageImmunity > curTime
    and !inflictor:IsVehicle())
    or (IsValid(attacker) and attacker.cwDamageImmunity and attacker.cwDamageImmunity > curTime) then
      entity.cwDamageImmunity = curTime + 1

      damageInfo:SetDamage(0)
      return false
    end

    -- `IsValid` is false for the world, so it is compared directly.
    if attacker == game.GetWorld() and entity.cwDamageImmunity and entity.cwDamageImmunity > curTime then
      damageInfo:SetDamage(0)
      return false
    end

    if (IsValid(inflictor) and inflictor:IsBeingHeld())
    or attacker:IsBeingHeld() then
      damageInfo:SetDamage(0)
      return false
    end
  end

  if entity:IsPlayer() and entity:InVehicle() and !IsValid(entity:GetVehicle():GetParent()) then
    entity.cwLastHitGroup = cw.core:GetRagdollHitBone(entity, damageInfo:GetDamagePosition(), HITGROUP_GEAR)

    if damageInfo:IsBulletDamage() then
      if (attacker:IsPlayer() or attacker:IsNPC()) and attacker != entity then
        damageInfo:ScaleDamage(10000)
      end
    end
  end

  if damageInfo:GetDamage() == 0 then
    return
  end

  local isPlayerRagdoll = cw.entity:IsPlayerRagdoll(entity)
  local player = cw.entity:GetPlayer(entity)

  if player and (entity:IsPlayer() or isPlayerRagdoll) then
    if damageInfo:IsFallDamage() or config.Get('damage_view_punch'):Get() then
      player:ViewPunch(
        Angle(math.random(amount, amount), math.random(amount, amount), math.random(amount, amount))
      )
    end

    if !isPlayerRagdoll then
      if damageInfo:IsDamageType(DMG_CRUSH) and damageInfo:GetDamage() < 10 then
        damageInfo:SetDamage(0)
      else
        local lastHitGroup = player:LastHitGroup()

        self:ScaleDamageByHitGroup(player, attacker, lastHitGroup, damageInfo, amount)

        if damageInfo:GetDamage() > 0 then
          cw.core:CalculatePlayerDamage(player, lastHitGroup, damageInfo)
          player:SetVelocity(cw.core:ConvertForce(damageInfo:GetDamageForce() * 32, 200))

          if player:Alive() and player:Health() == 1 then
            player:SetFakingDeath(true)
              hook.Run('DoPlayerDeath', player, attacker, damageInfo)
              hook.Run('PlayerDeath', player, inflictor, attacker, damageInfo)
              cw.core:CreateBloodEffects(damageInfo:GetDamagePosition(), 1, player, damageInfo:GetDamageForce())
            player:SetFakingDeath(false, true)
          else
            local bNoMsg = hook.Run('PlayerTakeDamage', player, inflictor, attacker, lastHitGroup, damageInfo)
            local sound = hook.Run('PlayerPlayPainSound', player, player:GetGender(), damageInfo, lastHitGroup)

            cw.core:CreateBloodEffects(damageInfo:GetDamagePosition(), 1, player, damageInfo:GetDamageForce())

            if sound and !bNoMsg then
              player:EmitHitSound(sound)
            end

            local armor = '!'

            if player:Armor() > 0 then
              armor = ' and '..player:Armor()..' armor!'
            end

            if attacker:IsPlayer() then
              cw.core:PrintLog(
                LOGTYPE_MAJOR,
                player:Name()..' has taken '..tostring(math.ceil(damageInfo:GetDamage()))..' damage from '..
                  attacker:Name()..
                  ' with '..cw.player:GetWeaponClass(attacker, 'an unknown weapon')..', leaving them at '..
                  player:Health()..
                  ' health'..armor
              )
            else
              cw.core:PrintLog(
                LOGTYPE_MAJOR,
                player:Name()..' has taken '..tostring(math.ceil(damageInfo:GetDamage()))..' damage from '..
                  attacker:GetClass()..', leaving them at '..player:Health()..' health'..armor
              )
            end
          end
        end

        damageInfo:SetDamage(0)
        player.cwLastHitGroup = nil
      end
    else
      local hitGroup = cw.core:GetRagdollHitGroup(entity, damageInfo:GetDamagePosition())

      self:ScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, amount)

      if hook.Run('PlayerRagdollCanTakeDamage', player, entity, inflictor, attacker, hitGroup, damageInfo)
      and damageInfo:GetDamage() > 0 then
        if !attacker:IsPlayer() then
          if attacker:GetClass() == 'prop_ragdoll' or cw.entity:IsDoor(attacker)
          or damageInfo:GetDamage() < 5 then
            return
          end
        end

        if damageInfo:GetDamage() >= 10 or damageInfo:IsBulletDamage() then
          cw.core:CreateBloodEffects(damageInfo:GetDamagePosition(), 1, entity, damageInfo:GetDamageForce())
        end

        cw.core:CalculatePlayerDamage(player, hitGroup, damageInfo)

        if player:Alive() and player:Health() == 1 then
          player:SetFakingDeath(true)
            player:GetRagdollTable().health = 0
            player:GetRagdollTable().armor = 0

            hook.Run('DoPlayerDeath', player, attacker, damageInfo)
            hook.Run('PlayerDeath', player, inflictor, attacker, damageInfo)
          player:SetFakingDeath(false, true)
        elseif player:Alive() then
          local bNoMsg = hook.Run('PlayerTakeDamage', player, inflictor, attacker, hitGroup, damageInfo)
          local sound = hook.Run('PlayerPlayPainSound', player, player:GetGender(), damageInfo, hitGroup)

          if sound and !bNoMsg then
            entity:EmitHitSound(sound)
          end

          local armor = '!'

          if player:Armor() > 0 then
            armor = ' and '..player:Armor()..' armor!'
          end

          if attacker:IsPlayer() then
            cw.core:PrintLog(
              LOGTYPE_MAJOR,
              player:Name()..' has taken '..tostring(math.ceil(damageInfo:GetDamage()))..' damage from '..
                attacker:Name()..
                ' with '..cw.player:GetWeaponClass(attacker, 'an unknown weapon')..', leaving them at '..
                player:Health()..
                ' health'..armor
            )
          else
            cw.core:PrintLog(
              LOGTYPE_MAJOR,
              player:Name()..' has taken '..tostring(math.ceil(damageInfo:GetDamage()))..' damage from '..
                attacker:GetClass()..
                ', leaving them at '..player:Health()..' health'..armor
            )
          end
        end
      end

      damageInfo:SetDamage(0)
    end
  elseif entity:GetClass() == 'prop_ragdoll' then
    if damageInfo:GetDamage() >= 20 or damageInfo:IsBulletDamage() then
      if !string.find(entity:GetModel(), 'matt') and !string.find(entity:GetModel(), 'gib') then
        local matType = util.QuickTrace(entity:GetPos(), entity:GetPos()).MatType

        if matType == MAT_FLESH or matType == MAT_BLOODYFLESH then
          cw.core:CreateBloodEffects(damageInfo:GetDamagePosition(), 1, entity, damageInfo:GetDamageForce())
        end
      end
    end

    if IsValid(inflictor) and inflictor:GetClass() == 'prop_combine_ball' then
      if !entity.disintegrating then
        cw.entity:Disintegrate(entity, 3, damageInfo:GetDamageForce())

        entity.disintegrating = true
      end
    end
  elseif entity:IsNPC() then
    if attacker:IsPlayer() and IsValid(attacker:GetActiveWeapon())
    and cw.player:GetWeaponClass(attacker) == 'weapon_crowbar' then
      damageInfo:ScaleDamage(0.25)
    end
  end
end

--- Called when the default death sound for a player should be played; returns `true` to mute it, Catwork plays its own.
-- @param player [Player The player]
-- @return [Boolean Always `true`]
function GM:PlayerDeathSound(player) return true end

--- Called when a player attempts to spawn a SWEP; only super admins can.
-- @param player [Player The player]
-- @param class [String The weapon class]
-- @param weapon [Map The weapon's table]
-- @return [Boolean Whether the SWEP can be spawned]
function GM:PlayerSpawnSWEP(player, class, weapon)
  if !player:IsSuperAdmin() then
    return false
  else
    return true
  end
end

--- Called when a player attempts to give themselves a SWEP; only super admins can.
-- @param player [Player The player]
-- @param class [String The weapon class]
-- @param weapon [Map The weapon's table]
-- @return [Boolean Whether the SWEP is given]
function GM:PlayerGiveSWEP(player, class, weapon)
  if !player:IsSuperAdmin() then
    return false
  else
    return true
  end
end

--- Called when a player attempts to spawn a scripted entity; only super admins can.
-- @param player [Player The player]
-- @param class [String The entity class]
-- @return [Boolean Whether the entity can be spawned]
function GM:PlayerSpawnSENT(player, class)
  if !player:IsSuperAdmin() then
    return false
  else
    return true
  end
end

--- Called when a player presses a key.
--
-- Use within 192 units opens doors (running `PlayerCanUseDoor` and `PlayerUseDoor`) and uses
-- `UsableInVehicle` entities from vehicles. Pressing walk while standing still and holding
-- sprint toggles crouching.
-- @param player [Player The player]
-- @param key [Number The key (`IN_*`)]
function GM:KeyPress(player, key)
  if key == IN_USE then
    local trace = player:GetEyeTraceNoCursor()

    if IsValid(trace.Entity) and trace.HitPos:Distance(player:GetShootPos()) <= 192 then
      if hook.Run('PlayerUse', player, trace.Entity) then
        if cw.entity:IsDoor(trace.Entity) and !trace.Entity:HasSpawnFlags(256)
        and !trace.Entity:HasSpawnFlags(8192) and !trace.Entity:HasSpawnFlags(32768) then
          if hook.Run('PlayerCanUseDoor', player, trace.Entity) then
            hook.Run('PlayerUseDoor', player, trace.Entity)
            cw.entity:OpenDoor(trace.Entity, 0, nil, nil, player:GetPos())
          end
        elseif trace.Entity.UsableInVehicle then
          if player:InVehicle() then
            if trace.Entity.Use then
              trace.Entity:Use(player, player)

              player.cwNextExitVehicle = CurTime() + 1
            end
          end
        end
      end
    end
  elseif key == IN_WALK then
    local velocity = player:GetVelocity():Length()

    if velocity == 0 and player:KeyDown(IN_SPEED) then
      if player:Crouching() then
        player:RunCommand('-duck')
      else
        player:RunCommand('+duck')
      end
    end
  end
end

--- Called when a player presses a button down.
--
-- B toggles the weapon raise when `quick_raise_enabled` is set and `PlayerCanQuickRaise` allows.
-- @param player [Player The player pressing the button]
-- @param button [Number The button pressed (`KEY_*`)]
function GM:PlayerButtonDown(player, button)
  if button == KEY_B then
    if config.Get('quick_raise_enabled'):GetBoolean() then
      if hook.Run('PlayerCanQuickRaise', player, player:GetActiveWeapon()) then
        cw.player:ToggleWeaponRaised(player)
      end
    end
  end

  return self.BaseClass:PlayerButtonDown(player, button)
end

--- Called when a player presses the quick raise key, to check whether they can toggle their weapon; always allows it.
-- @param player [Player The player raising their weapon]
-- @param weapon [Weapon The player's active weapon]
-- @return [Boolean Whether the weapon raise toggles]
function GM:PlayerCanQuickRaise(player, weapon) return true end

--- Called when a player releases a key; overridden to do nothing.
-- @param player [Player The player]
-- @param key [Number The key (`IN_*`)]
function GM:KeyRelease(player, key) end

--- Called to set up a player's visibility; adds their ragdoll's position to the PVS so it keeps being networked.
-- @param player [Player The player]
function GM:SetupPlayerVisibility(player)
  local ragdollEntity = player:GetRagdollEntity()

  if ragdollEntity then
    AddOriginToPVS(ragdollEntity:GetPos())
  end
end

--- Called after a player has spawned an NPC; applies every player's faction `entRelationship` to it.
-- @param player [Player The player who spawned the NPC]
-- @param npc [NPC The NPC]
function GM:PlayerSpawnedNPC(player, npc)
  local class = npc:GetClass()

  for k, v in ipairs(_player.GetAll()) do
    local factionTable = v:HasInitialized() and _faction.FindByID(v:GetFaction())
    local relation = factionTable and factionTable.entRelationship
    local relationName = istable(relation) and relation[class]

    if relationName then
      local disposition = relationTypes[string.lower(relationName)]

      if disposition then
        local steamID = v:SteamID()

        prevRelation = prevRelation or {}
        prevRelation[steamID] = prevRelation[steamID] or {}
        prevRelation[steamID][class] = prevRelation[steamID][class] or npc:Disposition(v)

        npc:AddEntityRelationship(v, disposition, 1)
      else
        ErrorNoHalt(
          "Attempting to add relationship using invalid relation '"..relationName.."' towards faction '"..
            factionTable.name.."'.\r\n"
        )
      end
    end
  end
end

--- Called when an attribute is progressed, before the amount is applied.
--
-- Catwork multiplies `amount` by the `scale_attribute_progress` config.
-- @param player [Player The player who progressed the attribute]
-- @param attribute [String The attribute's unique ID]
-- @param amount [Number The amount it is progressed by]
-- @return [Number The amount to progress the attribute by instead]
function GM:OnAttributeProgress(player, attribute, amount)
  return amount * config.Get('scale_attribute_progress'):Get()
end

--- Called to add ammo types that are saved with the character; adds the HL2 ammo types.
-- @param ammoTable [Map Ammo types to check, as `{ [ammoType] = true }`, modified in place]
function GM:AdjustAmmoTypes(ammoTable)
  ammoTable['sniperpenetratedround'] = true
  ammoTable['striderminigun'] = true
  ammoTable['helicoptergun'] = true
  ammoTable['combinecannon'] = true
  ammoTable['smg1_grenade'] = true
  ammoTable['gaussenergy'] = true
  ammoTable['sniperround'] = true
  ammoTable['ar2altfire'] = true
  ammoTable['rpg_round'] = true
  ammoTable['xbowbolt'] = true
  ammoTable['buckshot'] = true
  ammoTable['alyxgun'] = true
  ammoTable['grenade'] = true
  ammoTable['thumper'] = true
  ammoTable['gravity'] = true
  ammoTable['battery'] = true
  ammoTable['pistol'] = true
  ammoTable['slam'] = true
  ammoTable['smg1'] = true
  ammoTable['357'] = true
  ammoTable['ar2'] = true
end

--- Called after a player uses a command; does nothing by default.
-- @param player [Player The player who used the command]
-- @param command [Command The command used]
-- @param arguments [List<String> The arguments given with the command, if any]
function GM:PostCommandUsed(player, command, arguments) end

--- Called to scale damage a player takes by hit group.
--
-- Except for fall and crush damage, head, chest and limb hits are scaled by `scale_head_dmg`,
-- `scale_chest_dmg` and `scale_limb_dmg`; head hits also punch the view and muffle the sound.
-- Then runs `PlayerScaleDamageByHitGroup`.
-- @param player [Player The player taking damage]
-- @param attacker [Entity The attacker]
-- @param hitGroup [Number The hit group (`HITGROUP_*`)]
-- @param damageInfo [CTakeDamageInfo The damage to scale in place]
-- @param baseDamage [Number The damage before scaling]
function GM:ScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, baseDamage)
  if !damageInfo:IsFallDamage() and !damageInfo:IsDamageType(DMG_CRUSH) then
    if hitGroup == HITGROUP_HEAD then
      damageInfo:ScaleDamage(config.Get('scale_head_dmg'):Get())
      player:SetDSP(35, false)
      player:ViewPunch(AngleRand())
    elseif hitGroup == HITGROUP_CHEST or hitGroup == HITGROUP_GENERIC then
      damageInfo:ScaleDamage(config.Get('scale_chest_dmg'):Get())
    elseif hitGroup == HITGROUP_LEFTARM or hitGroup == HITGROUP_RIGHTARM or hitGroup == HITGROUP_LEFTLEG
    or hitGroup == HITGROUP_RIGHTLEG or hitGroup == HITGROUP_GEAR then
      damageInfo:ScaleDamage(config.Get('scale_limb_dmg'):Get())
    end
  end

  hook.Run('PlayerScaleDamageByHitGroup', player, attacker, hitGroup, damageInfo, baseDamage)
end
