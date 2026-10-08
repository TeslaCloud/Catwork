--- Server-side core of the HL2RP schema, which registers its config keys, hints and netstream receivers and defines the
-- `Schema` functions that the schema's hooks, commands, items and entities call.
--
-- The functions cover citizen records (loyalty, criminal and work points, status, residence, job), player-controlled
-- scanners, the Combine display and objectives, request, broadcast and Dispatch messages, Combine locks, door busting,
-- tying and permanent kills, and the per-map saving and loading of radios, ration dispensers, vending machines and
-- named NPCs. Config keys added here include `server_whitelist_identity`, `knockout_time`, `business_cost`, `permits`,
-- `cwu_props`, `voice_cooldown` and `enable_permakill`; `cw.hint:AddHumanHint` is added for hints shown only to
-- non-Combine players.

Schema.scannerSounds = {
  'npc/scanner/cbot_servochatter.wav',
  'npc/scanner/cbot_servoscared.wav',
  'npc/scanner/scanner_blip1.wav',
  'npc/scanner/scanner_scan1.wav',
  'npc/scanner/scanner_scan2.wav',
  'npc/scanner/scanner_scan4.wav',
  'npc/scanner/scanner_scan5.wav',
  'npc/scanner/combat_scan1.wav',
  'npc/scanner/combat_scan2.wav',
  'npc/scanner/combat_scan3.wav',
  'npc/scanner/combat_scan4.wav',
  'npc/scanner/combat_scan5.wav'
}
Schema.scanners = Schema.scanners or {}
Schema.cwuProps = {
  'models/props_c17/furniturewashingmachine001a.mdl',
  'models/props_interiors/furniture_vanity01a.mdl',
  'models/props_interiors/furniture_couch02a.mdl',
  'models/props_interiors/furniture_shelf01a.mdl',
  'models/props_interiors/furniture_chair01a.mdl',
  'models/props_interiors/furniture_desk01a.mdl',
  'models/props_interiors/furniture_lamp01a.mdl',
  'models/props_c17/furniturecupboard001a.mdl',
  'models/props_c17/furnituredresser001a.mdl',
  'models/props_c17/furniturefridge001a.mdl',
  'models/props_c17/furniturestove001a.mdl',
  'models/props_interiors/radiator01a.mdl',
  'models/props_c17/furniturecouch001a.mdl',
  'models/props_combine/breenclock.mdl',
  'models/props_combine/breenchair.mdl',
  'models/props_c17/shelfunit01a.mdl',
  'models/props_combine/breendesk.mdl',
  'models/props_lab/monitor01b.mdl',
  'models/props_lab/monitor01a.mdl',
  'models/props_lab/monitor02.mdl',
  'models/props_c17/frame002a.mdl',
  'models/props_c17/bench01a.mdl'
}

cw.core:AddFile('resource/fonts/mailartrubberstamp.ttf')
cw.core:AddFile('models/eliteghostcp.mdl')
cw.core:AddFile('models/eliteshockcp.mdl')
cw.core:AddFile('models/policetrench.mdl')
cw.core:AddFile('models/leet_police2.mdl')
cw.core:AddFile('models/sect_police2.mdl')
cw.core:AddFile('halfliferp/logo4.png')

config.Add('server_whitelist_identity', '')
config.Add('combine_lock_overrides', false)
config.Add('intro_text_small', 'The city of wonders.', true)
config.Add('intro_text_big', 'CITY-24, 2018.', true)
config.Add('knockout_time', 60)
config.Add('business_cost', 160, true)
config.Add('cwu_props', true)
config.Add('permits', true, true)
config.Add('voice_cooldown', 15)
config.Add('sxbase_force_fov', 0)
config.Add('enable_permakill', false)

config.Get('enable_gravgun_punt'):Set(false)
config.Get('default_inv_weight'):Set(6)
config.Get('enable_crosshair'):Set(true)
config.Get('disable_sprays'):Set(false)
config.Get('prop_cost'):Set(false)
config.Get('door_cost'):Set(0)

--- Adds a hint that is only shown to non-Combine players.
--
-- Wraps `cw.hint:Add` with a callback that checks `Player:IsCombine`.
-- @param name [String Unique name of the hint]
-- @param text [String Hint text or language key]
-- @param combine=nil [Boolean Unused]
function cw.hint:AddHumanHint(name, text, combine)
  cw.hint:Add(name, text, function(player)
    if IsValid(player) then
      return !player:IsCombine()
    end
  end)
end

cw.hint:AddHumanHint('Life', '#Hints_HL2RP_Life', false)
cw.hint:AddHumanHint('Sleep', '#Hints_HL2RP_Sleep', false)
cw.hint:AddHumanHint('Friends', '#Hints_HL2RP_Friends', false)

cw.hint:AddHumanHint('Curfew', '#Hints_HL2RP_Curfew')
cw.hint:AddHumanHint('Prison', '#Hints_HL2RP_Prison')
cw.hint:AddHumanHint('Rebels', '#Hints_HL2RP_Rebels')
cw.hint:AddHumanHint('Talking', '#Hints_HL2RP_Talking')
cw.hint:AddHumanHint('Rations', '#Hints_HL2RP_Rations')
cw.hint:AddHumanHint('Combine', '#Hints_HL2RP_Combine')
cw.hint:AddHumanHint('Jumping', '#Hints_HL2RP_Jumping')
cw.hint:AddHumanHint('Punching', '#Hints_HL2RP_Punching')
cw.hint:AddHumanHint('Compliance', '#Hints_HL2RP_Compliance')
cw.hint:AddHumanHint('Combine Raids', '#Hints_HL2RP_CombineRaids')
cw.hint:AddHumanHint('Request Device', '#Hints_HL2RP_RequestDevice')
cw.hint:AddHumanHint('Civil Protection', '#Hints_HL2RP_CivilProtection')

cw.hint:Add('Admins', '#Hints_HL2RP_Admins')
cw.hint:Add('Action', '#Hints_HL2RP_Action')
cw.hint:Add('Grammar', '#Hints_HL2RP_Grammar')
cw.hint:Add('Running', '#Hints_HL2RP_Running')
cw.hint:Add('Healing', '#Hints_HL2RP_Healing')
cw.hint:Add('F3 Hotkey', '#Hints_HL2RP_F3_Hotkey')
cw.hint:Add('F4 Hotkey', '#Hints_HL2RP_F4_Hotkey')
cw.hint:Add('Attributes', '#Hints_HL2RP_BugReport')
cw.hint:Add('Firefights', '#Hints_HL2RP_Firefights')
cw.hint:Add('Metagaming', '#Hints_HL2RP_Metagaming')
cw.hint:Add('Passive RP', '#Hints_HL2RP_PassiveRP')
cw.hint:Add('Development', '#Hints_HL2RP_Development')
cw.hint:Add('Powergaming', '#Hints_HL2RP_Powergaming')
cw.hint:Add('LOOC Spam', '#Hints_HL2RP_LOOCSpam')
cw.hint:Add('Uncommon Situation', '#Hints_HL2RP_UncommonSituation')
cw.hint:Add('PainRP', '#Hints_HL2RP_PainRP')
cw.hint:Add('FearRP', '#Hints_HL2RP_FearRP')
cw.hint:Add('Original', '#Hints_HL2RP_Original')

netstream.Hook('EditObjectives', function(player, data)
  if !player.editObjectivesAuthorised or type(data) != 'string' then return end

  player.editObjectivesAuthorised = nil

  -- The player may have switched to a non-Combine character since running the command.
  if !player:IsCombine() then return end

  data = string.sub(data, 1, 500)

  if Schema.combineObjectives == data then return end

  Schema:AddCombineDisplayLine(L('CombineDisplay_ObjectivesUpdated'), Color(255, 100, 255, 255))
  Schema.combineObjectives = data

  cw.core:SaveSchemaData('objectives', {
    text = Schema.combineObjectives
  })

  if !cwCTO then return end

  timer.Simple(0.1, function()
    local players = {}

    for k, v in ipairs(_player.GetAll()) do
      if v:IsCombine() and !v:GetSharedVar('IsBiosignalGone') then
        players[#players + 1] = v
      end
    end

    netstream.Start(players, 'RecalculateHUDObjectives', { cwCTO.socioStatus, Schema.combineObjectives })
  end)
end)

netstream.Hook('ObjectPhysDesc', function(player, data)
  if type(data) != 'table' or type(data[1]) != 'string' then return end

  local entity = player.objectPhysDesc

  if !IsValid(entity) or entity != data[2] then return end

  player.objectPhysDesc = nil

  local physDesc = data[1]

  if string.utf8len(physDesc) > 80 then
    physDesc = string.utf8sub(physDesc, 1, 80)..'...'
  end

  entity:SetNWString('physDesc', physDesc)
end)

netstream.Hook('EditData', function(player, data)
  if type(data) != 'table' or type(data[2]) != 'string' then return end

  local target = player.editDataAuthorised

  if !IsValid(target) or target != data[1] then return end

  player.editDataAuthorised = nil

  target:SetCharacterData('combinedata', string.sub(data[2], 1, 500))
end)

--- Sends custom scoreboard icons over the `PlayerSetCustomIcon` netstream message.
--
-- The player's own `CustomIcon` data is sent to everyone; unless `bOneWay` is set, every other player's
-- icon is then sent to this player, as needed when they have just connected.
-- @param player [Player The player whose icon is sent]
-- @param bOneWay=nil [Boolean Only broadcast this player's icon, and make clients re-download it]
function Schema:SendIconData(player, bOneWay)
  -- First send custom icon data to everybody already on the server.
  local iconData = player:GetData('CustomIcon')

  if istable(iconData) then
    netstream.Start(nil, 'PlayerSetCustomIcon', player, iconData, bOneWay)
  end

  if !bOneWay then
    -- Then send everyone's icons to our newly connected player.
    for k, v in ipairs(_player.GetAll()) do
      if v == player then continue end

      iconData = v:GetData('CustomIcon')

      if istable(iconData) then
        netstream.Start(player, 'PlayerSetCustomIcon', v, iconData)
      end
    end
  end
end

-- Rounds a points value; nil for anything that is not a finite number, which must never reach the character data.
local function ToPoints(value)
  value = tonumber(value)

  if value and value > -math.huge and value < math.huge then
    return math.Round(value)
  end
end

--- Sets a player's loyalty points, rounded, in their character data and `LoyaltyPoints` net var.
-- @param player [Player The player]
-- @param amt [Number The new amount; numeric strings are converted, anything else is ignored]
function Schema:SetLP(player, amt)
  amt = ToPoints(amt)

  if !amt then return end

  player:SetCharacterData('LoyaltyPoints', amt)
  player:SetNetVar('LoyaltyPoints', amt)
end

--- Sets a player's criminal points, rounded, in their character data and `CriminalPoints` net var.
-- @param player [Player The player]
-- @param amt [Number The new amount; numeric strings are converted, anything else is ignored]
function Schema:SetCP(player, amt)
  amt = ToPoints(amt)

  if !amt then return end

  player:SetCharacterData('CriminalPoints', amt)
  player:SetNetVar('CriminalPoints', amt)
end

--- Adds to a player's loyalty points with `Schema:SetLP`.
-- @param player [Player The player]
-- @param amt [Number The amount to add; may be negative]
function Schema:AddLP(player, amt)
  amt = ToPoints(amt)

  if amt then
    self:SetLP(player, self:GetLP(player) + amt)
  end
end

--- Adds to a player's criminal points with `Schema:SetCP`.
-- @param player [Player The player]
-- @param amt [Number The amount to add; may be negative]
function Schema:AddCP(player, amt)
  amt = ToPoints(amt)

  if amt then
    self:SetCP(player, self:GetCP(player) + amt)
  end
end

--- Subtracts from a player's loyalty points with `Schema:AddLP`.
-- @param player [Player The player]
-- @param amt [Number The amount to subtract]
function Schema:SubstractLP(player, amt)
  self:AddLP(player, -amt)
end

--- Subtracts from a player's criminal points with `Schema:AddCP`.
-- @param player [Player The player]
-- @param amt [Number The amount to subtract]
function Schema:SubstractCP(player, amt)
  self:AddCP(player, -amt)
end

--- Sets a player's citizen status in their character data and `CitizenStatus` net var.
-- @param player [Player The player]
-- @param status [String A key of `Schema.CitizenStates`; any other value is stored as `'Unknown'`]
function Schema:SetCitizenStatus(player, status)
  status = (self.CitizenStates[status] and status) or 'Unknown'

  player:SetCharacterData('CitizenStatus', status)
  player:SetNetVar('CitizenStatus', status)
end

--- Sets a player's residence in their character data and `Residence` net var.
-- @param player [Player The player]
-- @param value [String The residence]
function Schema:SetResidence(player, value)
  player:SetCharacterData('Residence', value)
  player:SetNetVar('Residence', value)
end

--- Sets whether a player is jailed, in their character data and `Jailed` net var.
-- @param player [Player The player]
-- @param value [Boolean Whether the player is jailed; converted with `tobool`]
function Schema:SetJailed(player, value)
  value = tobool(value)

  player:SetCharacterData('Jailed', value)
  player:SetNetVar('Jailed', value)
end

--- Sets a player's job in their character data and `Job` net var.
-- @param player [Player The player]
-- @param value [String The job]
function Schema:SetJob(player, value)
  player:SetCharacterData('Job', value)
  player:SetNetVar('Job', value)
end

--- Sets a player's work points, rounded, in their character data and `WorkPoints` net var.
-- @param player [Player The player]
-- @param value [Number The new amount; numeric strings are converted, anything else is ignored]
function Schema:SetWorkPoints(player, value)
  value = ToPoints(value)

  if !value then return end

  player:SetCharacterData('WorkPoints', value)
  player:SetNetVar('WorkPoints', value)
end

--- Adds to a player's work points with `Schema:SetWorkPoints`.
-- @param player [Player The player]
-- @param amt [Number The amount to add; may be negative]
function Schema:AddWorkPoints(player, amt)
  amt = ToPoints(amt)

  if amt then
    self:SetWorkPoints(player, self:GetWorkPoints(player) + amt)
  end
end

--- Keeps a scanner player in sync with their scanner; does nothing for other players.
--
-- Copies the scanner's health to the player, keeps them in observer movement and plays a random scanner
-- sound every 8 to 48 seconds.
-- @param player [Player The player controlling the scanner]
-- @param curTime [Number The current `CurTime()`]
function Schema:CalculateScannerThink(player, curTime)
  if !self.scanners[player] then return end

  local scanner = self.scanners[player][1]
  local marker = self.scanners[player][2]

  if IsValid(scanner) and IsValid(marker) then
    scanner:SetMaxHealth(player:GetMaxHealth())

    player:SetMoveType(MOVETYPE_OBSERVER)
    player:SetHealth(math.max(scanner:Health(), 0))

    if !player.nextScannerSound or curTime >= player.nextScannerSound then
      player.nextScannerSound = curTime + math.random(8, 48)

      scanner:EmitSound(self.scannerSounds[math.random(1, #self.scannerSounds)])
    end
  end
end

--- Removes a player's scanner and its follow marker; does nothing when they have none.
--
-- Unless `noMessage` is set, the player is also returned to walking, stops spectating and is killed
-- silently.
-- @param player [Player The player controlling the scanner]
-- @param noMessage=nil [Boolean Only remove the entities, leaving the player as they are]
function Schema:ResetPlayerScanner(player, noMessage)
  if self.scanners[player] then
    local scanner = self.scanners[player][1]
    local marker = self.scanners[player][2]

    if IsValid(scanner) then
      scanner:Remove()
    end

    if IsValid(marker) then
      marker:Remove()
    end

    self.scanners[player] = nil

    player:SetNetVar('scanner', nil)

    if !noMessage then
      player:SetMoveType(MOVETYPE_WALK)
      player:UnSpectate()
      player:KillSilent()
    end
  end
end

--- Turns a player into a scanner they control.
--
-- Replaces any existing scanner (see `Schema:ResetPlayerScanner`), spawns an `npc_cscanner` (or an
-- `npc_clawscanner` for the `SYNTH` rank) that follows a marker, and makes the player spectate it with
-- their weapons and armour stripped. The scanner's entity index is stored in the `scanner` net var.
-- @param player [Player The player]
-- @param noMessage=nil [Boolean Passed to `Schema:ResetPlayerScanner` for the old scanner]
-- @param lightSpawn=nil [Boolean Whether this is a light spawn; skips turning off the flashlight,
-- unducking and the shield scanner's 200 health]
function Schema:MakePlayerScanner(player, noMessage, lightSpawn)
  self:ResetPlayerScanner(player, noMessage)

  local scannerClass = 'npc_cscanner'

  if self:IsPlayerCombineRank(player, 'SYNTH') then
    scannerClass = 'npc_clawscanner'
  end

  local position = player:GetShootPos()
  local uniqueID = player:SteamID64()
  local scanner = ents.Create(scannerClass)
  local marker = ents.Create('path_corner')

  cw.entity:SetPlayer(scanner, player)

  scanner:SetPos(position + Vector(0, 0, 16))
  scanner:SetAngles(player:GetAimVector():Angle())
  scanner:SetKeyValue('targetname', 'scanner_'..uniqueID)
  scanner:SetKeyValue('spawnflags', 8592)
  scanner:SetKeyValue('renderfx', 0)
  scanner:Spawn() scanner:Activate()

  marker:SetKeyValue('targetname', 'marker_'..uniqueID)
  marker:SetPos(position)
  marker:Spawn() marker:Activate()

  if !lightSpawn then
    player:Flashlight(false)
    player:RunCommand('-duck')

    if scannerClass == 'npc_clawscanner' then
      player:SetHealth(200)
    end
  end

  player:SetArmor(0)
  player:Spectate(OBS_MODE_CHASE)
  player:StripWeapons()
  player:SetNetVar('scanner', scanner:EntIndex())
  player:SetMoveType(MOVETYPE_OBSERVER)
  player:SpectateEntity(scanner)

  scanner:SetMaxHealth(player:GetMaxHealth())
  scanner:SetHealth(player:Health())
  scanner:Fire('SetDistanceOverride', 64, 0)
  scanner:Fire('SetFollowTarget', 'marker_'..uniqueID, 0)

  self.scanners[player] = { scanner, marker }

  timer.Create('scanner_sound_'..uniqueID, 0.01, 1, function()
    if IsValid(scanner) then
      scanner.flyLoop = CreateSound(scanner, 'npc/scanner/cbot_fly_loop.wav')
      scanner.flyLoop:Play()
    end
  end)

  scanner:CallOnRemove('Scanner Sound', function(scanner)
    if scanner.flyLoop then
      scanner.flyLoop:Stop()
    end
  end)
end

--- Adds a line to the Combine display of one or all Combine players.
--
-- Sent with the `CombineDisplayLine` netstream message; the client side is
-- `Schema:AddCombineDisplayLine` in `cl_schema.lua`.
-- @param text [String The text or language key to show]
-- @param color=nil [Color Colour of the line; white when `nil`]
-- @param player=nil [Player Only send the line to this player]
-- @param exclude=nil [Player A Combine player who does not receive the line]
function Schema:AddCombineDisplayLine(text, color, player, exclude)
  if player then
    netstream.Start(player, 'CombineDisplayLine', { text, color })
  else
    local players = {}

    for k, v in ipairs(_player.GetAll()) do
      if v:IsCombine() and v != exclude then
        players[#players + 1] = v
      end
    end

    netstream.Start(players, 'CombineDisplayLine', { text, color })
  end
end

--- Loads the Combine objectives from the `objectives` schema data into `Schema.combineObjectives`.
function Schema:LoadObjectives()
  local combineObjectives = cw.core:RestoreSchemaData('objectives')

  if combineObjectives and combineObjectives.text then
    self.combineObjectives = combineObjectives.text
  else
    self.combineObjectives = ''
  end
end

--- Spawns the named NPCs saved for the current map by `Schema:SaveNPCs`.
function Schema:LoadNPCs()
  local npcs = cw.core:RestoreSchemaData('plugins/npcs/'..game.GetMap())

  for k, v in pairs(npcs) do
    local entity = ents.Create(v.class)

    if IsValid(entity) then
      entity:SetKeyValue('spawnflags', v.spawnFlags or 0)
      entity:SetKeyValue('additionalequipment', v.equipment or '')
      entity:SetAngles(v.angles)
      entity:SetModel(v.model)
      entity:SetPos(v.position)
      entity:Spawn()

      if IsValid(entity) then
        entity:Activate()

        entity:SetNWString('cw_Name', v.name)
        entity:SetNWString('cw_Title', v.title)
      end
    end
  end
end

--- Saves every NPC with a name and title (set with the `SetNPCName` command) for the current map.
function Schema:SaveNPCs()
  local npcs = {}

  for k, v in pairs(ents.FindByClass('npc_*')) do
    local name = v:GetNWString('cw_Name')
    local title = v:GetNWString('cw_Title')

    if name != '' and title != '' then
      local keyValues = table.LowerKeyNames(v:GetKeyValues())

      npcs[#npcs + 1] = {
        spawnFlags = keyValues['spawnflags'],
        equipment = keyValues['additionalequipment'],
        position = v:GetPos(),
        angles = v:GetAngles(),
        model = v:GetModel(),
        title = title,
        class = v:GetClass(),
        name = name
      }
    end
  end

  cw.core:SaveSchemaData('plugins/npcs/'..game.GetMap(), npcs)
end

--- Spawns the stationary radios saved for the current map by `Schema:SaveRadios`.
--
-- Restores each radio's owner, frequency and on/off state, and freezes radios that were frozen.
function Schema:LoadRadios()
  local radios = cw.core:RestoreSchemaData('plugins/radios/'..game.GetMap())

  for k, v in pairs(radios) do
    local entity = ents.Create('cw_radio')

    cw.player:GivePropertyOffline(v.key, v.uniqueID, entity)

    entity:SetAngles(v.angles)
    entity:SetPos(v.position)
    entity:Spawn()

    if IsValid(entity) then
      entity:SetFrequency(v.frequency)
      entity:SetOff(v.off)
    end

    if !v.moveable then
      local physicsObject = entity:GetPhysicsObject()

      if IsValid(physicsObject) then
        physicsObject:EnableMotion(false)
      end
    end
  end
end

--- Spawns the ration dispensers saved for the current map by `Schema:SaveRationDispensers`.
function Schema:LoadRationDispensers()
  local dispensers = cw.core:RestoreSchemaData('plugins/dispensers/'..game.GetMap())

  for k, v in pairs(dispensers) do
    local entity = ents.Create('cw_rationdispenser')

    entity:SetPos(v.position)
    entity:Spawn()

    if IsValid(entity) then
      entity:SetAngles(v.angles)

      if !v.locked then
        entity:Unlock()
      else
        entity:Lock()
      end
    end
  end
end

--- Saves the position, angles and lock state of every ration dispenser for the current map.
function Schema:SaveRationDispensers()
  local dispensers = {}

  for k, v in pairs(ents.FindByClass('cw_rationdispenser')) do
    dispensers[#dispensers + 1] = {
      locked = v:IsLocked(),
      angles = v:GetAngles(),
      position = v:GetPos()
    }
  end

  cw.core:SaveSchemaData('plugins/dispensers/'..game.GetMap(), dispensers)
end

--- Spawns the vending machines saved for the current map by `Schema:SaveVendingMachines`.
function Schema:LoadVendingMachines()
  local machines = cw.core:RestoreSchemaData('plugins/machines/'..game.GetMap())

  for k, v in pairs(machines) do
    local entity = ents.Create('cw_vendingmachine')

    entity:SetPos(v.position)
    entity:Spawn()

    if IsValid(entity) then
      entity:SetAngles(v.angles)
      entity:SetStock(v.stock, v.defaultStock)
    end
  end
end

--- Saves the position, angles and stock of every vending machine for the current map.
function Schema:SaveVendingMachines()
  local machines = {}

  for k, v in pairs(ents.FindByClass('cw_vendingmachine')) do
    machines[#machines + 1] = {
      stock = v:GetStock(),
      angles = v:GetAngles(),
      position = v:GetPos(),
      defaultStock = v:GetDefaultStock()
    }
  end

  cw.core:SaveSchemaData('plugins/machines/'..game.GetMap(), machines)
end

--- Saves the position, owner, frequency and state of every stationary radio for the current map.
function Schema:SaveRadios()
  local radios = {}

  for k, v in pairs(ents.FindByClass('cw_radio')) do
    local physicsObject = v:GetPhysicsObject()
    local moveable

    if IsValid(physicsObject) then
      moveable = physicsObject:IsMoveable()
    end

    radios[#radios + 1] = {
      off = v:IsOff(),
      key = cw.entity:QueryProperty(v, 'key'),
      angles = v:GetAngles(),
      moveable = moveable,
      uniqueID = cw.entity:QueryProperty(v, 'uniqueID'),
      position = v:GetPos(),
      frequency = v:GetFrequency()
    }
  end

  cw.core:SaveSchemaData('plugins/radios/'..game.GetMap(), radios)
end

--- Sends a message through a player's request device.
--
-- The request is shown on the Combine display and sent to Combine players, administrators, CWU and
-- anyone carrying a request device. When a citizen sends it, nearby citizens overhear it.
-- @param player [Player The player sending the request]
-- @param text [String The message]
function Schema:SayRequest(player, text)
  local isCitizen = (player:GetFaction() == FACTION_CITIZEN)
  local shootPos = player:GetShootPos()
  local talkRadius = config.Get('talk_radius'):Get()
  local senderListens = false
  local eavesdroppers = {}
  local listeners = {}

  for k, v in ipairs(_player.GetAll()) do
    if v:HasInitialized() then
      if v:GetFaction() == FACTION_CITIZEN and isCitizen and player != v then
        if v:GetShootPos():Distance(shootPos) <= talkRadius then
          eavesdroppers[#eavesdroppers + 1] = v
        end
      else
        local isCityAdmin = (v:GetFaction() == FACTION_ADMIN or v:GetFaction() == FACTION_CWU)

        if v:HasItemByID('request_device') or v:IsCombine() or isCityAdmin then
          listeners[#listeners + 1] = v

          if v == player then
            senderListens = true
          end
        end
      end
    end
  end

  local citizenID = player:GetCharacterData('citizenid', 0)

  if citizenID == 0 then
    citizenID = 'N/A'
  end

  self:AddCombineDisplayLine(
    L('CombineDisplay_Request', player:Name(), citizenID)..' '..text, Color(218, 165, 32, 255)
  )

  local info = chatbox.AddText(listeners, '"'..text..'"', {
    suffix = ' #Suffix_Request ',
    sender = player,
    isPlayerMessage = true,
    filter = 'ic',
    radius = 0,
    textColor = Color(175, 125, 100, 255),
    data = { request = true }
  })

  if info and IsValid(info.sender) then
    -- info.text is already quoted.
    local eavesdropInfo = {
      suffix = ' #Suffix_Request ',
      sender = info.sender,
      isPlayerMessage = true,
      filter = 'ic',
      radius = 0,
      textColor = Color(255, 255, 150, 255),
      data = { request = true }
    }

    if #eavesdroppers > 0 then
      chatbox.AddText(eavesdroppers, info.text, eavesdropInfo)
    end

    if !senderListens then
      chatbox.AddText(player, info.text, eavesdropInfo)
    end
  end
end

--- Returns the name of the area a player is in, using the Area Names plugin.
--
-- When the player is in no area, the area whose minimum corner is closest is used. A leading "the " is
-- removed from the name.
-- @param player [Player The player]
-- @return [String The area name, or `'#Location_Unknown'` without the plugin or any areas]
function Schema:PlayerGetLocation(player)
  local areaNames = plugin.FindByID('Area Names')

  if areaNames then
    local shootPos = player:GetShootPos()
    local closestDistance
    local name

    for k, v in pairs(areaNames.areaNames) do
      if cw.entity:IsInBox(player, v.minimum, v.maximum) then
        name = v.name

        break
      end

      local distance = shootPos:DistToSqr(v.minimum)

      if !closestDistance or distance < closestDistance then
        closestDistance = distance
        name = v.name
      end
    end

    if name then
      if string.sub(string.lower(name), 1, 4) == 'the ' then
        return string.sub(name, 5)
      end

      return name
    end
  end

  return '#Location_Unknown'
end

--- Sends a broadcast message from a player to everyone.
-- @param player [Player The player broadcasting]
-- @param text [String The message]
function Schema:SayBroadcast(player, text)
  chatbox.AddText(nil, '"'..text..'"', {
    suffix = ' #Suffix_Broadcast ',
    sender = player,
    isPlayerMessage = true,
    filter = 'ic',
    radius = 0,
    textColor = Color(150, 125, 175, 255)
  })
end

--- Sends a message to everyone under the name of Dispatch.
-- @param player [Player The player sending the message]
-- @param text [String The message]
function Schema:SayDispatch(player, text)
  chatbox.AddText(nil, '"'..text..'"', {
    sender = player,
    suffix = ' #Suffix_Broadcast ',
    playerName = '#Dispatch_Name',
    forceName = true,
    isPlayerMessage = true,
    filter = 'ic',
    radius = 0,
    textColor = Color(150, 100, 100, 255),
    data = { dispatch = true }
  })
end

--- Returns whether a player is Combine, using `Player:IsCombine`.
-- @param player [Player The player to check]
-- @return [Boolean Whether the player is Combine, or `nil` for an invalid player]
function Schema:PlayerIsCombine(player)
  if IsValid(player) then
    return player:IsCombine()
  end
end

--- Returns whether a player's character belongs to the Civil Workers' Union.
-- @param player [Player The player to check]
-- @return [Boolean Whether the player is in `FACTION_CWU`, or `nil` without a valid player and character]
function Schema:PlayerIsCWU(player)
  if IsValid(player) and player:GetCharacter() then
    local faction = player:GetFaction()

    return faction == FACTION_CWU
  end
end

--- Attaches a Combine lock to a door.
-- @param entity [Entity The door]
-- @param position=nil [Vector Position of the lock; a trace result places it at the default spot on the
-- door, moved out along the hit normal]
-- @param angles=nil [Angle Angles of the lock]
-- @return [Entity The `cw_combinelock`, or `nil` when it failed to spawn]
function Schema:ApplyCombineLock(entity, position, angles)
  local combineLock = ents.Create('cw_combinelock')

  combineLock:SetParent(entity)
  combineLock:SetDoor(entity)

  if position then
    if type(position) == 'table' then
      combineLock:SetLocalPos(Vector(-1.0313, 43.7188, -1.2258))
      combineLock:SetPos(combineLock:GetPos() + (position.HitNormal * 4))
    else
      combineLock:SetPos(position)
    end
  end

  if angles then
    combineLock:SetAngles(angles)
  end

  combineLock:Spawn()

  if IsValid(combineLock) then
    return combineLock
  end
end

--- Puts clothes on a player, or takes off the clothes they wear.
--
-- Clothes are only put on when the player's class has no model of its own. The worn item is stored in
-- the `clothes` character data and net var, and the item's `OnChangeClothes` is called.
-- @param player [Player The player]
-- @param itemTable=nil [Item The clothes to wear; `nil` takes off the current clothes]
-- @param noMessage=nil [Boolean Unused]
function Schema:PlayerWearClothes(player, itemTable, noMessage)
  local clothes = player:GetCharacterData('clothes')

  if itemTable then
    local model = cw.class:GetAppropriateModel(player:Team(), player, true)

    if !model then
      itemTable:OnChangeClothes(player, true)

      player:SetCharacterData('clothes', itemTable.index)
      player:SetNetVar('clothes', itemTable.index)
    end
  else
    itemTable = item.FindByID(clothes)

    if itemTable then
      itemTable:OnChangeClothes(player, false)

      player:SetCharacterData('clothes', nil)
      player:SetNetVar('clothes', 0)
    end
  end
end

--- Returns how much health a player heals, based on their Medical attribute.
-- @param player [Player The player doing the healing]
-- @param scale=1 [Number Multiplier for the amount]
-- @return [Number 15 plus up to 35 for the Medical attribute, times `scale`]
function Schema:GetHealAmount(player, scale)
  local medical = cw.attributes:Fraction(player, ATB_MEDICAL, 35)
  local healAmount = (15 + medical) * (scale or 1)

  return healAmount
end

--- Returns how long a dexterity action such as tying takes a player, based on their Agility attribute.
-- @param player [Player The player]
-- @return [Number The time in seconds, from 7 down to 2 with full Agility]
function Schema:GetDexterityTime(player)
  return 7 - cw.attributes:Fraction(player, ATB_AGILITY, 5, 5)
end

--- Knocks down a door for five minutes.
--
-- Hides and unlocks the door, destroys its Combine lock, triggers its breach and throws a decaying
-- physics copy of it, away from the player unless a force is given. The door returns after 300 seconds.
-- @param player [Player The player busting the door down, or `nil`]
-- @param door [Entity The door]
-- @param force=nil [Vector Force applied to the fake door instead of pushing it away from the player]
function Schema:BustDownDoor(player, door, force)
  door.bustedDown = true

  door:SetNotSolid(true)
  door:DrawShadow(false)
  door:SetNoDraw(true)
  door:EmitSound('physics/wood/wood_box_impact_hard3.wav')
  door:Fire('unlock', '', 0)

  if IsValid(door.combineLock) then
    door.combineLock:Explode()
    door.combineLock:Remove()
  end

  if IsValid(door.breach) then
    door.breach:BreachEntity()
  end

  local fakeDoor = ents.Create('prop_physics')

  fakeDoor:SetCollisionGroup(COLLISION_GROUP_WORLD)
  fakeDoor:SetAngles(door:GetAngles())
  fakeDoor:SetModel(door:GetModel())
  fakeDoor:SetSkin(door:GetSkin())
  fakeDoor:SetPos(door:GetPos())
  fakeDoor:Spawn()

  local physicsObject = fakeDoor:GetPhysicsObject()

  if IsValid(physicsObject) then
    if !force then
      if IsValid(player) then
        physicsObject:ApplyForceCenter((door:GetPos() - player:GetPos()):GetNormalized() * 10000)
      end
    else
      physicsObject:ApplyForceCenter(force)
    end
  end

  cw.entity:Decay(fakeDoor, 300)

  timer.Create('reset_door_'..door:EntIndex(), 300, 1, function()
    if IsValid(door) then
      door.bustedDown = nil
      door:SetNotSolid(false)
      door:DrawShadow(true)
      door:SetNoDraw(false)
    end
  end)
end

--- Permanently kills a player's character.
--
-- Kills the player if alive and, unless the character is already permakilled, marks it permakilled
-- and moves its inventory and cash onto the ragdoll as belongings, or into a `cw_belongings` entity when
-- there is no ragdoll. Items with `allowStorage = false` are lost. Runs the
-- `PlayerAdjustPermaKillInfo` hook with the `inventory`, `cash` and `entity` info, and saves the
-- character.
-- @param player [Player The player]
-- @param ragdoll=nil [Entity The player's ragdoll, if they are already dead]
function Schema:PermaKillPlayer(player, ragdoll)
  if player:Alive() then
    player:Kill()
    ragdoll = player:GetRagdollEntity()
  end

  local inventory = player:GetInventory()
  local cash = player:GetCash()
  local info = {}

  if !player:GetCharacterData('permakilled') then
    info.inventory = inventory
    info.cash = cash

    if !IsValid(ragdoll) then
      info.entity = ents.Create('cw_belongings')
    end

    hook.Run('PlayerAdjustPermaKillInfo', player, info)

    for k, v in pairs(info.inventory) do
      local itemTable = item.FindByID(k)

      if itemTable and itemTable.allowStorage == false then
        info.inventory[k] = nil
      end
    end

    player:SetCharacterData('permakilled', true)
    player:SetNetVar('permaKilled', true)
    player:SetCharacterData('inventory', {}, true)
    player:SetCharacterData('cash', 0, true)

    if !IsValid(ragdoll) then
      if table.Count(info.inventory) > 0 or info.cash > 0 then
        info.entity:SetData(info.inventory, info.cash)
        info.entity:SetPos(player:GetPos() + Vector(0, 0, 48))
        info.entity:Spawn()
      else
        info.entity:Remove()
      end
    else
      ragdoll.areBelongings = true
      ragdoll.cwInventory = info.inventory
      ragdoll.cash = info.cash
    end

    cw.player:SaveCharacter(player)
  end
end

--- Ties or unties a player.
--
-- Sets the `tied` net var to `0` (untied), `1` (tied) or `2` (tied by the Combine). Tying drops and
-- strips the player's weapons; untying light-spawns them to give their weapons back. Both are logged.
-- @param player [Player The player]
-- @param isTied [Boolean Whether to tie the player]
-- @param reset=nil [Boolean When untying, skip the light spawn and the log entry]
-- @param combine=nil [Boolean Whether the Combine tied the player]
function Schema:TiePlayer(player, isTied, reset, combine)
  if isTied then
    if combine then
      player:SetNetVar('tied', 2)
    else
      player:SetNetVar('tied', 1)
    end
  else
    player:SetNetVar('tied', 0)
  end

  if isTied then
    cw.player:DropWeapons(player)
    cw.core:PrintLog(LOGTYPE_GENERIC, player:Name()..' has been tied.')

    player:Flashlight(false)
    player:StripWeapons()
  elseif !reset then
    if player:Alive() and !player:IsRagdolled() then
      cw.player:LightSpawn(player, true, true)
    end

    cw.core:PrintLog(LOGTYPE_GENERIC, player:Name()..' has been untied.')
  end
end
