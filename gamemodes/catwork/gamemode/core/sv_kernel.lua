--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

--[[ Downloads the content addon for clients. --]]
resource.AddWorkshop('474315121')

resource.AddFile('resource/fonts/fontawesome-webfont.ttf')
resource.AddFile('resource/fonts/kellyslab.ttf')

cw.core:AddDirectory('resource/fonts/')

--[[
  Derive from Sandbox, because we want the spawn menu and such!
  We also want the base Sandbox entities and weapons.
--]]
DeriveGamemode('sandbox')

--[[
  This is a hack to stop file.Read returning an unnecessary newline
  at the end of each file when using Linux.
--]]

if system.IsLinux() then
  ClockworkFileRead = ClockworkFileRead or file.Read

  --- Reads a file like the stock `file.Read`, dropping one trailing newline from the contents.
  --
  -- Defined only on Linux servers, where the original is kept as `ClockworkFileRead`.
  -- @param fileName [String Path of the file to read]
  -- @param pathName [String Search path, as for the stock `file.Read` (e.g. `'GAME'` or `'DATA'`)]
  -- @return [String The file contents, or `nil` if the file could not be read]
  function file.Read(fileName, pathName)
    local contents = ClockworkFileRead(fileName, pathName)

    if contents and string.utf8sub(contents, -1) == '\n' then
      contents = string.utf8sub(contents, 1, -2)
    end

    return contents
  end
end

--- Escapes a value for an SQLite query, replacing the stock `sql.SQLStr`.
--
-- Converts the value with `tostring` and cuts it at the first NULL character. Unlike the stock version it
-- does not double single quotes, which used to duplicate `'` characters.
-- @param str_in [Any Value to escape]
-- @param bNoQuotes=nil [Boolean Whether to return the string without surrounding single quotes]
-- @return [String The value as a string, wrapped in single quotes unless `bNoQuotes` is set]
function sql.SQLStr(str_in, bNoQuotes)
  local str = tostring(str_in)

  local null_chr = string.find(str, '\0')

  if null_chr then
    str = string.utf8sub(str, 1, null_chr - 1)
  end

  if bNoQuotes then
    return str
  end

  return "'"..str.."'"
end

-- File.write creates missing folders itself, File.append does not and
-- cw.core:ServerLog needs this one. File.mkdir is recursive.
File.mkdir('logs/clockwork')

base64 = base64 or {}

--- Encodes a value as Base64.
--
-- Uses `util.Base64Encode` without line breaks; it is binary safe, so NULL characters need no special
-- treatment.
-- @param str [Any Value to encode; converted with `tostring`]
-- @return [String The Base64 encoded string]
-- @see base64.decode
function base64.encode(str)
  return util.Base64Encode(tostring(str), true)
end

--- Decodes a Base64 string with `util.Base64Decode`.
-- @param str [String Base64 encoded string]
-- @return [String The decoded data, or `nil` if the string is not valid Base64]
-- @see base64.encode
function base64.decode(str)
  return util.Base64Decode(str)
end

local ServerLog = ServerLog
local cvars = cvars

cw.Entities = cw.Entities or {}
cw.HitGroupBonesCache = {
  { 'ValveBiped.Bip01_R_UpperArm', HITGROUP_RIGHTARM },
  { 'ValveBiped.Bip01_R_Forearm', HITGROUP_RIGHTARM },
  { 'ValveBiped.Bip01_L_UpperArm', HITGROUP_LEFTARM },
  { 'ValveBiped.Bip01_L_Forearm', HITGROUP_LEFTARM },
  { 'ValveBiped.Bip01_R_Thigh', HITGROUP_RIGHTLEG },
  { 'ValveBiped.Bip01_R_Calf', HITGROUP_RIGHTLEG },
  { 'ValveBiped.Bip01_R_Foot', HITGROUP_RIGHTLEG },
  { 'ValveBiped.Bip01_R_Hand', HITGROUP_RIGHTARM },
  { 'ValveBiped.Bip01_L_Thigh', HITGROUP_LEFTLEG },
  { 'ValveBiped.Bip01_L_Calf', HITGROUP_LEFTLEG },
  { 'ValveBiped.Bip01_L_Foot', HITGROUP_LEFTLEG },
  { 'ValveBiped.Bip01_L_Hand', HITGROUP_LEFTARM },
  { 'ValveBiped.Bip01_Pelvis', HITGROUP_STOMACH },
  { 'ValveBiped.Bip01_Spine2', HITGROUP_CHEST },
  { 'ValveBiped.Bip01_Spine1', HITGROUP_CHEST },
  { 'ValveBiped.Bip01_Head1', HITGROUP_HEAD },
  { 'ValveBiped.Bip01_Neck1', HITGROUP_HEAD }
}

cw.MeleeTranslation = {
  [ACT_HL2MP_GESTURE_RANGE_ATTACK] = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2,
  [ACT_HL2MP_GESTURE_RELOAD] = ACT_HL2MP_GESTURE_RELOAD_MELEE2,
  [ACT_HL2MP_WALK_CROUCH] = ACT_HL2MP_WALK_CROUCH_MELEE2,
  [ACT_HL2MP_IDLE_CROUCH] = ACT_HL2MP_IDLE_CROUCH_MELEE2,
  [ACT_RANGE_ATTACK1] = ACT_RANGE_ATTACK1_MELEE2,
  [ACT_HL2MP_IDLE] = ACT_HL2MP_IDLE_MELEE2,
  [ACT_HL2MP_WALK] = ACT_HL2MP_WALK_MELEE2,
  [ACT_HL2MP_JUMP] = ACT_HL2MP_JUMP_MELEE2,
  [ACT_HL2MP_RUN] = ACT_HL2MP_RUN_MELEE2
}

cw.WorkshopMaps = {
  md_venetianredux_b2fix = 106094354,
  rp_c18_v1 						= 132931674,
  rp_c18_v2 						= 132937160,
  rp_city8 = 132913036,
  rp_city8_2 = 132940295,
  rp_city8_canals = 132911524,
  rp_city8_district1 				= 132919876,
  rp_city8_district9 				= 132916875,
  rp_city11_night_v1b 			= 127632645,
  rp_city17_v1 = 113352748,
  rp_city23_night 				= 143076340,
  rp_city45_2013 					= 118759412,
  rp_city45_catalyst_x1f_final = 221567663,
  rp_nc_industrial17_v2 = 698222128,
  rp_nc_city8_v2a = 736405289,
  rp_gc_city8 = 760771478
}

--- Serializes a table and writes it to the current schema's data folder.
--
-- The file is `settings/catwork/schemas/<schema>/<fileName>.cw`, encoded with `cw.core:Serialize`.
-- Prints an error and saves nothing when `data` is not a table.
-- @param fileName [String File name without extension; may contain subfolders]
-- @param data [Map Table to save]
-- @param bForceJSON=nil [Boolean Whether to encode as JSON instead of pON]
-- @return [Boolean The result of `File.write`, or `nil` when `data` is not a table]
-- @see cw.core:RestoreSchemaData
function cw.core:SaveSchemaData(fileName, data, bForceJSON)
  if type(data) != 'table' then
    MsgC(
      Color(255, 100, 0, 255),
      "[CW:Kernel] The '"..fileName.."' schema data has failed to save.\nUnable to save type "..type(data)..
        ', table required.\n'
    )
    return
  end

  return File.write('settings/catwork/schemas/'..cw.Schema..'/'..fileName..'.cw', self:Serialize(data, bForceJSON))
end

--- Deletes a file from the current schema's data folder.
-- @param fileName [String File name without extension, as passed to `cw.core:SaveSchemaData`]
-- @return [Boolean The result of `File.delete`]
function cw.core:DeleteSchemaData(fileName)
  return File.delete('settings/catwork/schemas/'..cw.Schema..'/'..fileName..'.cw')
end

--- Returns whether a file exists in the current schema's data folder.
-- @param fileName [String File name without extension, as passed to `cw.core:SaveSchemaData`]
-- @return [Boolean Whether the file exists]
function cw.core:SchemaDataExists(fileName)
  return _file.Exists('settings/catwork/schemas/'..cw.Schema..'/'..fileName..'.cw', 'GAME')
end

--- Returns the path of the current schema's data folder.
-- @return [String The path, `settings/catwork/schemas/<schema>`, relative to the `garrysmod` folder]
function cw.core:GetSchemaDataPath()
  return 'settings/catwork/schemas/'..cw.Schema
end

SCHEMA_GAMEMODE_INFO = SCHEMA_GAMEMODE_INFO or nil

--- Returns the schema's gamemode information from its gamemode `.txt` file.
--
-- Reads `gamemodes/<schema>/<schema>.txt` once and caches the result in the `SCHEMA_GAMEMODE_INFO` global.
-- Missing fields are `'Undefined'`.
-- @return [Map The `name` (the file's `title`), `author`, `description` and `version` of the schema]
function cw.core:GetSchemaGamemodeInfo()
  if SCHEMA_GAMEMODE_INFO then return SCHEMA_GAMEMODE_INFO end

  local schemaFolder = string.lower(self:GetSchemaFolder())
  local schemaData = util.KeyValuesToTable(
    File.read('gamemodes/'..schemaFolder..'/'..schemaFolder..'.txt')
  )

  if !schemaData then
    schemaData = {}
  end

  if schemaData['Gamemode'] then
    schemaData = schemaData['Gamemode']
  end

  SCHEMA_GAMEMODE_INFO = {}
    SCHEMA_GAMEMODE_INFO['name'] = schemaData['title'] or 'Undefined'
    SCHEMA_GAMEMODE_INFO['author'] = schemaData['author'] or 'Undefined'
    SCHEMA_GAMEMODE_INFO['description'] = schemaData['description'] or 'Undefined'
    SCHEMA_GAMEMODE_INFO['version'] = schemaData['version'] or 'Undefined'
  return SCHEMA_GAMEMODE_INFO
end

--- Returns the name of the loaded schema.
-- @return [String The schema's name from `Schema:GetName`, or `'Catwork'` before the schema has loaded]
function cw.core:GetSchemaGamemodeName()
  if Schema then
    return Schema:GetName()
  else
    return 'Catwork'
  end
end

--- Returns the version of the schema from its gamemode `.txt` file.
-- @return [String The version, or `'Undefined'` if the file does not set one]
-- @see cw.core:GetSchemaGamemodeInfo
function cw.core:GetSchemaGamemodeVersion()
  local schemaInfo = self:GetSchemaGamemodeInfo()

  return schemaInfo['version']
end

--- Finds files and folders in the current schema's data folder.
-- @param directory [String Path and wildcard relative to the schema data folder, e.g. `'plugins/*'`]
-- @return [List<String> File names, List<String> Folder names, as returned by `file.Find`]
function cw.core:FindSchemaDataInDir(directory)
  return _file.Find('settings/catwork/schemas/'..self:GetSchemaFolder()..'/'..directory, 'GAME')
end

--- Reads and deserializes a file from the current schema's data folder.
--
-- If the file cannot be deserialized, an error is printed and the file is deleted.
-- @param fileName [String File name without extension, as passed to `cw.core:SaveSchemaData`]
-- @param failSafe=nil [Any Value to return when the file is missing or invalid; an empty table if `nil`]
-- @param bForceJSON=nil [Boolean Whether the file is JSON instead of pON]
-- @return [Any The stored table, or `failSafe` when it could not be restored]
-- @see cw.core:SaveSchemaData
function cw.core:RestoreSchemaData(fileName, failSafe, bForceJSON)
  if self:SchemaDataExists(fileName) then
    local data = File.read('settings/catwork/schemas/'..cw.Schema..'/'..fileName..'.cw')

    if data then
      local bSuccess, value = pcall(self.Deserialize, self, data, bForceJSON)

      if bSuccess and value != nil then
        return value
      elseif !bSuccess then
        MsgC(
          Color(255, 100, 0, 255),
          "[CW:Kernel] '"..fileName.."' schema data has failed to restore.\n"..tostring(value)..'\n'
        )

        self:DeleteSchemaData(fileName)
      end
    end
  end

  if failSafe != nil then
    return failSafe
  else
    return {}
  end
end

--- Reads and deserializes a file from the framework-wide data folder, `settings/clockwork/`.
--
-- If the file cannot be deserialized, an error is printed and the file is deleted.
-- @param fileName [String File name without extension, as passed to `cw.core:SaveClockworkData`]
-- @param failSafe=nil [Any Value to return when the file is missing or invalid; an empty table if `nil`]
-- @return [Any The stored table, or `failSafe` when it could not be restored]
-- @see cw.core:SaveClockworkData
function cw.core:RestoreClockworkData(fileName, failSafe)
  if self:ClockworkDataExists(fileName) then
    local data = File.read('settings/clockwork/'..fileName..'.cw')

    if data then
      local bSuccess, value = pcall(self.Deserialize, self, data)

      if bSuccess and value != nil then
        return value
      else
        MsgC(Color(255, 100, 0, 255), "[CW:Kernel] '"..fileName.."' catwork data has failed to restore.\n"..value..'\n')

        self:DeleteClockworkData(fileName)
      end
    end
  end

  if failSafe != nil then
    return failSafe
  else
    return {}
  end
end

--- Serializes a table with pON and writes it to `settings/clockwork/<fileName>.cw`.
--
-- Unlike schema data, this data is shared by every schema. Prints an error and saves nothing when `data`
-- is not a table.
-- @param fileName [String File name without extension]
-- @param data [Map Table to save]
-- @return [Boolean The result of `File.write`, or `nil` when `data` is not a table]
-- @see cw.core:RestoreClockworkData
function cw.core:SaveClockworkData(fileName, data)
  if type(data) != 'table' then
    MsgC(
      Color(255, 100, 0, 255),
      "[CW:Kernel] The '"..fileName.."' clockwork data has failed to save.\nUnable to save type "..type(data)..
        ', table required.\n'
    )

    return
  end

  return File.write('settings/clockwork/'..fileName..'.cw', self:Serialize(data))
end

--- Returns whether a file exists in the framework-wide data folder, `settings/clockwork/`.
-- @param fileName [String File name without extension]
-- @return [Boolean Whether the file exists]
function cw.core:ClockworkDataExists(fileName)
  return _file.Exists('settings/clockwork/'..fileName..'.cw', 'GAME')
end

--- Deletes a file from the framework-wide data folder, `settings/clockwork/`.
-- @param fileName [String File name without extension]
-- @return [Boolean The result of `File.delete`]
function cw.core:DeleteClockworkData(fileName)
  return File.delete('settings/clockwork/'..fileName..'.cw')
end

--- Scales a force vector down so that its length does not exceed a limit.
--
-- Used to keep damage forces applied to ragdolls and players within reason.
-- @param force [Vector The force to limit]
-- @param limit=800 [Number Maximum length of the returned vector]
-- @return [Vector The force, shortened to `limit` if it was longer, or a zero vector for a zero force]
function cw.core:ConvertForce(force, limit)
  local forceLength = force:Length()

  if forceLength == 0 then
    return Vector(0, 0, 0)
  end

  if !limit then
    limit = 800
  end

  if forceLength > limit then
    return force / (forceLength / limit)
  else
    return force
  end
end

--- Stores a player's attribute boosts in their character data so they survive a reconnect.
--
-- Writes the `AttrBoosts` key of `data`, keeping the remaining duration of timed boosts and dropping
-- expired ones. Called from `PlayerSaveCharacterData` when the `save_attribute_boosts` config is on.
-- @param player [Player The player whose boosts are saved]
-- @param data [Map The character data table being saved]
-- @warning [Internal] Called by the kernel when a character is saved.
function cw.core:SavePlayerAttributeBoosts(player, data)
  local attributeBoosts = player:GetAttributeBoosts()
  local curTime = CurTime()

  if data['AttrBoosts'] then
    data['AttrBoosts'] = nil
  end

  if table.Count(attributeBoosts) > 0 then
    data['AttrBoosts'] = {}

    for k, v in pairs(attributeBoosts) do
      data['AttrBoosts'][k] = {}

      for k2, v2 in pairs(v) do
        if v2.duration then
          if curTime < v2.endTime then
            data['AttrBoosts'][k][k2] = {
              duration = math.ceil(v2.endTime - curTime),
              amount = v2.amount
            }
          end
        else
          data['AttrBoosts'][k][k2] = {
            amount = v2.amount
          }
        end
      end
    end
  end
end

--- Starts a dead player's respawn timer.
--
-- The delay is the `spawn_time` config, adjusted by the `PlayerAdjustDeathInfo` hook through an info table
-- with `attacker`, `inflictor`, `spawnTime` and `damageInfo`. Sets the player's `spawn` action when the
-- resulting time is above zero.
-- @param player [Player The player who died]
-- @param inflictor [Entity The entity that inflicted the damage]
-- @param attacker [Entity The entity that caused the death]
-- @param damageInfo=nil [CTakeDamageInfo The fatal damage]
function cw.core:CalculateSpawnTime(player, inflictor, attacker, damageInfo)
  local info = {
    attacker = attacker,
    inflictor = inflictor,
    spawnTime = config.GetVal('spawn_time'),
    damageInfo = damageInfo
  }

  hook.Run('PlayerAdjustDeathInfo', player, info)

  if info.spawnTime and info.spawnTime > 0 then
    cw.player:SetAction(player, 'spawn', info.spawnTime, 3)
  end
end

--- Spawns an `infodecal` entity that paints a decal at a position.
-- @param texture [String Material path of the decal]
-- @param position [Vector Where to place the decal]
-- @param temporary=nil [Boolean Whether the decal is low priority, so the engine may remove it]
-- @return [Entity The decal entity]
function cw.core:CreateDecal(texture, position, temporary)
  local decal = ents.Create('infodecal')

  if temporary then
    decal:SetKeyValue('LowPriority', 'true')
  end

  decal:SetKeyValue('Texture', texture)
  decal:SetPos(position)
  decal:Spawn()
  decal:Fire('activate')

  return decal
end

--- Blocks or restores a weapon's primary and secondary fire based on the `PlayerCanFireWeapon` hook.
--
-- When firing is not allowed, the next fire time is pushed a minute ahead and the original time is kept
-- on the weapon to restore once firing is allowed again. The SMG's secondary fire is never delayed.
-- @param player [Player The player holding the weapon]
-- @param bIsRaised [Boolean Whether the weapon is raised]
-- @param weapon [Weapon The weapon]
-- @param curTime [Number The current `CurTime`]
function cw.core:HandleWeaponFireDelay(player, bIsRaised, weapon, curTime)
  local delaySecondaryFire = nil
  local delayPrimaryFire = nil

  if !hook.Run('PlayerCanFireWeapon', player, bIsRaised, weapon, true) then
    delaySecondaryFire = curTime + 60
  end

  if !hook.Run('PlayerCanFireWeapon', player, bIsRaised, weapon) then
    delayPrimaryFire = curTime + 60
  end

  if delaySecondaryFire == nil and weapon.secondaryFireDelayed then
    weapon:SetNextSecondaryFire(weapon.secondaryFireDelayed)
    weapon.secondaryFireDelayed = nil
  end

  if delayPrimaryFire == nil and weapon.primaryFireDelayed then
    weapon:SetNextPrimaryFire(weapon.primaryFireDelayed)
    weapon.primaryFireDelayed = nil
  end

  if delaySecondaryFire then
    if !weapon.secondaryFireDelayed then
      weapon.secondaryFireDelayed = weapon:GetNextSecondaryFire()
    end

    --[[
      This is a terrible hotfix for the SMG not being able
      to fire after loading ammunition.
    --]]

    if weapon:GetClass() != 'weapon_smg1' then
      weapon:SetNextSecondaryFire(delaySecondaryFire)
    end
  end

  if delayPrimaryFire then
    if !weapon.primaryFireDelayed then
      weapon.primaryFireDelayed = weapon:GetNextPrimaryFire()
    end

    weapon:SetNextPrimaryFire(delayPrimaryFire)
  end
end

--- Applies damage to a player's armor, health and limbs.
--
-- Bullet, club and slash damage is taken from armor first (only on the chest and generic hit groups when
-- `armor_chest_only` is on); damage that gets through hurts the hit limb with `cw.limb:TakeDamage`.
-- Health never drops below 1 here, and fall damage also hurts both legs.
-- @param player [Player The damaged player]
-- @param hitGroup [Number The `HITGROUP_*` that was hit]
-- @param damageInfo [CTakeDamageInfo The damage]
function cw.core:CalculatePlayerDamage(player, hitGroup, damageInfo)
  local bDamageIsValid =
    damageInfo:IsBulletDamage() or damageInfo:IsDamageType(DMG_CLUB) or damageInfo:IsDamageType(DMG_SLASH)
  local bHitGroupIsValid = true

  if config.GetVal('armor_chest_only') then
    if hitGroup != HITGROUP_CHEST and hitGroup != HITGROUP_GENERIC then
      bHitGroupIsValid = nil
    end
  end

  if player:Armor() > 0 and bDamageIsValid and bHitGroupIsValid then
    local armor = player:Armor() - damageInfo:GetDamage()

    if armor < 0 then
      cw.limb:TakeDamage(player, hitGroup, damageInfo:GetDamage() * 2)
      player:SetHealth(math.max(player:Health() - math.abs(armor), 1))
      player:SetArmor(math.max(armor, 0))
    else
      player:SetArmor(math.max(armor, 0))
    end
  else
    cw.limb:TakeDamage(player, hitGroup, damageInfo:GetDamage() * 2)
    player:SetHealth(math.max(player:Health() - damageInfo:GetDamage(), 1))
  end

  if damageInfo:IsFallDamage() then
    cw.limb:TakeDamage(player, HITGROUP_RIGHTLEG, damageInfo:GetDamage())
    cw.limb:TakeDamage(player, HITGROUP_LEFTLEG, damageInfo:GetDamage())
  end
end

--- Returns the bone of a ragdoll closest to a position.
--
-- Only the bones listed in `cw.HitGroupBonesCache` are considered.
-- @param entity [Entity The ragdoll]
-- @param position [Vector The position to check, usually the damage position]
-- @param failSafe=nil [Any Value to return when no bone is close enough]
-- @param minimum=nil [Number Maximum distance a bone may be from the position]
-- @return [Number The bone index, or `failSafe`]
function cw.core:GetRagdollHitBone(entity, position, failSafe, minimum)
  local closest = {}

  for k, v in pairs(cw.HitGroupBonesCache) do
    local bone = entity:LookupBone(v[1])

    if bone then
      local bonePosition = entity:GetBonePosition(bone)

      if bonePosition then
        local distance = bonePosition:Distance(position)

        if !closest[1] or distance < closest[1] then
          if !minimum or distance <= minimum then
            closest[1] = distance
            closest[2] = bone
          end
        end
      end
    end
  end

  if closest[2] then
    return closest[2]
  else
    return failSafe
  end
end

--- Returns the hit group of the ragdoll bone closest to a position.
-- @param entity [Entity The ragdoll]
-- @param position [Vector The position to check, usually the damage position]
-- @return [Number The `HITGROUP_*` of the closest bone in `cw.HitGroupBonesCache`, or `HITGROUP_GENERIC`]
function cw.core:GetRagdollHitGroup(entity, position)
  local closest = { nil, HITGROUP_GENERIC }

  for k, v in pairs(cw.HitGroupBonesCache) do
    local bone = entity:LookupBone(v[1])

    if bone then
      local bonePosition = entity:GetBonePosition(bone)

      if position then
        local distance = bonePosition:Distance(position)

        if !closest[1] or distance < closest[1] then
          closest[1] = distance
          closest[2] = v[2]
        end
      end
    end
  end

  return closest[2]
end

--- Plays blood smoke and impact effects at a position and sprays blood decals.
--
-- Does nothing if the entity bled less than half a second ago.
-- @param position [Vector Where the blood appears]
-- @param decals [Number How many blood decals to trace]
-- @param entity [Entity The bleeding entity; also filtered out of the decal traces]
-- @param forceVec=nil [Vector Direction of the blood smoke; random if `nil`]
-- @param fScale=0.5 [Number Scale of the effects]
function cw.core:CreateBloodEffects(position, decals, entity, forceVec, fScale)
  if !entity.cwNextBlood or CurTime() >= entity.cwNextBlood then
    local effectData = EffectData()
      effectData:SetOrigin(position)
      effectData:SetNormal(forceVec or (VectorRand() * 80))
      effectData:SetScale(fScale or 0.5)
    util.Effect('cw_bloodsmoke', effectData, true, true)

    local effectData = EffectData()
      effectData:SetOrigin(position)
      effectData:SetEntity(entity)
      effectData:SetStart(position)
      effectData:SetScale(fScale or 0.5)
    util.Effect('BloodImpact', effectData, true, true)

    for i = 1, decals do
      local trace = {}
        trace.start = position
        trace.endpos = trace.start
        trace.filter = entity
      trace = util.TraceLine(trace)

      util.Decal('Blood', trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal)
    end

    entity.cwNextBlood = CurTime() + 0.5
  end
end

--- Advances the in-game clock by one minute, rolling over hours, days, months and years.
--
-- Runs the `TimePassed` hook with `TIME_MINUTE`, `TIME_HOUR`, `TIME_DAY`, `TIME_MONTH` or `TIME_YEAR` for
-- each unit that changed and networks the time and date with `netvars.SetNetVar`.
-- @warning [Internal] Called by the kernel every `minute_time` seconds (one in-game minute).
function cw.core:PerformDateTimeThink()
  local defaultDays = cw.option:GetKey('default_days')
  local minute = cw.time:GetMinute()
  local month = cw.date:GetMonth()
  local year = cw.date:GetYear()
  local hour = cw.time:GetHour()
  local day = cw.time:GetDay()

  cw.time.minute = cw.time:GetMinute() + 1

  if cw.time:GetMinute() >= 60 then
    cw.time.minute = 0
    cw.time.hour = cw.time:GetHour() + 1

    if cw.time:GetHour() >= 24 then
      cw.time.hour = 0
      cw.time.day = cw.time:GetDay() + 1
      cw.date.day = cw.date:GetDay() + 1

      if cw.time:GetDay() == #defaultDays + 1 then
        cw.time.day = 1
      end

      if cw.date:GetDay() >= 31 then
        cw.date.day = 1
        cw.date.month = cw.date:GetMonth() + 1

        if cw.date:GetMonth() >= 13 then
          cw.date.month = 1
          cw.date.year = cw.date:GetYear() + 1
        end
      end
    end
  end

  if cw.time:GetMinute() != minute then
    hook.Run('TimePassed', TIME_MINUTE)
  end

  if cw.time:GetHour() != hour then
    hook.Run('TimePassed', TIME_HOUR)
  end

  if cw.time:GetDay() != day then
    hook.Run('TimePassed', TIME_DAY)
  end

  if cw.date:GetMonth() != month then
    hook.Run('TimePassed', TIME_MONTH)
  end

  if cw.date:GetYear() != year then
    hook.Run('TimePassed', TIME_YEAR)
  end

  local month = self:ZeroNumberToDigits(cw.date:GetMonth(), 2)
  local day = self:ZeroNumberToDigits(cw.date:GetDay(), 2)

  netvars.SetNetVar('minute', minute)
  netvars.SetNetVar('hour', hour)
  netvars.SetNetVar('date', day..'/'..month..'/'..year)
  netvars.SetNetVar('day', day)
end

--- Creates a console variable and runs the `ClockworkConVarChanged` hook whenever it changes.
-- @param name [String Name of the convar]
-- @param value [String Default value]
-- @param flags=nil [Number `FCVAR_*` flags; replicated, notify and archive when `nil`]
-- @param Callback=nil [Function Called as `Callback(conVar, previousValue, newValue)` on every change]
-- @return [ConVar The created convar]
function cw.core:CreateConVar(name, value, flags, Callback)
  local conVar = CreateConVar(name, value, flags or FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)

  cvars.AddChangeCallback(name, function(conVar, previousValue, newValue)
    hook.Run('ClockworkConVarChanged', conVar, previousValue, newValue)

    if Callback then
      Callback(conVar, previousValue, newValue)
    end
  end)

  return conVar
end

--- Returns whether the server is shutting down.
--
-- Set in the `ShutDown` hook; used to skip work such as dropping belongings while the map unloads.
-- @return [Boolean `true` during shutdown, otherwise `nil`]
function cw.core:IsShuttingDown()
  return cw.ShuttingDown
end

--- Pays wages to every initialized, living player.
--
-- For each player the `PlayerModifyWagesInfo` hook may change the `wages` field of an info table. When
-- `PlayerCanEarnWagesCash` allows it and the wages are positive, `PlayerGiveWagesCash` decides whether the
-- cash is given with `cw.player:GiveCash`; `PlayerEarnWagesCash` runs afterwards in any case.
-- @warning [Internal] Called by the kernel every `wages_interval` seconds.
function cw.core:DistributeWagesCash()
  for k, v in ipairs(_player.GetAll()) do
    if v:HasInitialized() and v:Alive() then
      local info = {
        wages = v:GetWages()
      }

      hook.Run('PlayerModifyWagesInfo', v, info)

      if hook.Run('PlayerCanEarnWagesCash', v, info.wages) then
        if info.wages > 0 then
          if hook.Run('PlayerGiveWagesCash', v, info.wages, v:GetWagesName()) then
            cw.player:GiveCash(v, info.wages, v:GetWagesName())
          end
        end

        hook.Run('PlayerEarnWagesCash', v, info.wages)
      end
    end
  end
end

--- Loads the schema, loading the config before and after it.
-- @warning [Internal] Called once while the framework boots, from `shared.lua`.
function cw.core:IncludeSchema()
  local schemaFolder = self:GetSchemaFolder()

  if schemaFolder and type(schemaFolder) == 'string' then
    config.Load(nil, true)
      self:LoadSchema()
    config.Load()
  end
end

--- Sends a log message to admins who have log display enabled and writes it to the server log.
--
-- Admins receive it when their `cwShowLog` client convar is `1`. On dedicated servers with
-- `CW_CONVAR_LOG` enabled the message is also passed to `cw.core:ServerLog`.
-- @param logType=LOGTYPE_GENERIC [Number One of the `LOGTYPE_*` enums]
-- @param text [String The message]
function cw.core:PrintLog(logType, text)
  local listeners = {}
  local plyTable = _player.GetAll()

  for k, v in ipairs(plyTable) do
    if v:HasInitialized() and v:GetInfoNum('cwShowLog', 0) == 1 then
      if cw.player:IsAdmin(v) then
        listeners[#listeners + 1] = v
      end
    end
  end

  netstream.Start(listeners, 'Log', {
    logType = (logType or 5), text = text
  })

  if CW_CONVAR_LOG:GetInt() == 1 and game.IsDedicated() then
    self:ServerLog(text)
  end
end

--- Writes a message to the server log and to the day's Catwork log file.
--
-- Appends a timestamped line to `logs/clockwork/<YYYY-MM-DD>.log`, passes the text to the engine's
-- `ServerLog` and runs the `ClockworkLog` hook with the text and the Unix time.
-- @param text [String The message; newlines are removed in the log file]
function cw.core:ServerLog(text)
  local dateInfo = os.date('*t')
  local unixTime = os.time()

  if dateInfo then
    if dateInfo.month < 10 then dateInfo.month = '0'..dateInfo.month end
    if dateInfo.day < 10 then dateInfo.day = '0'..dateInfo.day end
    local fileName = dateInfo.year..'-'..dateInfo.month..'-'..dateInfo.day

    if dateInfo.hour < 10 then dateInfo.hour = '0'..dateInfo.hour end
    if dateInfo.min < 10 then dateInfo.min = '0'..dateInfo.min end
    if dateInfo.sec < 10 then dateInfo.sec = '0'..dateInfo.sec end
    local time = dateInfo.hour..':'..dateInfo.min..':'..dateInfo.sec
    local logText = time..': '..string.gsub(text, '\n', '')

    File.append('logs/clockwork/'..fileName..'.log', logText..'\n')
  end

  ServerLog(text..'\n') hook.Run('ClockworkLog', text, unixTime)
end

-- the function below is from Gristwork I believe.
-- so kudos to Alex Grist for making it

--- Adds every item of a Steam Workshop collection to the client downloads.
--
-- Fetches the collection page asynchronously and calls `resource.AddWorkshop` for each item on it.
-- @param id [String The collection's Workshop ID]
function cw.core:AddWorkshopCollection(id)
  http.Fetch('http://steamcommunity.com/sharedfiles/filedetails/?id='..id, function(page)
    for k in string.gmatch(page, [[<div id="sharedfile_(.-)" class="collectionItem">]]) do
      resource.AddWorkshop(k)
    end
  end)
end

do
  if cw.WorkshopMaps[game.GetMap()] then
    resource.AddWorkshop(cw.WorkshopMaps[game.GetMap()])
  else
    resource.AddSingleFile('maps/'..game.GetMap()..'.bsp')
  end

  local workshopCollection = cvars.String('host_workshop_collection', '')

  if workshopCollection != '' then
    cw.core:AddWorkshopCollection(workshopCollection)
  else
    cw.core:AddWorkshopCollection('1117399683') -- Blowback content
  end
end

--- Runs the player-specific part of the `EntityTakeDamage` hook.
--
-- For players and their ragdolls it runs `PrePlayerTakeDamage`, cancels damage that `PlayerShouldTakeDamage`
-- rejects or that hits a player in god mode, redirects damage from a ragdolled player to the ragdoll and
-- turns crush damage on a ragdoll into fall damage (at most once a second) using `GetFallDamage`.
-- @param entity [Entity The damaged entity]
-- @param damageInfo [CTakeDamageInfo The damage; modified in place]
-- @return [Boolean `true` when the damage was cancelled or redirected and the caller should stop]
-- @warning [Internal] Called by the kernel's `EntityTakeDamage` hook.
function cw.core:DoEntityTakeDamageHook(entity, damageInfo)
  if !IsValid(entity) then
    return
  end

  local inflictor = damageInfo:GetInflictor()
  local attacker = damageInfo:GetAttacker()
  local amount = damageInfo:GetDamage()

  if amount != damageInfo:GetDamage() then
    amount = damageInfo:GetDamage()
  end

  local player = cw.entity:GetPlayer(entity)

  if player then
    local ragdoll = player:GetRagdollEntity()

    hook.Run('PrePlayerTakeDamage', player, attacker, inflictor, damageInfo)

    if !hook.Run('PlayerShouldTakeDamage', player, attacker, inflictor, damageInfo)
    or player:IsInGodMode() then
      damageInfo:SetDamage(0)

      return true
    end

    if ragdoll and entity != ragdoll then
      hook.Run('EntityTakeDamage', ragdoll, damageInfo)
      damageInfo:SetDamage(0)

      return true
    end

    if entity == ragdoll then
      local physicsObject = entity:GetPhysicsObject()

      if IsValid(physicsObject) then
        local velocity = physicsObject:GetVelocity():Length()
        local curTime = CurTime()

        if damageInfo:IsDamageType(DMG_CRUSH) then
          if entity.cwNextFallDamage
          and curTime < entity.cwNextFallDamage then
            damageInfo:SetDamage(0)
            return true
          end

          amount = hook.Run('GetFallDamage', player, velocity)
          entity.cwNextFallDamage = curTime + 1
          damageInfo:SetDamage(amount)
        end
      end
    end
  end
end

--[[ Disable game saving and admin cleanup. --]]
concommand.Add('gm_save', function(player, command, arguments)
  ErrorNoHalt(
    '[Catwork] '..player:Name()..' ('..player:SteamID()..
      ') has attempted to use gm_save command to potentially crash the server!\n'
  )
end)

concommand.Add('gmod_admin_cleanup', function(player, command, arguments)
  ErrorNoHalt(
    '[Catwork] '..player:Name()..' ('..player:SteamID()..
      ') has attempted to use gmod_admin_cleanup command to wipe all props from the server!\n'
  )
end)

concommand.Add('cat_add_bots', function(player, command, arguments)
  if !IsValid(player) then
    print('[Catwork] Spawning 63 bots for debug purposes...')

    timer.Create('BOTS', 0.3, 63, function()
      RunConsoleCommand('bot')
    end)
  end
end)

local entityMeta = FindMetaTable('Entity')
local playerMeta = FindMetaTable('Player')

playerMeta.ClockworkSetCrouchedWalkSpeed = playerMeta.ClockworkSetCrouchedWalkSpeed or playerMeta.SetCrouchedWalkSpeed
playerMeta.ClockworkLastHitGroup = playerMeta.ClockworkLastHitGroup or playerMeta.LastHitGroup
playerMeta.ClockworkSetJumpPower = playerMeta.ClockworkSetJumpPower or playerMeta.SetJumpPower
playerMeta.ClockworkSetWalkSpeed = playerMeta.ClockworkSetWalkSpeed or playerMeta.SetWalkSpeed
playerMeta.ClockworkStripWeapons = playerMeta.ClockworkStripWeapons or playerMeta.StripWeapons
playerMeta.ClockworkSetRunSpeed = playerMeta.ClockworkSetRunSpeed or playerMeta.SetRunSpeed
entityMeta.ClockworkSetMaterial = entityMeta.ClockworkSetMaterial or entityMeta.SetMaterial
playerMeta.ClockworkStripWeapon = playerMeta.ClockworkStripWeapon or playerMeta.StripWeapon
entityMeta.ClockworkFireBullets = entityMeta.ClockworkFireBullets or entityMeta.FireBullets
playerMeta.ClockworkGodDisable = playerMeta.ClockworkGodDisable or playerMeta.GodDisable
entityMeta.ClockworkExtinguish = entityMeta.ClockworkExtinguish or entityMeta.Extinguish
entityMeta.ClockworkWaterLevel = entityMeta.ClockworkWaterLevel or entityMeta.WaterLevel
playerMeta.ClockworkGodEnable = playerMeta.ClockworkGodEnable or playerMeta.GodEnable
entityMeta.ClockworkSetHealth = entityMeta.ClockworkSetHealth or entityMeta.SetHealth
playerMeta.ClockworkUniqueID = playerMeta.ClockworkUniqueID or playerMeta.UniqueID
entityMeta.ClockworkSetColor = entityMeta.ClockworkSetColor or entityMeta.SetColor
entityMeta.ClockworkIsOnFire = entityMeta.ClockworkIsOnFire or entityMeta.IsOnFire
entityMeta.ClockworkSetModel = entityMeta.ClockworkSetModel or entityMeta.SetModel
playerMeta.ClockworkSetArmor = playerMeta.ClockworkSetArmor or playerMeta.SetArmor
entityMeta.ClockworkSetSkin = entityMeta.ClockworkSetSkin or entityMeta.SetSkin
entityMeta.ClockworkAlive = entityMeta.ClockworkAlive or playerMeta.Alive
playerMeta.ClockworkGive = playerMeta.ClockworkGive or playerMeta.Give
playerMeta.ClockworkKick = playerMeta.ClockworkKick or playerMeta.Kick
playerMeta.ClockworkSteamID64 = playerMeta.ClockworkSteamID64 or playerMeta.SteamID64
playerMeta.ClockworkPlayStepSound = playerMeta.ClockworkPlayStepSound or playerMeta.PlayStepSound

playerMeta.SteamName = playerMeta.SteamName or playerMeta.Name

--- Returns the player's 64-bit Steam ID, or an empty string where the engine returns `nil`.
--
-- Wraps the engine function, kept as `Player:ClockworkSteamID64`, so callers can concatenate the result
-- safely; prints a message when the fallback is used.
-- @return [String The SteamID64, or `''` if it is not available]
function playerMeta:SteamID64()
  local value = self:ClockworkSteamID64()

  if value == nil then
    print('[Catwork] Temporary fix for SteamID64 has been used.')
    return ''
  else
    return value
  end
end

--- Overrides the name `Player:Name` returns for this player, on the server and on clients.
--
-- Stored in the `NameOverride` net variable.
-- @param name [String The name to show; `nil` or `''` removes the override]
function playerMeta:OverrideName(name)
  if name and name != '' then
    self:SetNetVar('NameOverride', name)
  else
    self:SetNetVar('NameOverride', nil)
  end
end

--- Returns the player's display name.
--
-- This is the name set with `Player:OverrideName` if any, otherwise the character's name, otherwise the
-- Steam name (`Player:SteamName` is the engine's original `Name`).
-- @param bRealName=nil [Boolean Whether to ignore the name override]
-- @return [String The player's name]
-- @alias [Player.GetName]
-- @alias [Player.Nick]
function playerMeta:Name(bRealName)
  return (!bRealName and self:GetNetVar('NameOverride', nil)) or self:QueryCharacter('Name', self:SteamName())
end

--- Plays a footstep sound, at most once every quarter second.
--
-- Wraps the engine function, kept as `Player:ClockworkPlayStepSound`.
-- @param volume [Number Volume of the sound, from 0 to 1]
function playerMeta:PlayStepSound(volume)
  local curTime = CurTime()

  self.nextFootstep = self.nextFootstep or curTime

  if self.nextFootstep <= curTime then
    self:ClockworkPlayStepSound(volume)

    self.nextFootstep = curTime + 0.25 -- min delay
  end
end

--- Fires bullets from the entity after letting hooks adjust them.
--
-- Runs `PlayerAdjustBulletInfo` for players and `EntityFireBullets` for every entity, both with the bullet
-- table, then calls the engine function, kept as `Entity:ClockworkFireBullets`.
-- @param bulletInfo [Map Bullet structure, as for the engine's `Entity:FireBullets`]
-- @param ... [Any Extra arguments passed to the engine function]
function entityMeta:FireBullets(bulletInfo, ...)
  if self:IsPlayer() then
    hook.Run('PlayerAdjustBulletInfo', self, bulletInfo)
  end

  hook.Run('EntityFireBullets', self, bulletInfo)
  return self:ClockworkFireBullets(bulletInfo, ...)
end

--- Returns whether the player is alive, treating a player who is faking death as dead.
-- @return [Boolean Whether the player is alive]
-- @see Player:SetFakingDeath
function playerMeta:Alive()
  if !self.fakingDeath then
    return self:ClockworkAlive()
  else
    return false
  end
end

--- Sets whether the player is faking death, which makes `Player:Alive` return `false`.
-- @param fakingDeath [Boolean Whether the player is faking death]
-- @param killSilent=nil [Boolean When ending the fake death, kill the player silently]
function playerMeta:SetFakingDeath(fakingDeath, killSilent)
  self.fakingDeath = fakingDeath

  if !fakingDeath and killSilent then
    self:KillSilent()
  end
end

--- Saves the player's current character to the database.
-- @see cw.player:SaveCharacter
function playerMeta:SaveCharacter()
  cw.player:SaveCharacter(self)
end

--- Gives the player the weapon of a weapon item.
-- @param itemTable [Item The weapon item instance]
-- @see cw.player:GiveItemWeapon
function playerMeta:GiveItemWeapon(itemTable)
  cw.player:GiveItemWeapon(self, itemTable)
end

--- Gives the player a weapon, optionally tied to an item.
--
-- Does nothing if the `PlayerCanBeGivenWeapon` hook returns `false`. While the player is ragdolled the weapon
-- is added to the ragdoll's weapons and handed out when they get up, unless `bForceReturn` is set. With an
-- item, the weapon gets its `ItemID` networked string, the item definition is sent to the player and
-- the item's `OnWeaponGiven` callback runs. Runs `PlayerGivenWeapon` afterwards. Unlike the engine function
-- (kept as `Player:ClockworkGive`), nothing is returned.
-- @param class [String Weapon class name]
-- @param itemTable=nil [Item Item instance the weapon belongs to]
-- @param bForceReturn=nil [Boolean Give the weapon now even if the player is ragdolled]
function playerMeta:Give(class, itemTable, bForceReturn)
  local iTeamIndex = self:Team()

  if !hook.Run('PlayerCanBeGivenWeapon', self, class, itemTable) then
    return
  end

  if self:IsRagdolled() and !bForceReturn then
    local ragdollWeapons = self:GetRagdollWeapons()
    local spawnWeapon = cw.player:GetSpawnWeapon(self, class)
    local bCanHolster = (itemTable and hook.Run('PlayerCanHolsterWeapon', self, itemTable, true, true))

    if !spawnWeapon then iTeamIndex = nil end

    for k, v in pairs(ragdollWeapons) do
      if v.weaponData['class'] == class
      and v.weaponData['itemTable'] == itemTable then
        v.canHolster = bCanHolster
        v.teamIndex = iTeamIndex
        return
      end
    end

    ragdollWeapons[#ragdollWeapons + 1] = {
      weaponData = {
        class = class,
        itemTable = itemTable
      },
      canHolster = bCanHolster,
      teamIndex = iTeamIndex
    }
  elseif !self:HasWeapon(class) then
    self.cwForceGive = true
      self:ClockworkGive(class)
    self.cwForceGive = nil

    local weapon = self:GetWeapon(class)

    if IsValid(weapon) and itemTable then
      netstream.Start(self, 'WeaponItemData', {
        definition = item.GetDefinition(itemTable, true),
        weapon = weapon:EntIndex()
      })

      weapon:SetNWString(
        'ItemID', tostring(itemTable.itemID)
      )
      weapon.cwItemTable = itemTable

      if itemTable.OnWeaponGiven then
        itemTable:OnWeaponGiven(self, weapon)
      end
    end
  end

  hook.Run('PlayerGivenWeapon', self, class, itemTable)
end

--- Returns a value from the player's persistent data, which belongs to the player rather than a character.
-- @param key [String Name of the value]
-- @param default=nil [Any Value to return when the key is not set]
-- @return [Any The stored value, or `default`]
-- @see Player:SetData
function playerMeta:GetData(key, default)
  if self.cwData and self.cwData[key] != nil then
    return self.cwData[key]
  else
    return default
  end
end

--- Returns the playback rate of the player's animations.
-- @return [Number The playback rate, `1` by default]
function playerMeta:GetPlaybackRate()
  return self.cwPlaybackRate or 1
end

--- Sets the entity's skin; for players also updates their ragdoll's saved skin.
--
-- Runs the `PlayerSkinChanged` hook for players.
-- @param skin [Number Skin index]
function entityMeta:SetSkin(skin)
  self:ClockworkSetSkin(skin)

  if self:IsPlayer() then
    hook.Run('PlayerSkinChanged', self, skin)

    if self:IsRagdolled() then
      self:GetRagdollTable().skin = skin
    end
  end
end

--- Sets the entity's model; for players also updates their ragdoll's saved model.
--
-- Runs the `PlayerModelChanged` hook for players.
-- @param model [String Model path]
function entityMeta:SetModel(model)
  self:ClockworkSetModel(model)

  if self:IsPlayer() then
    hook.Run('PlayerModelChanged', self, model)

    if self:IsRagdolled() then
      self:GetRagdollTable().model = model
    end
  end
end

--- Returns the character key of the entity's owner.
-- @return [Number The owner's character key, or `nil` if the entity has no owner]
function entityMeta:GetOwnerKey()
  return self.cwOwnerKey
end

--- Sets the character key of the entity's owner.
-- @param key [Number The owner's character key, as returned by `Player:GetCharacterKey`; `nil` clears it]
function entityMeta:SetOwnerKey(key)
  self.cwOwnerKey = key
end

--- Returns whether the entity was created by the map.
-- @return [Boolean Whether the entity is a map entity]
-- @see cw.entity:IsMapEntity
function entityMeta:IsMapEntity()
  return cw.entity:IsMapEntity(self)
end

--- Returns the position the entity was at when it was recorded as spawned.
-- @return [Vector The start position, or `nil` if none was stored]
-- @see cw.entity:GetStartPosition
function entityMeta:GetStartPosition()
  return cw.entity:GetStartPosition(self)
end

--- Plays a body hit sound from the entity, followed a few frames later by another sound.
-- @param sound [String Sound to play after the hit sound]
function entityMeta:EmitHitSound(sound)
  self:EmitSound('weapons/crossbow/hitbod2.wav',
    math.random(100, 150), math.random(150, 170)
  )

  timer.Simple(FrameTime() * 8, function()
    if IsValid(self) then
      self:EmitSound(sound)
    end
  end)
end

--- Sets the entity's material, also applying it to a ragdolled player's ragdoll.
-- @param material [String Material path; `''` restores the default]
function entityMeta:SetMaterial(material)
  if self:IsPlayer() and self:IsRagdolled() then
    self:GetRagdollEntity():SetMaterial(material)
  end

  self:ClockworkSetMaterial(material)
end

--- Sets the entity's color, also applying it to a ragdolled player's ragdoll.
-- @param color [Color The new color]
function entityMeta:SetColor(color)
  if self:IsPlayer() and self:IsRagdolled() then
    self:GetRagdollEntity():SetColor(color)
  end

  self:ClockworkSetColor(color)
end

--- Returns the table of movement and inventory values the kernel refreshes for the player every think.
-- @return [Map The info table, with keys such as `walkSpeed`, `jumpPower` and `inventoryWeight`]
function playerMeta:GetInfoTable()
  return self.cwInfoTable
end

--- Sets the player's armor and runs the `PlayerArmorSet` hook with the new and old values.
-- @param armor [Number The new armor; does nothing if `nil`]
function playerMeta:SetArmor(armor)
  if !armor then
    return
  end

  local oldArmor = self:Armor()
    self:ClockworkSetArmor(armor)
  hook.Run('PlayerArmorSet', self, armor, oldArmor)
end

--- Sets the player's health and runs the `PlayerHealthSet` hook with the new and old values.
-- @param health [Number The new health; does nothing if `nil`]
function playerMeta:SetHealth(health)
  if !health then
    return
  end

  local oldHealth = self:Health()
    self:ClockworkSetHealth(health)
  hook.Run('PlayerHealthSet', self, health, oldHealth)
end

--- Returns whether the player is in noclip.
-- @return [Boolean Whether the player is noclipping]
-- @see cw.player:IsNoClipping
function playerMeta:IsNoClipping()
  return cw.player:IsNoClipping(self)
end

--- Returns whether the player is sprinting.
--
-- True while the player is alive, not ragdolled, crouching or in a vehicle, holds the sprint key and moves
-- at least at walking speed.
-- @return [Boolean Whether the player is running]
function playerMeta:IsRunning()
  if self:Alive() and !self:IsRagdolled() and !self:InVehicle()
  and !self:Crouching() and self:KeyDown(IN_SPEED) then
    if self:GetVelocity():Length() >= self:GetWalkSpeed()
    or bNoWalkSpeed then
      return true
    end
  end

  return false
end

--- Returns whether the player is in the middle of a jump.
-- @return [Boolean Whether the player is jumping and alive, not ragdolled, crouching or in a vehicle]
function playerMeta:IsJumping()
  if self:Alive() and !self:IsRagdolled() and !self:InVehicle()
  and !self:Crouching() and self.m_bJumping then
    return true
  end

  return false
end

--- Removes a weapon from the player, or from their ragdoll's weapons while they are ragdolled.
-- @param weaponClass [String Weapon class name]
function playerMeta:StripWeapon(weaponClass)
  if self:IsRagdolled() then
    local ragdollWeapons = self:GetRagdollWeapons()

    for k, v in pairs(ragdollWeapons) do
      if v.weaponData['class'] == weaponClass then
        weapons[k] = nil
      end
    end
  else
    self:ClockworkStripWeapon(weaponClass)
  end
end

--- Returns the run speed the player is meant to have.
-- @return [Number The target run speed, or the current run speed if none is set]
function playerMeta:GetTargetRunSpeed()
  return self.cwTargetRunSpeed or self:GetRunSpeed()
end

--- Sends the player's accumulated attribute progress to their client every 30 seconds.
--
-- Clears the accumulated progress after sending it.
-- @param curTime [Number The current `CurTime`]
-- @warning [Internal] Called by the kernel once a second for each player.
function playerMeta:HandleAttributeProgress(curTime)
  if self.cwAttrProgressTime and curTime >= self.cwAttrProgressTime then
    self.cwAttrProgressTime = curTime + 30

    for k, v in pairs(self.cwAttrProgress) do
      local attributeTable = cw.attribute:FindByID(k)

      if attributeTable then
        netstream.Start(self, 'AttributeProgress', {
          index = attributeTable.index, amount = v
        })
      end
    end

    if self.cwAttrProgress then
      self.cwAttrProgress = {}
    end
  end
end

--- Updates the player's timed attribute boosts, fading their amount out and removing expired ones.
-- @param curTime [Number The current `CurTime`]
-- @warning [Internal] Called by the kernel once a second for each player.
function playerMeta:HandleAttributeBoosts(curTime)
  for k, v in pairs(self.cwAttrBoosts) do
    for k2, v2 in pairs(v) do
      if v2.duration and v2.endTime then
        if curTime > v2.endTime then
          self:BoostAttribute(k2, k, false)
        else
          local timeLeft = v2.endTime - curTime

          if timeLeft >= 0 then
            if v2.default < 0 then
              v2.amount = math.min((v2.default / v2.duration) * timeLeft, 0)
            else
              v2.amount = math.max((v2.default / v2.duration) * timeLeft, 0)
            end
          end
        end
      end
    end
  end
end

--- Removes all of the player's weapons, or their ragdoll's weapons while they are ragdolled.
-- @param ragdollForce=nil [Boolean Strip the player's real weapons even while ragdolled]
function playerMeta:StripWeapons(ragdollForce)
  if self:IsRagdolled() and !ragdollForce then
    self:GetRagdollTable().weapons = {}
  else
    self:ClockworkStripWeapons()
  end
end

--- Enables god mode for the player and remembers it for `Player:IsInGodMode`.
function playerMeta:GodEnable()
  self.godMode = true self:ClockworkGodEnable()
end

--- Disables god mode for the player.
function playerMeta:GodDisable()
  self.godMode = nil self:ClockworkGodDisable()
end

--- Returns whether god mode was enabled with `Player:GodEnable`.
-- @return [Boolean `true` in god mode, otherwise `nil`]
function playerMeta:IsInGodMode()
  return self.godMode
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

  --- Detects whether the player's active weapon fired since the last check by comparing its clips.
  --
  -- Runs the `PlayerFireWeapon` hook with the weapon, `CLIP_ONE` or `CLIP_TWO` and the ammo type when a clip
  -- went down. Firing a listed melee weapon is meant to drain stamina.
  -- @warning [Internal] Called by the kernel from `PlayerThink`.
  function playerMeta:UpdateWeaponFired()
    local activeWeapon = self:GetActiveWeapon()

    if IsValid(activeWeapon) then
      local weaponClass = activeWeapon:GetClass()

      if self.cwClipOneInfo.weapon == activeWeapon then
        local clipOne = activeWeapon:Clip1()

        if clipOne < self.cwClipOneInfo.ammo then
          self.cwClipOneInfo.ammo = clipOne
          hook.Run('PlayerFireWeapon', self, activeWeapon, CLIP_ONE, activeWeapon:GetPrimaryAmmoType())
        end
      else
        self.cwClipOneInfo.weapon = activeWeapon
        self.cwClipOneInfo.ammo = activeWeapon:Clip1()
      end

      if self.cwClipTwoInfo.weapon == activeWeapon then
        local clipTwo = activeWeapon:Clip2()

        if clipTwo < self.cwClipTwoInfo.ammo then
          self.cwClipTwoInfo.ammo = clipTwo
          hook.Run('PlayerFireWeapon', self, activeWeapon, CLIP_TWO, activeWeapon:GetSecondaryAmmoType())
        end
      else
        self.cwClipTwoInfo.weapon = activeWeapon
        self.cwClipTwoInfo.ammo = activeWeapon:Clip2()
      end

      if meleeWeapons[weaponClass] and player.GetCharacterData and player.SetCharacterData then
        player:SetCharacterData(
          'Stamina',
          math.Clamp(player:GetCharacterData('Stamina', 0) - meleeWeapons[weaponClass]),
          0,
          100 - player:GetCharacterData('Fatigue', 0)
        )
      end
    end
  end
end

--- Returns how deep the player is in water, using their ragdoll while they are ragdolled.
-- @return [Number Water level from 0 (dry) to 3 (fully submerged)]
function playerMeta:WaterLevel()
  if self:IsRagdolled() then
    return self:GetRagdollEntity():WaterLevel()
  else
    return self:ClockworkWaterLevel()
  end
end

--- Returns whether the player, or their ragdoll while they are ragdolled, is on fire.
-- @return [Boolean Whether the player is burning]
function playerMeta:IsOnFire()
  if self:IsRagdolled() then
    return self:GetRagdollEntity():IsOnFire()
  else
    return self:ClockworkIsOnFire()
  end
end

--- Puts out the fire on the player, or on their ragdoll while they are ragdolled.
function playerMeta:Extinguish()
  if self:IsRagdolled() then
    return self:GetRagdollEntity():Extinguish()
  else
    return self:ClockworkExtinguish()
  end
end

--- Returns whether the player's active weapon is the hands (`cw_hands`).
-- @return [Boolean Whether the player is using their hands]
function playerMeta:IsUsingHands()
  return cw.player:GetWeaponClass(self) == 'cw_hands'
end

--- Returns whether the player's active weapon is the keys (`cw_keys`).
-- @return [Boolean Whether the player is using their keys]
function playerMeta:IsUsingKeys()
  return cw.player:GetWeaponClass(self) == 'cw_keys'
end

--- Returns the wages the player earns each wages interval.
-- @return [Number The wages, from the `Wages` net variable]
function playerMeta:GetWages()
  return cw.player:GetWages(self)
end

--- Returns the player's Steam community ID, computed from their Steam ID.
-- @return [Number The community ID, or the Steam ID string if it could not be parsed (e.g. for bots)]
function playerMeta:CommunityID()
  local x, y, z = string.match(self:SteamID(), 'STEAM_(%d+):(%d+):(%d+)')

  if x and y and z then
    return (z * 2) + STEAM_COMMUNITY_ID + y
  else
    return self:SteamID()
  end
end

--- Returns whether the player is ragdolled (knocked out or fallen over).
-- @param exception=nil [Number A `RAGDOLL_*` state that does not count as ragdolled]
-- @param entityless=nil [Boolean Check the ragdoll state even if the player has no ragdoll entity]
-- @return [Boolean Whether the player is ragdolled, or `nil` when there is no ragdoll entity]
-- @see cw.player:IsRagdolled
function playerMeta:IsRagdolled(exception, entityless)
  return cw.player:IsRagdolled(self, exception, entityless)
end

--- Returns the reason the player is being kicked, if `Player:Kick` was called for them.
-- @return [String The kick reason, or `nil` if the player is not being kicked]
function playerMeta:IsKicked()
  return self.isKicked
end

--- Returns whether the player's initial spawn has happened.
-- @return [Boolean `true` once `PlayerInitialSpawn` has run for the player, otherwise `nil`]
function playerMeta:HasSpawned()
  return self.cwHasSpawned
end

--- Kicks the player with a reason.
--
-- The kick happens a moment later; a player whose initial spawn has not happened yet is kicked once it has.
-- The engine function is kept as `Player:ClockworkKick`.
-- @param reason='You have been kicked.' [String Reason shown to the player]
function playerMeta:Kick(reason)
  if !self:IsKicked() then
    timer.Simple(FrameTime() * 0.5, function()
      local isKicked = self:IsKicked()

      if IsValid(self) and isKicked then
        if self:HasSpawned() then
          -- Not `kickid` through the console: the reason would be parsed as console commands.
          self:ClockworkKick(isKicked)
        else
          self.isKicked = nil
          self:Kick(isKicked)
        end
      end
    end)
  end

  if !reason then
    self.isKicked = 'You have been kicked.'
  else
    self.isKicked = reason
  end
end

--- Bans the player's Steam ID, which also kicks them.
-- @param duration [Number Ban length in minutes; `0` bans permanently]
-- @param reason=nil [String Ban reason]
-- @see cw.bans:Add
function playerMeta:Ban(duration, reason)
  cw.bans:Add(self:SteamID(), duration * 60, reason)
end

--- Returns the cash of the player's character.
-- @return [Number The cash, or `0` when the `cash_enabled` config is off]
function playerMeta:GetCash()
  if config.GetVal('cash_enabled') then
    return self:QueryCharacter('Cash')
  else
    return 0
  end
end

--- Returns the flags of the player's character.
-- @return [String The character's flags, one letter each]
-- @see Player:GetPlayerFlags
function playerMeta:GetFlags() return self:QueryCharacter('Flags') end

--- Returns the faction of the player's character.
-- @return [String The faction name, or `nil` without a character]
function playerMeta:GetFaction() return self:QueryCharacter('Faction') end

--- Returns the gender of the player's character.
-- @return [String `GENDER_MALE` or `GENDER_FEMALE`, or `nil` without a character]
function playerMeta:GetGender() return self:QueryCharacter('Gender') end

--- Returns the inventory of the player's character.
-- @return [Inventory The inventory, or `nil` without a character]
function playerMeta:GetInventory() return self:QueryCharacter('Inventory') end

--- Returns the attributes of the player's character.
-- @return [Map Attribute unique IDs mapped to `{ amount = Number, progress = Number }`, or `nil` without a
-- character]
function playerMeta:GetAttributes() return self:QueryCharacter('Attributes') end

--- Returns the ammo saved with the player's character.
-- @return [Map Ammo types mapped to amounts, or `nil` without a character]
function playerMeta:GetSavedAmmo() return self:QueryCharacter('Ammo') end

--- Returns the model chosen for the player's character.
-- @return [String The model path, or `nil` without a character]
function playerMeta:GetDefaultModel() return self:QueryCharacter('Model') end

--- Returns the ID of the player's character among the player's own characters.
-- @return [Number The character ID, or `nil` without a character]
-- @see Player:GetCharacterKey
function playerMeta:GetCharacterID() return self:QueryCharacter('CharacterID') end

--- Returns when the player's character was created.
-- @return [Number The creation time, or `nil` without a character]
function playerMeta:GetTimeCreated() return self:QueryCharacter('TimeCreated') end

--- Returns the key of the player's character, which is unique among all characters.
--
-- Used to identify a character across players, e.g. for recognition and entity ownership.
-- @return [Number The character key, or `nil` without a character]
function playerMeta:GetCharacterKey() return self:QueryCharacter('Key') end

--- Returns the characters the player's character recognises.
-- @return [Map Character keys mapped to `RECOGNISE_*` values, or `nil` without a character]
function playerMeta:GetRecognisedNames()
  return self:QueryCharacter('RecognisedNames')
end

--- Returns the player's current character.
-- @return [Character The character, or `nil` if the player has not loaded one]
function playerMeta:GetCharacter() return cw.player:GetCharacter(self) end

--- Returns the storage the player has open.
-- @return [Map The storage table, or `nil` if no storage is open]
-- @see cw.storage:GetTable
function playerMeta:GetStorageTable() return cw.storage:GetTable(self) end

--- Returns the player's ragdoll table, which holds the ragdoll entity and what to restore when they get up.
-- @return [Map The ragdoll table, with keys such as `entity`, `weapons`, `model` and `skin`]
function playerMeta:GetRagdollTable() return cw.player:GetRagdollTable(self) end

--- Returns the player's ragdoll state.
-- @return [Number One of `RAGDOLL_KNOCKEDOUT`, `RAGDOLL_FALLENOVER`, `RAGDOLL_RESET` or `RAGDOLL_NONE`]
function playerMeta:GetRagdollState() return cw.player:GetRagdollState(self) end

--- Returns the entity whose storage the player has open.
-- @return [Entity The storage entity, or `nil` if no storage is open]
-- @see cw.storage:GetEntity
function playerMeta:GetStorageEntity() return cw.storage:GetEntity(self) end

--- Returns the player's ragdoll entity.
-- @return [Entity The ragdoll, or `nil` if the player has no valid ragdoll]
function playerMeta:GetRagdollEntity() return cw.player:GetRagdollEntity(self) end

--- Returns the weapons the player will get back when their ragdoll gets up.
-- @return [List<Map> Entries with `weaponData` (`class`, `itemTable`), `canHolster` and `teamIndex`]
function playerMeta:GetRagdollWeapons()
  return self:GetRagdollTable().weapons or {}
end

--- Returns whether the player's ragdoll holds a weapon of a class.
-- @param weaponClass [String Weapon class name]
-- @return [Boolean `true` if the ragdoll has the weapon, otherwise `nil`]
function playerMeta:RagdollHasWeapon(weaponClass)
  local ragdollWeapons = self:GetRagdollWeapons()

  if ragdollWeapons then
    for k, v in pairs(ragdollWeapons) do
      if v.weaponData['class'] == weaponClass then
        return true
      end
    end
  end
end

--- Sets the player's maximum armor, networked as `MaxAP`.
-- @param armor [Number The maximum armor]
function playerMeta:SetMaxArmor(armor)
  self:SetNetVar('MaxAP', armor)
end

--- Returns the player's maximum armor.
-- @param armor=nil [Any Unused]
-- @return [Number The maximum armor; `100` when it is unset or not positive]
function playerMeta:GetMaxArmor(armor)
  local maxArmor = self:GetNetVar('MaxAP') or 100

  if maxArmor > 0 then
    return maxArmor
  else
    return 100
  end
end

--- Sets the player's maximum health, networked as `MaxHP`.
-- @param health [Number The maximum health]
function playerMeta:SetMaxHealth(health)
  self:SetNetVar('MaxHP', health)
end

--- Returns the player's maximum health.
-- @param health=nil [Any Unused]
-- @return [Number The maximum health; `100` when it is unset or not positive]
function playerMeta:GetMaxHealth(health)
  local maxHealth = self:GetNetVar('MaxHP') or 100

  if maxHealth > 0 then
    return maxHealth
  else
    return 100
  end
end

--- Returns whether the player is still being shown the starter hints after joining.
-- @return [Boolean Whether the starter hints are showing]
function playerMeta:IsViewingStarterHints()
  return self.cwViewStartHints
end

--- Returns the hit group the player was last hit in, including hits on their ragdoll.
-- @return [Number A `HITGROUP_*` value]
function playerMeta:LastHitGroup()
  return self.cwLastHitGroup or self:ClockworkLastHitGroup()
end

--- Returns whether a player is holding the entity, as answered by the `GetEntityBeingHeld` hook.
-- @return [Boolean Whether the entity is being held, or `nil` for an invalid entity]
function entityMeta:IsBeingHeld()
  if IsValid(self) then
    return hook.Run('GetEntityBeingHeld', self)
  end
end

--- Runs a console command on the player's client.
--
-- The client refuses to run `cwlua` this way.
-- @param ... [String The command and its arguments, as for `RunConsoleCommand`]
function playerMeta:RunCommand(...)
  netstream.Start(self, 'RunCommand', { ... })
end

--- Runs a Catwork command as the player.
-- @param command [String Name of the command]
-- @param ... [String The command's arguments]
-- @see cw.player:RunClockworkCommand
function playerMeta:RunClockworkCmd(command, ...)
  cw.player:RunClockworkCommand(self, command, ...)
end

--- Returns the name of the player's wages, as shown to players (e.g. "Supplies").
-- @return [String The wages name]
function playerMeta:GetWagesName()
  return cw.player:GetWagesName(self)
end

--- Stops the player's forced animation after a delay, replacing any pending stop timer.
-- @param delay [Number Seconds until the animation stops]
function playerMeta:CreateAnimationStopDelay(delay)
  timer.Create('ForcedAnim'..self:SteamID64(), delay, 1, function()
    if IsValid(self) then
      local forcedAnimation = self:GetForcedAnimation()

      if forcedAnimation then
        self:SetForcedAnimation(false)
      end
    end
  end)
end

--- Forces the player to play an animation, or stops the current forced animation.
--
-- The sequence is networked in the `ForceAnim` net variable. A permanent animation started with a `delay`
-- of `0` cannot be replaced until it is stopped. The previous animation's `OnFinish` runs when it is
-- replaced or stopped.
--
-- ```
-- player:SetForcedAnimation('pickup', 1.2, nil, function(player)
--   player:EmitSound('items/ammo_pickup.wav')
-- end)
-- ```
--
-- @param animation [String Sequence name or activity number; `false` stops the forced animation]
-- @param delay=nil [Number Seconds to play it for; `nil` or `0` plays it until stopped]
-- @param OnAnimate=nil [Function Called as `OnAnimate(player)` when the animation first plays]
-- @param OnFinish=nil [Function Called as `OnFinish(player)` when the animation ends or is replaced]
-- @return [Boolean `true` if the animation started, `false` if it was stopped, `nil` if it was not played]
function playerMeta:SetForcedAnimation(animation, delay, OnAnimate, OnFinish)
  local forcedAnimation = self:GetForcedAnimation()
  local sequence = nil

  if !animation then
    self:SetNetVar('ForceAnim', 0)
    self.cwForcedAnimation = nil

    if forcedAnimation and forcedAnimation.OnFinish then
      forcedAnimation.OnFinish(self)
    end

    return false
  end

  local bIsPermanent = (!delay or delay == 0)
  local bShouldPlay = (!forcedAnimation or forcedAnimation.delay != 0)

  if bShouldPlay then
    if type(animation) == 'string' then
      sequence = self:LookupSequence(animation)
    else
      sequence = self:SelectWeightedSequence(animation)
    end

    self.cwForcedAnimation = {
      animation = animation,
      OnAnimate = OnAnimate,
      OnFinish = OnFinish,
      delay = delay
    }

    if bIsPermanent then
      timer.Remove(
        'ForcedAnim'..self:SteamID64()
      )
    else
      self:CreateAnimationStopDelay(delay)
    end

    self:SetNetVar('ForceAnim', sequence)

    if forcedAnimation and forcedAnimation.OnFinish then
      forcedAnimation.OnFinish(self)
    end

    return true
  end
end

--- Sets whether the player has received the config.
-- @param initialized [Boolean Whether the config was sent]
function playerMeta:SetConfigInitialized(initialized)
  self.cwConfigInitialized = initialized
end

--- Returns whether the player has received the config.
-- @return [Boolean Whether the config was sent to the player]
function playerMeta:HasConfigInitialized()
  return self.cwConfigInitialized
end

--- Returns the player's current forced animation.
-- @return [Map `animation`, `delay`, `OnAnimate` and `OnFinish`, or `nil` if none is playing]
-- @see Player:SetForcedAnimation
function playerMeta:GetForcedAnimation()
  return self.cwForcedAnimation
end

--- Returns the item entity the player is interacting with.
-- @return [Entity The item entity, or `nil` if it is not set or no longer valid]
function playerMeta:GetItemEntity()
  if IsValid(self.itemEntity) then
    return self.itemEntity
  end
end

--- Sets the item entity the player is interacting with.
-- @param entity [Entity The item entity; `nil` clears it]
function playerMeta:SetItemEntity(entity)
  self.itemEntity = entity
end

--- Plays a pickup animation towards an entity: a low pickup when it is nearer the feet, a reach otherwise.
-- @param entity [Entity The entity being picked up]
function playerMeta:FakePickup(entity)
  local entityPosition = entity:GetPos()

  if entity:IsPlayer() then
    entityPosition = entity:GetShootPos()
  end

  local shootPosition = self:GetShootPos()
  local feetDistance = self:GetPos():Distance(entityPosition)
  local armsDistance = shootPosition:Distance(entityPosition)

  if feetDistance < armsDistance then
    self:SetForcedAnimation('pickup', 1.2)
  else
    self:SetForcedAnimation('gunrack', 1.2)
  end
end

--- Sets the player's user group, saves it and runs the `OnPlayerUserGroupSet` hook.
--
-- Does nothing if the player is already in the group. Also sets the engine user group.
-- @param userGroup [String The user group, e.g. `'superadmin'`, `'admin'`, `'operator'` or `'user'`]
function playerMeta:SetClockworkUserGroup(userGroup)
  if self:GetClockworkUserGroup() != userGroup then
    self.cwUserGroup = userGroup
    self:SetUserGroup(userGroup)
    self:SaveCharacter()

    hook.Run('OnPlayerUserGroupSet', self, userGroup)
  end
end

--- Returns the player's Catwork user group.
-- @return [String The user group]
function playerMeta:GetClockworkUserGroup()
  return self.cwUserGroup
end

--- Returns all instances of an item in the player's inventory.
-- @param uniqueID [String Unique ID, index or name of the item, as accepted by `item.FindByID`]
-- @return [Map<Item> Item IDs mapped to instances, or `nil` if the player has none; an empty table for an
-- unknown item]
-- @see cw.inventory:GetItemsByID
function playerMeta:GetItemsByID(uniqueID)
  return cw.inventory:GetItemsByID(
    self:GetInventory(), uniqueID
  )
end

--- Returns the instances of an item in the player's inventory whose name matches, ignoring case.
-- @param uniqueID [String Unique ID, index or name of the item, as accepted by `item.FindByID`]
-- @param name [String Name to match against each instance's `name` and `PrintName`]
-- @return [List<Item> The matching instances, or `nil` if the player has none of the item]
-- @see cw.inventory:FindItemsByName
function playerMeta:FindItemsByName(uniqueID, name)
  return cw.inventory:FindItemsByName(
    self:GetInventory(), uniqueID, name
  )
end

--- Returns the maximum weight the player can carry.
--
-- This is the `InvWeight` net variable (8 by default) plus the `addInvSpace` of every carried item.
-- Runs the `PlayerAdjustMaxWeight` hook with the result, but cannot be changed by it.
-- @return [Number The maximum weight]
function playerMeta:GetMaxWeight()
  local itemsList = cw.inventory:GetAsItemsList(self:GetInventory())
  local weight = self:GetNetVar('InvWeight') or 8

  for k, v in pairs(itemsList) do
    local addInvWeight = v.addInvSpace

    if addInvWeight then
      weight = weight + addInvWeight
    end
  end

  hook.Run('PlayerAdjustMaxWeight', self, weight)

  return weight
end

--- Returns the maximum inventory space the player has.
--
-- This is the `InvSpace` net variable (10 by default) plus the `addInvVolume` of every carried item.
-- Runs the `PlayerAdjustMaxSpace` hook with the result, but cannot be changed by it.
-- @return [Number The maximum space]
function playerMeta:GetMaxSpace()
  local itemsList = cw.inventory:GetAsItemsList(self:GetInventory())
  local space = self:GetNetVar('InvSpace') or 10

  for k, v in pairs(itemsList) do
    local addInvSpace = v.addInvVolume

    if addInvSpace then
      space = space + addInvSpace
    end
  end

  hook.Run('PlayerAdjustMaxSpace', player, space)

  return space
end

--- Returns whether the player can carry additional weight.
-- @param weight [Number The weight to add]
-- @return [Boolean Whether the inventory stays within `Player:GetMaxWeight`]
function playerMeta:CanHoldWeight(weight)
  local inventoryWeight = cw.inventory:CalculateWeight(
    self:GetInventory()
  )

  if inventoryWeight + weight > self:GetMaxWeight() then
    return false
  else
    return true
  end
end

--- Returns whether the player has room for additional inventory space.
-- @param space [Number The space to add]
-- @return [Boolean Whether the inventory stays within `Player:GetMaxSpace`; always `true` when the space
-- system is disabled]
function playerMeta:CanHoldSpace(space)
  if !cw.inventory:UseSpaceSystem() then
    return true
  end

  local inventorySpace = cw.inventory:CalculateSpace(
    self:GetInventory()
  )

  if inventorySpace + space > self:GetMaxSpace() then
    return false
  else
    return true
  end
end

--- Returns the total weight of the player's inventory.
-- @return [Number The weight]
function playerMeta:GetInventoryWeight()
  return cw.inventory:CalculateWeight(self:GetInventory())
end

--- Returns the total space taken by the player's inventory.
-- @return [Number The space]
function playerMeta:GetInventorySpace()
  return cw.inventory:CalculateSpace(self:GetInventory())
end

--- Returns whether the player has at least one instance of an item.
-- @param uniqueID [String Unique ID of the item]
-- @return [Boolean Whether the player has the item]
-- @see cw.inventory:HasItemByID
function playerMeta:HasItemByID(uniqueID)
  return cw.inventory:HasItemByID(
    self:GetInventory(), uniqueID
  )
end

--- Returns how many instances of an item the player has.
-- @param uniqueID [String Unique ID, index or name of the item, as accepted by `item.FindByID`]
-- @return [Number The number of instances]
function playerMeta:GetItemCountByID(uniqueID)
  return cw.inventory:GetItemCountByID(
    self:GetInventory(), uniqueID
  )
end

--- Returns whether the player has at least an amount of instances of an item.
-- @param uniqueID [String Unique ID, index or name of the item, as accepted by `item.FindByID`]
-- @param amount [Number The amount needed]
-- @return [Boolean Whether the player has at least `amount` of the item]
function playerMeta:HasItemCountByID(uniqueID, amount)
  return cw.inventory:HasItemCountByID(
    self:GetInventory(), uniqueID, amount
  )
end

--- Finds an instance of an item in the player's inventory.
-- @param uniqueID [String Unique ID, index or name of the item, as accepted by `item.FindByID`]
-- @param itemID=nil [Number Item ID of the instance; any instance of the item when `nil`]
-- @return [Item The instance, or `nil` if the player does not have it]
-- @see cw.inventory:FindItemByID
function playerMeta:FindItemByID(uniqueID, itemID)
  return cw.inventory:FindItemByID(
    self:GetInventory(), uniqueID, itemID
  )
end

--- Returns whether the player has one of their weapons from an item instance.
-- @param itemTable [Item The item instance]
-- @return [Boolean Whether a weapon of the player belongs to the item]
function playerMeta:HasItemAsWeapon(itemTable)
  for k, v in pairs(self:GetWeapons()) do
    local weaponItemTable = item.GetByWeapon(v)

    if itemTable:IsTheSameAs(weaponItemTable) then
      return true
    end
  end

  return false
end

--- Returns the item instance behind one of the player's weapons.
-- @param uniqueID [String Unique ID of the item]
-- @param itemID [Number Item ID of the instance]
-- @return [Item The instance, or `nil` if no weapon of the player belongs to it]
function playerMeta:FindWeaponItemByID(uniqueID, itemID)
  for k, v in pairs(self:GetWeapons()) do
    local weaponItemTable = item.GetByWeapon(v)

    if weaponItemTable and weaponItemTable.uniqueID == uniqueID
    and weaponItemTable.itemID == itemID then
      return weaponItemTable
    end
  end
end

--- Returns whether a specific item instance is in the player's inventory.
-- @param itemTable [Item The item instance]
-- @return [Boolean Whether the instance is in the inventory]
function playerMeta:HasItemInstance(itemTable)
  return cw.inventory:HasItemInstance(
    self:GetInventory(), itemTable
  )
end

--- Finds an instance of an item in the player's inventory; the same as `Player:FindItemByID`.
-- @param uniqueID [String Unique ID, index or name of the item, as accepted by `item.FindByID`]
-- @param itemID=nil [Number Item ID of the instance; any instance of the item when `nil`]
-- @return [Item The instance, or `nil` if the player does not have it]
function playerMeta:GetItemInstance(uniqueID, itemID)
  return cw.inventory:FindItemByID(
    self:GetInventory(), uniqueID, itemID
  )
end

--- Takes an instance of an item from the player's inventory.
-- @param uniqueID [String Unique ID, index or name of the item, as accepted by `item.FindByID`]
-- @param itemID=nil [Number Item ID of the instance; any instance of the item when `nil`]
-- @return [Boolean Whether an item was taken]
-- @see Player:TakeItem
function playerMeta:TakeItemByID(uniqueID, itemID)
  local itemTable = self:GetItemInstance(uniqueID, itemID)

  if itemTable then
    return self:TakeItem(itemTable)
  else
    return false
  end
end

--- Returns the player's attribute boosts.
-- @return [Map Attribute unique IDs mapped to tables of boosts by identifier, each with `amount`,
-- `default`, `duration` and `endTime`]
function playerMeta:GetAttributeBoosts()
  return self.cwAttrBoosts
end

--- Tells the player's client to rebuild its inventory panel on the next frame.
function playerMeta:RebuildInventory()
  cw.inventory:Rebuild(self)
end

--- Gives the player an item.
--
-- Fails when the item does not fit within `Player:GetMaxWeight` and `Player:GetMaxSpace`, unless `bForce`
-- is set. On success, calls the item's `OnGiveToPlayer`, logs it, sends the item to the client, runs the
-- `PlayerItemGiven` hook and rebuilds the inventory.
--
-- ```
-- local success, fault = player:GiveItem('ration')
--
-- if !success then
--   player:Notify(fault)
-- end
-- ```
--
-- @param itemTable [Item The item instance, or an item unique ID to create a new instance of]
-- @param bForce=nil [Boolean Give the item even if the player cannot carry it]
-- @return [Item The given instance, or `false` on failure, String The failure reason, as a language phrase]
function playerMeta:GiveItem(itemTable, bForce)
  if isstring(itemTable) then
    itemTable = item.CreateInstance(itemTable)
  end

  if !itemTable or !itemTable:IsInstance() then
    debug.Trace()
    return false, L'#GiveInvalidItem'
  end

  local inventory = self:GetInventory()

  if (self:CanHoldWeight(itemTable.weight)
  and self:CanHoldSpace(itemTable.space)) or bForce then
    if itemTable.OnGiveToPlayer then
      itemTable:OnGiveToPlayer(self)
    end

    cw.core:PrintLog(LOGTYPE_GENERIC, self:Name()..' has gained a '..itemTable.name..' '..itemTable.itemID..'.')

    cw.inventory:AddInstance(inventory, itemTable)
      netstream.Start(self, 'InvGive', item.GetDefinition(itemTable, true))
    hook.Run('PlayerItemGiven', self, itemTable, bForce)

    cw.inventory:Rebuild(self)

    return itemTable
  else
    return false, L'NoSpace'
  end
end

--- Takes an item instance from the player.
--
-- Calls the item's `OnTakeFromPlayer`, logs it, runs the `PlayerItemTaken` hook, removes the instance,
-- tells the client and rebuilds the inventory.
-- @param itemTable [Item The item instance]
-- @return [Boolean `true`, or `false` when `itemTable` is not an item instance]
function playerMeta:TakeItem(itemTable)
  if !itemTable or !itemTable:IsInstance() then
    debug.Trace()
    return false
  end

  local inventory = self:GetInventory()

  if itemTable.OnTakeFromPlayer then
    itemTable:OnTakeFromPlayer(self)
  end

  cw.core:PrintLog(LOGTYPE_GENERIC, self:Name()..' has lost a '..itemTable.name..' '..itemTable.itemID..'.')

  hook.Run('PlayerItemTaken', self, itemTable)
    cw.inventory:RemoveInstance(inventory, itemTable)
  netstream.Start(self, 'InvTake', { itemTable.index, itemTable.itemID })

  cw.inventory:Rebuild(self)

  return true
end

--- Gives the player several items.
-- @param itemTables [List<Item> Item instances or unique IDs]
-- @see Player:GiveItem
function playerMeta:GiveItems(itemTables)
  for _, itemTable in pairs(itemTables) do
    self:GiveItem(itemTables)
  end
end

--- Takes several item instances from the player.
-- @param itemTables [List<Item> The item instances]
-- @see Player:TakeItem
function playerMeta:TakeItems(itemTables)
  for _, itemTable in pairs(itemTables) do
    self:TakeItem(itemTable)
  end
end

--- Changes one of the player's attributes by a number of points.
-- @param attribute [Any Attribute index, unique ID or name]
-- @param amount [Number Points to add; negative values remove points]
-- @return [Boolean Whether the attribute was updated, String The reason it was not]
-- @see cw.attributes:Update
function playerMeta:UpdateAttribute(attribute, amount)
  return cw.attributes:Update(self, attribute, amount)
end

--- Adds progress towards the next point of one of the player's attributes.
-- @param attribute [Any Attribute index, unique ID or name]
-- @param amount [Number Progress to add; negative values remove progress]
-- @param gradual=nil [Boolean Whether to scale positive progress down as the attribute grows]
-- @return [Boolean `false` when the progress was not applied, String The reason]
-- @see cw.attributes:Progress
function playerMeta:ProgressAttribute(attribute, amount, gradual)
  return cw.attributes:Progress(self, attribute, amount, gradual)
end

--- Adds or removes a boost to one of the player's attributes.
-- @param identifier [String Boost identifier; generated when `nil` and `amount` is given]
-- @param attribute [Any Attribute index, unique ID or name]
-- @param amount=nil [Number Points to add while the boost lasts, or `nil` to remove boosts]
-- @param duration=nil [Number How long the boost lasts in seconds, or `nil` for no time limit]
-- @return [String The boost identifier when a boost was added, or `true` when boosts were removed]
-- @see cw.attributes:Boost
function playerMeta:BoostAttribute(identifier, attribute, amount, duration)
  return cw.attributes:Boost(self, identifier, attribute, amount, duration)
end

--- Returns whether the player has a specific attribute boost.
-- @param identifier [String Boost identifier]
-- @param attribute [Any Attribute index, unique ID or name]
-- @param amount=nil [Number Amount the boost must have]
-- @param duration=nil [Number Duration the boost must have, in seconds]
-- @return [Boolean Whether the boost is active]
-- @see cw.attributes:IsBoostActive
function playerMeta:IsBoostActive(identifier, attribute, amount, duration)
  return cw.attributes:IsBoostActive(self, identifier, attribute, amount, duration)
end

--- Returns the player's characters.
-- @return [Map<Character> Character IDs mapped to characters]
function playerMeta:GetCharacters()
  return self.cwCharacterList
end

--- Sets the player's run speed and, unless `bClockwork` is set, remembers it as their base run speed.
--
-- The kernel passes `bClockwork` for temporary changes such as slowing injured players.
-- @param speed [Number The run speed]
-- @param bClockwork=nil [Boolean Whether this is a temporary change that keeps the base speed]
function playerMeta:SetRunSpeed(speed, bClockwork)
  if !bClockwork then self.cwRunSpeed = speed end
  self:ClockworkSetRunSpeed(speed)
end

--- Sets the player's walk speed and, unless `bClockwork` is set, remembers it as their base walk speed.
--
-- Also sets the slow walk (`+walk`) speed to the same value.
-- @param speed [Number The walk speed]
-- @param bClockwork=nil [Boolean Whether this is a temporary change that keeps the base speed]
function playerMeta:SetWalkSpeed(speed, bClockwork)
  if !bClockwork then self.cwWalkSpeed = speed end
  self:ClockworkSetWalkSpeed(speed)

  -- +walk has its own engine speed since 2020; keep it equal so holding it neither slows nor speeds up.
  self:SetSlowWalkSpeed(speed)
end

--- Sets the player's jump power and, unless `bClockwork` is set, remembers it as their base jump power.
-- @param power [Number The jump power]
-- @param bClockwork=nil [Boolean Whether this is a temporary change that keeps the base power]
function playerMeta:SetJumpPower(power, bClockwork)
  if !bClockwork then self.cwJumpPower = power end
  self:ClockworkSetJumpPower(power)
end

--- Sets the player's crouched walk speed and, unless `bClockwork` is set, remembers it as the base speed.
-- @param speed [Number The crouched walk speed multiplier]
-- @param bClockwork=nil [Boolean Whether this is a temporary change that keeps the base speed]
function playerMeta:SetCrouchedWalkSpeed(speed, bClockwork)
  if !bClockwork then self.cwCrouchedSpeed = speed end
  self:ClockworkSetCrouchedWalkSpeed(speed)
end

--- Returns whether the player has loaded a character and finished initializing.
-- @return [Boolean Whether the player has initialized]
function playerMeta:HasInitialized()
  return self.cwInitialized
end

--- Returns a field of the player's character.
--
-- The key is converted to camel case, so `'Name'` reads `character.name`.
-- @param key [String Name of the field]
-- @param default=nil [Any Value to return when the field is not set or there is no character]
-- @return [Any The field's value, or `default`]
-- @see cw.player:Query
function playerMeta:QueryCharacter(key, default)
  if self:GetCharacter() then
    return cw.player:Query(self, key, default)
  else
    return default
  end
end

--- Returns a net variable of the player.
-- @param key [String Name of the variable]
-- @param default=nil [Any Value to return when the variable is not set]
-- @return [Any The value, or `default`]
-- @deprecation [Use `Player:GetNetVar` instead.]
function playerMeta:GetSharedVar(key, default)
  return self:GetNetVar(key, default)
end

--- Sets a net variable of the player.
-- @param key [String Name of the variable]
-- @param value [Any The new value]
-- @param sharedTable=nil [Any Ignored]
-- @deprecation [Use `Player:SetNetVar` instead.]
function playerMeta:SetSharedVar(key, value, sharedTable)
  return self:SetNetVar(key, value)
end

--- Returns a value from the player's character data.
-- @param key [String Name of the value, as registered with `cw.player:AddCharacterData`]
-- @param default=nil [Any Value to return when the key is not set or there is no character]
-- @return [Any The stored value, or `default`]
-- @see Player:SetCharacterData
function playerMeta:GetCharacterData(key, default)
  if self:GetCharacter() then
    local data = self:QueryCharacter('Data')

    if data[key] != nil then
      return data[key]
    end
  end

  return default
end

--- Returns when the player first joined the server.
-- @return [Number Unix time of the first join; the current time if it is not known yet]
function playerMeta:TimeJoined()
  return self.cwTimeJoined or os.time()
end

--- Returns when the player last played on the server.
-- @return [Number Unix time of the last session; the current time if it is not known yet]
function playerMeta:LastPlayed()
  return self.cwLastPlayed or os.time()
end

--- Returns the clothes data of the player's character.
-- @return [Map `uniqueID` and `itemID` of the worn clothes; an empty table when no data is stored]
function playerMeta:GetClothesData()
  local clothesData = self:GetCharacterData('Clothes')

  if type(clothesData) != 'table' then
    clothesData = {}
  end

  return clothesData
end

--- Returns the accessory data of the player's character.
-- @return [Map Item IDs of worn accessories mapped to their unique IDs; an empty table when no data is stored]
function playerMeta:GetAccessoryData()
  local accessoryData = self:GetCharacterData('Accessories')

  if type(accessoryData) != 'table' then
    accessoryData = {}
  end

  return accessoryData
end

--- Takes off the player's clothes, optionally removing the clothes item from their inventory.
-- @param bRemoveItem=nil [Boolean Whether to also take the clothes item]
-- @return [Item The removed clothes item when `bRemoveItem` is set and the player wore one]
function playerMeta:RemoveClothes(bRemoveItem)
  self:SetClothesData(nil)

  if bRemoveItem then
    local clothesItem = self:GetClothesItem()

    if clothesItem then
      self:TakeItem(clothesItem)
      return clothesItem
    end
  end
end

--- Returns the clothes item the player is wearing.
-- @return [Item The clothes item, or `nil` if the player wears none or no longer has it]
function playerMeta:GetClothesItem()
  local clothesData = self:GetClothesData()

  if type(clothesData) == 'table' then
    if clothesData.itemID != nil and clothesData.uniqueID != nil then
      return self:FindItemByID(
        clothesData.uniqueID, clothesData.itemID
      )
    end
  end
end

--- Returns whether the player is wearing a clothes item.
-- @return [Boolean Whether the player wears clothes]
function playerMeta:IsWearingClothes()
  return (self:GetClothesItem() != nil)
end

--- Returns whether the player is wearing an item as clothes.
-- @param itemTable [Item The item instance]
-- @return [Boolean Whether the item is the worn clothes, or `nil` if the player wears none]
function playerMeta:IsWearingItem(itemTable)
  local clothesItem = self:GetClothesItem()
  return (clothesItem and clothesItem:IsTheSameAs(itemTable))
end

--- Networks the player's worn clothes in the `Clothes` net variable as `'<uniqueID> <itemID>'`.
--
-- The variable is an empty string when no clothes are worn.
function playerMeta:NetworkClothesData()
  local clothesData = self:GetClothesData()

  if clothesData.uniqueID and clothesData.itemID then
    self:SetNetVar('Clothes', clothesData.uniqueID..' '..clothesData.itemID)
  else
    self:SetNetVar('Clothes', '')
  end
end

--- Puts clothes on the player, or takes them off.
--
-- Calls `OnChangeClothes` on the old and new items and networks the change. Wearing clothes does nothing
-- when the player's class forces a model.
-- @param itemTable [Item The clothes item to wear, or `nil` to take the current clothes off]
function playerMeta:SetClothesData(itemTable)
  local clothesItem = self:GetClothesItem()

  if itemTable then
    local model = cw.class:GetAppropriateModel(self:Team(), self, true)

    if !model then
      if clothesItem and itemTable != clothesItem then
        clothesItem:OnChangeClothes(self, false)
      end

      itemTable:OnChangeClothes(self, true)

      local clothesData = self:GetClothesData()
        clothesData.itemID = itemTable.itemID
        clothesData.uniqueID = itemTable.uniqueID
      self:NetworkClothesData()
    end
  else
    local clothesData = self:GetClothesData()
      clothesData.itemID = nil
      clothesData.uniqueID = nil
    self:NetworkClothesData()

    if clothesItem then
      clothesItem:OnChangeClothes(self, false)
    end
  end
end

--- Returns the entity the player is holding.
--
-- The `PlayerGetHoldingEntity` hook is asked first.
-- @return [Entity The held entity, or `nil` if the player holds nothing]
function playerMeta:GetHoldingEntity()
  return hook.Run('PlayerGetHoldingEntity', self) or self.cwIsHoldingEnt
end

--- Returns whether the player's character menu was opened with a reset, which kills them silently.
-- @return [Boolean Whether the character menu was reset]
function playerMeta:IsCharacterMenuReset()
  return self.cwCharMenuReset
end

--- Returns whether the player has at least an amount of cash.
-- @param amount [Number The amount of cash]
-- @return [Boolean Whether the player can afford it; always `true` when cash is disabled]
-- @see cw.player:CanAfford
function playerMeta:CanAfford(amount)
  return cw.player:CanAfford(self, amount)
end

--- Returns the player's rank within their faction.
-- @param character=nil [Character Character to check instead of the player's current one]
-- @return [String The rank name, Map The rank's table from the faction's `ranks`]
-- @see cw.player:GetFactionRank
function playerMeta:GetFactionRank(character)
  return cw.player:GetFactionRank(self, character)
end

--- Sets the player's rank within their faction, applying the rank's class, model and weapons.
-- @param rank [String Name of a rank in the faction's `ranks`]
-- @see cw.player:SetFactionRank
function playerMeta:SetFactionRank(rank)
  return cw.player:SetFactionRank(self, rank)
end

--- Returns the player's global flags, which apply to all of their characters.
-- @return [String The flags, one letter each; `''` when none]
-- @see Player:GetFlags
function playerMeta:GetPlayerFlags()
  return cw.player:GetPlayerFlags(self)
end

playerMeta.GetName = playerMeta.Name
playerMeta.Nick = playerMeta.Name

concommand.Add('cwStatus', function(player, command, arguments)
  local plyTable = _player.GetAll()

  if IsValid(player) then
    if cw.player:IsAdmin(player) then
      player:PrintMessage(2, '# User ID | Name | Steam Name | Steam ID | IP Address')

      for k, v in ipairs(plyTable) do
        if v:HasInitialized() then
          local status = hook.Run('PlayerCanSeeStatus', player, v)

          if status then
            player:PrintMessage(2, status)
          end
        end
      end
    else
      player:PrintMessage(2, 'You do not have access to this command, '..player:Name()..'.')
    end
  else
    print('# User ID | Name | Steam Name | Steam ID | IP Address')

    for k, v in ipairs(plyTable) do
      if v:HasInitialized() then
        print('# '..v:UserID()..' | '..v:Name()..' | '..v:SteamName()..' | '..v:SteamID()..' | '..v:IPAddress())
      end
    end
  end
end)

-- The most awfully written function in cw.
-- Allows you to call certain commands from server console.
-- ToDo: Rewrite everything to be shorter
concommand.Add('cwc', function(player, command, arguments)
  -- Yep, it's awfully written, but it's not meant to be edited, so...
  local cmdTable = {
    sg  = 'setgroup',
    d   = 'demote',
    sc  = 'setcash',
    w   = 'whitelist',
    uw  = 'unwhitelist',
    b   = 'ban',
    k   = 'kick',
    sn  = 'setname',
    sm  = 'setmodel',
    r   = 'restart',
    gf  = 'giveflags',
    tf  = 'takeflags'
  }

  --  if called from console
  if !IsValid(player) then
    -- PlySetGroup
    if arguments[1] == cmdTable.sg then
      local target = _player.Find(arguments[2])
      local userGroup = arguments[3]

      if userGroup != 'superadmin' and userGroup != 'admin' and userGroup != 'operator' then
        MsgC(Color(255, 100, 0, 255), 'The user group must be superadmin, admin or operator!\n')

        return
      end

      if target then
        if !cw.player:IsProtected(target) then
          print('Console has set '..target:Name().."'s user group to "..userGroup..'.')
          cw.player:NotifyAll(L('Console_SetGroup', target:Name(), userGroup))
            target:SetClockworkUserGroup(userGroup)
          cw.player:LightSpawn(target, true, true)
        else
          MsgC(Color(255, 100, 0, 255), target:Name()..' is protected!\n')
        end
      else
        MsgC(Color(255, 100, 0, 255), arguments[2]..' is not a valid player!\n')
      end

      return
    -- PlyDemote
    elseif arguments[1] == cmdTable.d then
      local target = _player.Find(arguments[2])

      if target then
        if !cw.player:IsProtected(target) then
          local userGroup = target:GetClockworkUserGroup()

          if userGroup != 'user' then
            print('Console has demoted '..target:Name()..' from '..userGroup..' to user.')
            cw.player:NotifyAll(L('Console_Demoted', target:Name(), userGroup))
              target:SetClockworkUserGroup('user')
            cw.player:LightSpawn(target, true, true)
          else
            MsgC(Color(255, 100, 0, 255), 'This player is only a user and cannot be demoted!\n')
          end
        else
          MsgC(Color(255, 100, 0, 255), target:Name()..' is protected!\n')
        end
      else
        MsgC(Color(255, 100, 0, 255), arguments[2]..' is not a valid player!\n')
      end

      return
    -- SetCash
    elseif arguments[1] == cmdTable.sc then
      local target = _player.Find(arguments[2])
      local cash = math.floor(tonumber((arguments[3] or 0)))

      if target then
        if cash and cash >= 1 then
          local playerName = 'Console'
          local targetName = target:Name()
          local giveCash = cash - target:GetCash()

          cw.player:GiveCash(target, giveCash)

          print('Console has set '..targetName.."'s cash to "..cw.core:FormatCash(cash, nil, true)..'.')
          cw.player:Notify(target, L('Console_SetCash', cw.core:FormatCash(cash, nil, true)))
        else
          MsgC(Color(255, 100, 0, 255), 'This is not a valid amount!\n')
        end
      else
        MsgC(Color(255, 100, 0, 255), arguments[2]..' is not a valid player!\n')
      end

      return
    -- PlyWhitelist
    elseif arguments[1] == cmdTable.w then
      local target = _player.Find(arguments[2])

      if target then
        local factionTable = faction.FindByID(table.concat(arguments, ' ', 3))

        if factionTable then
          if factionTable.whitelist then
            if !cw.player:IsWhitelisted(target, factionTable.name) then
              cw.player:SetWhitelisted(target, factionTable.name, true)
              cw.player:SaveCharacter(target)

              print('Console has added '..target:Name()..' to the '..factionTable.name..' whitelist.')
              cw.player:NotifyAll(L('Console_WhitelistAdded', target:Name(), factionTable.name))
            else
              MsgC(Color(255, 100, 0, 255), target:Name()..' is already on the '..factionTable.name..' whitelist!\n')
            end
          else
            MsgC(Color(255, 100, 0, 255), factionTable.name..' does not have a whitelist!\n')
          end
        else
          MsgC(Color(255, 100, 0, 255), table.concat(arguments, ' ', 3)..' is not a valid faction!\n')
        end
      else
        MsgC(Color(255, 100, 0, 255), arguments[2]..' is not a valid player!\n')
      end

      return
    -- PlyUnWhitelist
    elseif arguments[1] == cmdTable.uw then
      local target = _player.Find(arguments[2])

      if target then
        local factionTable = faction.FindByID(table.concat(arguments, ' ', 3))

        if factionTable then
          if factionTable.whitelist then
            if cw.player:IsWhitelisted(target, factionTable.name) then
              cw.player:SetWhitelisted(target, factionTable.name, false)
              cw.player:SaveCharacter(target)

              print('Console has removed '..target:Name()..' from the '..factionTable.name..' whitelist.')
              cw.player:NotifyAll(L('Console_WhitelistRemoved', target:Name(), factionTable.name))
            else
              MsgC(Color(255, 100, 0, 255), target:Name()..' is not on the '..factionTable.name..' whitelist!\n')
            end
          else
            MsgC(Color(255, 100, 0, 255), factionTable.name..' does not have a whitelist!\n')
          end
        else
          MsgC(Color(255, 100, 0, 255), factionTable.name..' is not a valid faction!\n')
        end
      else
        MsgC(Color(255, 100, 0, 255), arguments[2]..' is not a valid player!\n')
      end

      return
    -- PlyBan
    elseif arguments[1] == cmdTable.b then
      local schemaFolder = cw.core:GetSchemaFolder()
      local duration = tonumber(arguments[3])
      local reason = table.concat(arguments, ' ', 4)

      if !reason or reason == '' then
        reason = nil
      end

      if !cw.player:IsProtected(arguments[2]) then
        if duration then
          cw.bans:Add(arguments[2], duration * 60, reason, function(steamName, duration, reason)
            if IsValid(player) then
              if steamName then
                if duration > 0 then
                  local hours = math.Round(duration / 3600)

                  if hours >= 1 then
                    print("Console has banned '"..steamName.."' for "..hours..' hour(s) ('..reason..').')
                    cw.player:NotifyAll(L('Console_BannedHours', steamName, hours)..' '..reason)
                  else
                    print(
                      "Console has banned '"..steamName.."' for "..math.Round(duration / 60)..' minute(s) ('..reason..
                        ').'
                    )
                    cw.player:NotifyAll(L('Console_BannedMinutes', steamName, math.Round(duration / 60))..' '..reason)
                  end
                else
                  print("Console has banned '"..steamName.."' permanently ("..reason..').')
                  cw.player:NotifyAll(L('Console_BannedPermanently', steamName)..' '..reason)
                end
              else
                MsgC(Color(255, 100, 0, 255), 'This is not a valid identifier!\n')
              end
            end
          end)
        else
          MsgC(Color(255, 100, 0, 255), 'This is not a valid duration!\n')
        end
      else
        local target = _player.Find(arguments[2])

        if target then
          MsgC(Color(255, 100, 0, 255), target:Name()..' is protected!\n')
        else
          MsgC(Color(255, 100, 0, 255), 'This player is protected!\n')
        end
      end

      return
    -- PlyKick
    elseif arguments[1] == cmdTable.k then
      local target = _player.Find(arguments[2])
      local reason = table.concat(arguments, ' ', 3)

      if !reason or reason == '' then
        reason = 'N/A'
      end

      if target then
        if !cw.player:IsProtected(arguments[2]) then
          print("Console has kicked '"..target:Name().."' ("..reason..').')
          cw.player:NotifyAll(L('Console_Kicked', target:Name())..' '..reason)
            target:Kick(reason)
          target.kicked = true
        else
          MsgC(Color(255, 100, 0, 255), target:Name()..' is protected!\n')
        end
      else
        MsgC(Color(255, 100, 0, 255), arguments[1]..' is not a valid player!\n')
      end

      return
    -- CharSetName
    elseif arguments[1] == cmdTable.sn then
      local target = _player.Find(arguments[2])

      if target then
        if arguments[3] == 'nil' then
          MsgC(
            Color(255, 100, 0, 255),
            "You have to specify the name as the last argument, it also has to be 'quoted'.\n"
          )

          return
        else
          local name = table.concat(arguments, ' ', 3)

          print('Console has set '..target:Name().."'s name to "..name..'.')
          cw.player:NotifyAll(L('Console_SetName', target:Name(), name))

          cw.player:SetName(target, name)
        end
      else
        MsgC(Color(255, 100, 0, 255), arguments[2]..' is not a valid character!\n')
      end

      return
    -- CharSetModel
    elseif arguments[1] == cmdTable.sm then
      local target = _player.Find(arguments[2])

      if target then
        local model = table.concat(arguments, ' ', 3)

        target:SetCharacterData('Model', model, true)
        target:SetModel(model)

        print('Console has set '..target:Name().."'s model to "..model..'.')
        cw.player:NotifyAll(L('Console_SetModel', target:Name(), model))
      else
        MsgC(Color(255, 100, 0, 255), arguments[2]..' is not a valid character!\n')
      end

      return
    -- MapRestart
    elseif arguments[1] == cmdTable.r then
      local delay = tonumber(arguments[2]) or 10

      if type(arguments[2]) == 'number' then
        delay = arguments[2]
      end

      print('Console is restarting the map in '..delay..' seconds!')
      cw.player:NotifyAll(L('Console_MapRestart', delay))

      timer.Simple(delay, function()
        RunConsoleCommand('changelevel', game.GetMap())
      end)

      return
    -- GiveFlags
    elseif arguments[1] == cmdTable.gf then
      local target = _player.Find(arguments[2])

      if target then
        if string.find(arguments[3], 'a') or string.find(arguments[3], 's') or string.find(arguments[3], 'o') then
          MsgC(Color(255, 100, 0, 255), "You cannot give 'o', 'a' or 's' flags!\n")

          return
        end

        if !arguments[3] then print("You haven't entered any flags!") return end

        cw.player:GiveFlags(target, arguments[3])

        print('Console gave '..target:Name().." '"..arguments[3].."' flags.")
        cw.player:NotifyAll(L('Console_GaveFlags', target:Name(), arguments[3]))
      else
        MsgC(Color(255, 100, 0, 255), arguments[2]..' is not a valid character!\n')
      end

      return
    -- TakeFlags
    elseif arguments[1] == cmdTable.tf then
      local target = _player.Find(arguments[2])

      if target then
        if string.find(arguments[3], 'a') or string.find(arguments[3], 's') or string.find(arguments[3], 'o') then
          cw.player:Notify(player, L('Command_CannotTakeAdminFlags'))

          return
        end

        if !arguments[3] then print("You haven't entered any flags!") return end

        cw.player:TakeFlags(target, arguments[3])

        print("Console took '"..arguments[3].."' flags from "..target:Name()..'.')
        cw.player:NotifyAll(L('Console_TookFlags', target:Name(), arguments[3]))
      else
        MsgC(Color(255, 100, 0, 255), arguments[2]..' is not a valid character!\n')
      end

      return
    -- Everything else
    else
      MsgC(Color(255, 100, 0, 255), "'"..arguments[1].."' command not found!\n")
    end

  -- if not too bad, players are not allowed to use this swag
  else
    cw.player.Notify(player, L('Console_NotAllowed'))
  end
end)

concommand.Add('cwDeathCode', function(player, command, arguments)
  if player.cwDeathCodeIdx then
    if arguments and tonumber(arguments[1]) == player.cwDeathCodeIdx then
      player.cwDeathCodeAuth = true
    end
  end
end)

--[[ Accessories --]]
local playerMeta = FindMetaTable('Player')

--- Sends all of the player's worn accessories to their client.
function playerMeta:NetworkAccessories()
  local accessoryData = self:GetAccessoryData()

  netstream.Start(self, 'AllAccessories', accessoryData)
end

--- Takes off an accessory the player is wearing.
--
-- Tells the client and calls the item's `OnWearAccessory` with `false`. Does nothing if it is not worn.
-- @param itemTable [Item The accessory item instance]
function playerMeta:RemoveAccessory(itemTable)
  if !self:IsWearingAccessory(itemTable) then return end

  local accessoryData = self:GetAccessoryData()
  local uniqueID = itemTable.uniqueID
  local itemID = itemTable.itemID

  accessoryData[itemID] = nil
    netstream.Start(
      self, 'RemoveAccessory', { itemID = itemID }
    )

  if itemTable.OnWearAccessory then
    itemTable:OnWearAccessory(self, false)
  end
end

--- Returns whether the player is wearing any accessory of an item type.
-- @param uniqueID [String Unique ID of the accessory item, compared ignoring case]
-- @return [Boolean Whether such an accessory is worn]
function playerMeta:HasAccessory(uniqueID)
  local accessoryData = self:GetAccessoryData()

  for k, v in pairs(accessoryData) do
    if string.lower(v) == string.lower(uniqueID) then
      return true
    end
  end

  return false
end

--- Returns whether the player is wearing a specific accessory item instance.
-- @param itemTable [Item The accessory item instance]
-- @return [Boolean Whether it is worn]
function playerMeta:IsWearingAccessory(itemTable)
  local accessoryData = self:GetAccessoryData()
  local itemID = itemTable.itemID

  if accessoryData[itemID] then
    return true
  else
    return false
  end
end

--- Puts on an accessory item.
--
-- Tells the client and calls the item's `OnWearAccessory` with `true`. Does nothing if it is already worn.
-- @param itemTable [Item The accessory item instance]
function playerMeta:WearAccessory(itemTable)
  if self:IsWearingAccessory(itemTable) then return end

  local accessoryData = self:GetAccessoryData()
  local uniqueID = itemTable.uniqueID
  local itemID = itemTable.itemID

  accessoryData[itemID] = itemTable.uniqueID
  netstream.Start(
    self, 'AddAccessory', { itemID = itemID, uniqueID = uniqueID }
  )

  if itemTable.OnWearAccessory then
    itemTable:OnWearAccessory(self, true)
  end
end

--- Sets a value in the player's character data, or a base field of the character.
--
-- When the value changes, it is sent to clients with `cw.player:UpdateCharacterData` and the
-- `PlayerCharacterDataChanged` hook is called with the key, old and new value. Base fields
-- (`bFromBase`) are camel cased, only set if they already exist, and are not networked.
-- @param key [String Name of the value, as registered with `cw.player:AddCharacterData`]
-- @param value [Any The new value]
-- @param bFromBase=nil [Boolean Set a base field of the character table instead of its data]
-- @see Player:GetCharacterData
function playerMeta:SetCharacterData(key, value, bFromBase)
  local character = self:GetCharacter()

  if !character then return end

  if bFromBase then
    key = cw.core:SetCamelCase(key, true)

    if character[key] != nil then
      character[key] = value
    end
  else
    local oldValue = character.data[key]
    character.data[key] = value

    if !netvars.AreEqual(value, oldValue) then
      cw.player:UpdateCharacterData(self, key, value)

      plugin.Call('PlayerCharacterDataChanged', self, key, oldValue, value)
    end
  end
end

--- Sets a value in the player's persistent data, which belongs to the player rather than a character.
--
-- When the value changes, it is sent with `cw.player:UpdatePlayerData` and the `PlayerDataChanged` hook is
-- called with the key, old and new value. Does nothing before the player's data has loaded.
-- @param key [String Name of the value]
-- @param value [Any The new value]
-- @see Player:GetData
function playerMeta:SetData(key, value)
  if self.cwData then
    local oldValue = self.cwData[key]
    self.cwData[key] = value

    if value != oldValue then
      cw.player:UpdatePlayerData(self, key, value)

      plugin.Call('PlayerDataChanged', self, key, oldValue, value)
    end
  end
end

local phrases = {
  'Sending your private info to kurozael',
  'Hacking your bank accounts',
  'Stealing your cat',
  'Installing Windows 10 spyware',
  'Sending your private info to Microsoft',
  'Do not wait',
  'Using your server to DDoS LemonPunch',
  'Using your server to mine bitcoins',
  'Crashing your server',
  'Adding extra 7 seconds to boot times',
  'Sending a DMCA notice to Alex Grist',
  'Starting a lawsuit against you for using Catwork',
  'Installing backdoors',
  'Giving kurozael owner',
  'Banning your whole playerbase',
  'You are not authorized by CloudAuthX to use Catwork',
  'Making kittens cry',
  'Installing an update that breaks everything',
  'Loading your CPU core to 100%',
  'Crying about that extra space in the serial file',
  'Attempting to explode your server for using Catwork',
  'CloudAuthX is not installed',
  'Downloading porn',
  "Opening kuro's favorite PH category (gay porn)",
  'Reporting you to NSA',
  'Banning random people',
  'Attempting to install legit cw... ERROR',
  'Transferring all your money to kurozael',
  'Transferring $30 to kurozael',
  '#kurobucks, #kurobank',
  'Throwing all the errors at you',
  'Downloading internet',
  'Sending your server IP to Anonymous',
  'Taking over your community',
  'Turning your cat into a dog',
  'Turning your dog into a cat',
  'Suing you for using Catwork',
  'Generating a ton of Alex Grist drama',
  'Burning your CPU',
  'Stealing your CS:GO items',
  'Stealing your TF2 hats',
  'Downloading ponies',
  'Generating Lua Errors',
  'Something is creating script errors',
  'Banning people for thinking about NutScript',
  'Installing NutScript',
  'Ripping off NutScript',
  'Stealing TARDIS',
  'Installing winlocker',
  'Hacking your Apple ID'
}

MsgC(Color(0, 255, 255, 255), '[CloudAuthX] '..table.Random(phrases)..', please wait...\n')
