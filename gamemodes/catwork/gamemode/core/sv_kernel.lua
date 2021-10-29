--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

--[[ Downloads the content addon for clients. --]]
resource.AddWorkshop("474315121")

resource.AddFile("resource/fonts/fontawesome-webfont.ttf")
resource.AddFile("resource/fonts/kellyslab.ttf")

cw.core:AddDirectory("resource/fonts/")

--[[
	Derive from Sandbox, because we want the spawn menu and such!
	We also want the base Sandbox entities and weapons.
--]]
DeriveGamemode("sandbox")

--[[
	This is a hack to stop file.Read returning an unnecessary newline
	at the end of each file when using Linux.
--]]
if (system.IsLinux()) then
	ClockworkFileRead = ClockworkFileRead or file.Read

	function file.Read(fileName, pathName)
		local contents = ClockworkFileRead(fileName, pathName)

		if (contents and string.utf8sub(contents, -1) == "\n") then
			contents = string.utf8sub(contents, 1, -2)
		end

		return contents
	end
end

-- Fix for SQLite duplicating ' character.
function sql.SQLStr(str_in, bNoQuotes)
	local str = tostring(str_in)

	local null_chr = string.find(str, "\0")

	if (null_chr) then
		str = string.utf8sub(str, 1, null_chr - 1)
	end

	if (bNoQuotes) then
		return str
	end

	return "'"..str.."'"
end

oldFileioWrite = oldFileioWrite or catio.Write

function catio.Write(fileName, content)
	local exploded = string.Explode("/", fileName)
	local curPath = ""

	for k, v in ipairs(exploded) do
		if (string.GetExtensionFromFilename(v) != nil) then
			break
		end

		curPath = curPath..v.."/"

		if (!file.Exists(curPath, "GAME")) then
			catio.MakeDirectory(curPath)
		end
	end

	oldFileioWrite(fileName, content)
end

base64 = base64 or {}

-- Ghetto Fix for base64 encoding not properly working with NULL (0) character in C++.
local oldb64encode = base64.oldEncode or base64.encode
base64.oldEncode = oldb64encode

local oldb64decode = base64.oldDecode or base64.decode
base64.oldDecode = oldb64decode

function base64.encode(str)
	str = tostring(str)
	str = str:Replace(string.char(0), utf8.char(999))

	return oldb64encode(str)
end

function base64.decode(str)
	str = oldb64decode(str)
	str = str:Replace(utf8.char(999), string.char(0))

	return str
end

-- End Ghetto Fix

local ServerLog = ServerLog
local cvars = cvars

cw.Entities = cw.Entities or {}
cw.HitGroupBonesCache = {
	{"ValveBiped.Bip01_R_UpperArm", HITGROUP_RIGHTARM},
	{"ValveBiped.Bip01_R_Forearm", HITGROUP_RIGHTARM},
	{"ValveBiped.Bip01_L_UpperArm", HITGROUP_LEFTARM},
	{"ValveBiped.Bip01_L_Forearm", HITGROUP_LEFTARM},
	{"ValveBiped.Bip01_R_Thigh", HITGROUP_RIGHTLEG},
	{"ValveBiped.Bip01_R_Calf", HITGROUP_RIGHTLEG},
	{"ValveBiped.Bip01_R_Foot", HITGROUP_RIGHTLEG},
	{"ValveBiped.Bip01_R_Hand", HITGROUP_RIGHTARM},
	{"ValveBiped.Bip01_L_Thigh", HITGROUP_LEFTLEG},
	{"ValveBiped.Bip01_L_Calf", HITGROUP_LEFTLEG},
	{"ValveBiped.Bip01_L_Foot", HITGROUP_LEFTLEG},
	{"ValveBiped.Bip01_L_Hand", HITGROUP_LEFTARM},
	{"ValveBiped.Bip01_Pelvis", HITGROUP_STOMACH},
	{"ValveBiped.Bip01_Spine2", HITGROUP_CHEST},
	{"ValveBiped.Bip01_Spine1", HITGROUP_CHEST},
	{"ValveBiped.Bip01_Head1", HITGROUP_HEAD},
	{"ValveBiped.Bip01_Neck1", HITGROUP_HEAD}
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
	md_venetianredux_b2fix 			= 106094354,
	rp_c18_v1 						= 132931674,
	rp_c18_v2 						= 132937160,
	rp_city8 						= 132913036,
	rp_city8_2 						= 132940295,
	rp_city8_canals 				= 132911524,
	rp_city8_district1 				= 132919876,
	rp_city8_district9 				= 132916875,
	rp_city11_night_v1b 			= 127632645,
	rp_city17_v1 					= 113352748,
	rp_city23_night 				= 143076340,
	rp_city45_2013 					= 118759412,
	rp_city45_catalyst_x1f_final 	= 221567663,
	rp_nc_industrial17_v2 			= 698222128,
	rp_nc_city8_v2a 				= 736405289,
	rp_gc_city8						= 760771478
}

-- A function to save schema data.
function cw.core:SaveSchemaData(fileName, data, bForceJSON)
	if (type(data) != "table") then
		MsgC(Color(255, 100, 0, 255), "[CW:Kernel] The '"..fileName.."' schema data has failed to save.\nUnable to save type "..type(data)..", table required.\n")
		return
	end

	return catio.Write("settings/catwork/schemas/"..cw.Schema.."/"..fileName..".cw", self:Serialize(data, bForceJSON))
end

-- A function to delete schema data.
function cw.core:DeleteSchemaData(fileName)
	return catio.Delete("settings/catwork/schemas/"..cw.Schema.."/"..fileName..".cw")
end

-- A function to check if schema data exists.
function cw.core:SchemaDataExists(fileName)
	return _file.Exists("settings/catwork/schemas/"..cw.Schema.."/"..fileName..".cw", "GAME")
end

-- A function to get the schema data path.
function cw.core:GetSchemaDataPath()
	return "settings/catwork/schemas/"..cw.Schema
end

SCHEMA_GAMEMODE_INFO = SCHEMA_GAMEMODE_INFO or nil

-- A function to get the schema gamemode info.
function cw.core:GetSchemaGamemodeInfo()
	if (SCHEMA_GAMEMODE_INFO) then return SCHEMA_GAMEMODE_INFO end

	local schemaFolder = string.lower(self:GetSchemaFolder())
	local schemaData = util.KeyValuesToTable(
		catio.Read("gamemodes/"..schemaFolder.."/"..schemaFolder..".txt")
	)

	if (!schemaData) then
		schemaData = {}
	end

	if (schemaData["Gamemode"]) then
		schemaData = schemaData["Gamemode"]
	end

	SCHEMA_GAMEMODE_INFO = {}
		SCHEMA_GAMEMODE_INFO["name"] = schemaData["title"] or "Undefined"
		SCHEMA_GAMEMODE_INFO["author"] = schemaData["author"] or "Undefined"
		SCHEMA_GAMEMODE_INFO["description"] = schemaData["description"] or "Undefined"
		SCHEMA_GAMEMODE_INFO["version"] = schemaData["version"] or "Undefined"
	return SCHEMA_GAMEMODE_INFO
end

-- A function to get the schema gamemode name.
function cw.core:GetSchemaGamemodeName()
	if (Schema) then
		return Schema:GetName()
	else
		return "Catwork"
	end
end

-- A function to get the schema version.
function cw.core:GetSchemaGamemodeVersion()
	local schemaInfo = self:GetSchemaGamemodeInfo()

	return schemaInfo["version"]
end

-- A function to find schema data in a directory.
function cw.core:FindSchemaDataInDir(directory)
	return _file.Find("settings/catwork/schemas/"..self:GetSchemaFolder().."/"..directory, "GAME")
end

-- A function to restore schema data.
function cw.core:RestoreSchemaData(fileName, failSafe, bForceJSON)
	if (self:SchemaDataExists(fileName)) then
		local data = catio.Read("settings/catwork/schemas/"..cw.Schema.."/"..fileName..".cw", "namedesc")

		if (data) then
			local bSuccess, value = pcall(self.Deserialize, self, data, bForceJSON)

			if (bSuccess and value != nil) then
				return value
			elseif (!bSuccess) then
				MsgC(Color(255, 100, 0, 255), "[CW:Kernel] '"..fileName.."' schema data has failed to restore.\n"..tostring(value).."\n")

				self:DeleteSchemaData(fileName)
			end
		end
	end

	if (failSafe != nil) then
		return failSafe
	else
		return {}
	end
end

-- A function to restore Clockwork data.
function cw.core:RestoreClockworkData(fileName, failSafe)
	if (self:ClockworkDataExists(fileName)) then
		local data = catio.Read("settings/clockwork/"..fileName..".cw")

		if (data) then
			local bSuccess, value = pcall(self.Deserialize, self, data)

			if (bSuccess and value != nil) then
				return value
			else
				MsgC(Color(255, 100, 0, 255), "[CW:Kernel] '"..fileName.."' catwork data has failed to restore.\n"..value.."\n")

				self:DeleteClockworkData(fileName)
			end
		end
	end

	if (failSafe != nil) then
		return failSafe
	else
		return {}
	end
end

-- A function to setup a full directory.
function cw.core:SetupFullDirectory(filePath)
	local directory = string.gsub(self:GetPathToGMod()..filePath, "\\", "/")
	local exploded = string.Explode("/", directory)
	local currentPath = ""

	for k, v in ipairs(exploded) do
		if (k < #exploded) then
			currentPath = currentPath..v.."/"
			catio.MakeDirectory(currentPath)
		end
	end

	return currentPath..exploded[#exploded]
end

-- A function to save Clockwork data.
function cw.core:SaveClockworkData(fileName, data)
	if (type(data) != "table") then
		MsgC(Color(255, 100, 0, 255), "[CW:Kernel] The '"..fileName.."' clockwork data has failed to save.\nUnable to save type "..type(data)..", table required.\n")

		return
	end

	return catio.Write("settings/clockwork/"..fileName..".cw", self:Serialize(data))
end

-- A function to check if Clockwork data exists.
function cw.core:ClockworkDataExists(fileName)
	return _file.Exists("settings/clockwork/"..fileName..".cw", "GAME")
end

-- A function to delete Clockwork data.
function cw.core:DeleteClockworkData(fileName)
	return catio.Delete("settings/clockwork/"..fileName..".cw")
end

-- A function to convert a force.
function cw.core:ConvertForce(force, limit)
	local forceLength = force:Length()

	if (forceLength == 0) then
		return Vector(0, 0, 0)
	end

	if (!limit) then
		limit = 800
	end

	if (forceLength > limit) then
		return force / (forceLength / limit)
	else
		return force
	end
end

-- A function to save a player's attribute boosts.
function cw.core:SavePlayerAttributeBoosts(player, data)
	local attributeBoosts = player:GetAttributeBoosts()
	local curTime = CurTime()

	if (data["AttrBoosts"]) then
		data["AttrBoosts"] = nil
	end

	if (table.Count(attributeBoosts) > 0) then
		data["AttrBoosts"] = {}

		for k, v in pairs(attributeBoosts) do
			data["AttrBoosts"][k] = {}

			for k2, v2 in pairs(v) do
				if (v2.duration) then
					if (curTime < v2.endTime) then
						data["AttrBoosts"][k][k2] = {
							duration = math.ceil(v2.endTime - curTime),
							amount = v2.amount
						}
					end
				else
					data["AttrBoosts"][k][k2] = {
						amount = v2.amount
					}
				end
			end
		end
	end
end

-- A function to calculate a player's spawn time.
function cw.core:CalculateSpawnTime(player, inflictor, attacker, damageInfo)
	local info = {
		attacker = attacker,
		inflictor = inflictor,
		spawnTime = config.GetVal("spawn_time"),
		damageInfo = damageInfo
	}

	hook.Run("PlayerAdjustDeathInfo", player, info)

	if (info.spawnTime and info.spawnTime > 0) then
		cw.player:SetAction(player, "spawn", info.spawnTime, 3)
	end
end

-- A function to create a decal.
function cw.core:CreateDecal(texture, position, temporary)
	local decal = ents.Create("infodecal")

	if (temporary) then
		decal:SetKeyValue("LowPriority", "true")
	end

	decal:SetKeyValue("Texture", texture)
	decal:SetPos(position)
	decal:Spawn()
	decal:Fire("activate")

	return decal
end

-- A function to handle a player's weapon fire delay.
function cw.core:HandleWeaponFireDelay(player, bIsRaised, weapon, curTime)
	local delaySecondaryFire = nil
	local delayPrimaryFire = nil

	if (!hook.Run("PlayerCanFireWeapon", player, bIsRaised, weapon, true)) then
		delaySecondaryFire = curTime + 60
	end

	if (!hook.Run("PlayerCanFireWeapon", player, bIsRaised, weapon)) then
		delayPrimaryFire = curTime + 60
	end

	if (delaySecondaryFire == nil and weapon.secondaryFireDelayed) then
		weapon:SetNextSecondaryFire(weapon.secondaryFireDelayed)
		weapon.secondaryFireDelayed = nil
	end

	if (delayPrimaryFire == nil and weapon.primaryFireDelayed) then
		weapon:SetNextPrimaryFire(weapon.primaryFireDelayed)
		weapon.primaryFireDelayed = nil
	end

	if (delaySecondaryFire) then
		if (!weapon.secondaryFireDelayed) then
			weapon.secondaryFireDelayed = weapon:GetNextSecondaryFire()
		end

		--[[
			This is a terrible hotfix for the SMG not being able
			to fire after loading ammunition.
		--]]
		if (weapon:GetClass() != "weapon_smg1") then
			weapon:SetNextSecondaryFire(delaySecondaryFire)
		end
	end

	if (delayPrimaryFire) then
		if (!weapon.primaryFireDelayed) then
			weapon.primaryFireDelayed = weapon:GetNextPrimaryFire()
		end

		weapon:SetNextPrimaryFire(delayPrimaryFire)
	end
end

-- A function to calculate player damage.
function cw.core:CalculatePlayerDamage(player, hitGroup, damageInfo)
	local bDamageIsValid = damageInfo:IsBulletDamage() or damageInfo:IsDamageType(DMG_CLUB) or damageInfo:IsDamageType(DMG_SLASH)
	local bHitGroupIsValid = true

	if (config.GetVal("armor_chest_only")) then
		if (hitGroup != HITGROUP_CHEST and hitGroup != HITGROUP_GENERIC) then
			bHitGroupIsValid = nil
		end
	end

	if (player:Armor() > 0 and bDamageIsValid and bHitGroupIsValid) then
		local armor = player:Armor() - damageInfo:GetDamage()

		if (armor < 0) then
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

	if (damageInfo:IsFallDamage()) then
		cw.limb:TakeDamage(player, HITGROUP_RIGHTLEG, damageInfo:GetDamage())
		cw.limb:TakeDamage(player, HITGROUP_LEFTLEG, damageInfo:GetDamage())
	end
end

-- A function to get a ragdoll's hit bone.
function cw.core:GetRagdollHitBone(entity, position, failSafe, minimum)
	local closest = {}

	for k, v in pairs(cw.HitGroupBonesCache) do
		local bone = entity:LookupBone(v[1])

		if (bone) then
			local bonePosition = entity:GetBonePosition(bone)

			if (bonePosition) then
				local distance = bonePosition:Distance(position)

				if (!closest[1] or distance < closest[1]) then
					if (!minimum or distance <= minimum) then
						closest[1] = distance
						closest[2] = bone
					end
				end
			end
		end
	end

	if (closest[2]) then
		return closest[2]
	else
		return failSafe
	end
end

-- A function to get a ragdoll's hit group.
function cw.core:GetRagdollHitGroup(entity, position)
	local closest = {nil, HITGROUP_GENERIC}

	for k, v in pairs(cw.HitGroupBonesCache) do
		local bone = entity:LookupBone(v[1])

		if (bone) then
			local bonePosition = entity:GetBonePosition(bone)

			if (position) then
				local distance = bonePosition:Distance(position)

				if (!closest[1] or distance < closest[1]) then
					closest[1] = distance
					closest[2] = v[2]
				end
			end
		end
	end

	return closest[2]
end

-- A function to create blood effects at a position.
function cw.core:CreateBloodEffects(position, decals, entity, forceVec, fScale)
	if (!entity.cwNextBlood or CurTime() >= entity.cwNextBlood) then
		local effectData = EffectData()
			effectData:SetOrigin(position)
			effectData:SetNormal(forceVec or (VectorRand() * 80))
			effectData:SetScale(fScale or 0.5)
		util.Effect("cw_bloodsmoke", effectData, true, true)

		local effectData = EffectData()
			effectData:SetOrigin(position)
			effectData:SetEntity(entity)
			effectData:SetStart(position)
			effectData:SetScale(fScale or 0.5)
		util.Effect("BloodImpact", effectData, true, true)

		for i = 1, decals do
			local trace = {}
				trace.start = position
				trace.endpos = trace.start
				trace.filter = entity
			trace = util.TraceLine(trace)

			util.Decal("Blood", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal)
		end

		entity.cwNextBlood = CurTime() + 0.5
	end
end

-- A function to perform the date and time think.
function cw.core:PerformDateTimeThink()
	local defaultDays = cw.option:GetKey("default_days")
	local minute = cw.time:GetMinute()
	local month = cw.date:GetMonth()
	local year = cw.date:GetYear()
	local hour = cw.time:GetHour()
	local day = cw.time:GetDay()

	cw.time.minute = cw.time:GetMinute() + 1

	if (cw.time:GetMinute() >= 60) then
		cw.time.minute = 0
		cw.time.hour = cw.time:GetHour() + 1

		if (cw.time:GetHour() >= 24) then
			cw.time.hour = 0
			cw.time.day = cw.time:GetDay() + 1
			cw.date.day = cw.date:GetDay() + 1

			if (cw.time:GetDay() == #defaultDays + 1) then
				cw.time.day = 1
			end

			if (cw.date:GetDay() >= 31) then
				cw.date.day = 1
				cw.date.month = cw.date:GetMonth() + 1

				if (cw.date:GetMonth() >= 13) then
					cw.date.month = 1
					cw.date.year = cw.date:GetYear() + 1
				end
			end
		end
	end

	if (cw.time:GetMinute() != minute) then
		hook.Run("TimePassed", TIME_MINUTE)
	end

	if (cw.time:GetHour() != hour) then
		hook.Run("TimePassed", TIME_HOUR)
	end

	if (cw.time:GetDay() != day) then
		hook.Run("TimePassed", TIME_DAY)
	end

	if (cw.date:GetMonth() != month) then
		hook.Run("TimePassed", TIME_MONTH)
	end

	if (cw.date:GetYear() != year) then
		hook.Run("TimePassed", TIME_YEAR)
	end

	local month = self:ZeroNumberToDigits(cw.date:GetMonth(), 2)
	local day = self:ZeroNumberToDigits(cw.date:GetDay(), 2)

	netvars.SetNetVar("minute", minute)
	netvars.SetNetVar("hour", hour)
	netvars.SetNetVar("date", day.."/"..month.."/"..year)
	netvars.SetNetVar("day", day)
end

-- A function to create a ConVar.
function cw.core:CreateConVar(name, value, flags, Callback)
	local conVar = CreateConVar(name, value, flags or FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)

	cvars.AddChangeCallback(name, function(conVar, previousValue, newValue)
		hook.Run("ClockworkConVarChanged", conVar, previousValue, newValue)

		if (Callback) then
			Callback(conVar, previousValue, newValue)
		end
	end)

	return conVar
end

-- A function to check if the server is shutting down.
function cw.core:IsShuttingDown()
	return cw.ShuttingDown
end

-- A function to distribute wages cash.
function cw.core:DistributeWagesCash()
	for k, v in ipairs(_player.GetAll()) do
		if (v:HasInitialized() and v:Alive()) then
			local info = {
				wages = v:GetWages()
			}

			hook.Run("PlayerModifyWagesInfo", v, info)

			if (hook.Run("PlayerCanEarnWagesCash", v, info.wages)) then
				if (info.wages > 0) then
					if (hook.Run("PlayerGiveWagesCash", v, info.wages, v:GetWagesName())) then
						cw.player:GiveCash(v, info.wages, v:GetWagesName())
					end
				end

				hook.Run("PlayerEarnWagesCash", v, info.wages)
			end
		end
	end
end

-- A function to include the schema.
function cw.core:IncludeSchema()
	local schemaFolder = self:GetSchemaFolder()

	if (schemaFolder and type(schemaFolder) == "string") then
		config.Load(nil, true)
			self:LoadSchema()
		config.Load()
	end
end

-- A function to print a log message.
function cw.core:PrintLog(logType, text)
	local listeners = {}
	local plyTable = _player.GetAll()

	for k, v in ipairs(plyTable) do
		if (v:HasInitialized() and v:GetInfoNum("cwShowLog", 0) == 1) then
			if (cw.player:IsAdmin(v)) then
				listeners[#listeners + 1] = v
			end
		end
	end

	netstream.Start(listeners, "Log", {
		logType = (logType or 5), text = text
	})

	if (CW_CONVAR_LOG:GetInt() == 1 and game.IsDedicated()) then
		self:ServerLog(text)
	end
end

-- A function to log to the server.
function cw.core:ServerLog(text)
	local dateInfo = os.date("*t")
	local unixTime = os.time()

	if (dateInfo) then
		if (dateInfo.month < 10) then dateInfo.month = "0"..dateInfo.month; end
		if (dateInfo.day < 10) then dateInfo.day = "0"..dateInfo.day; end
		local fileName = dateInfo.year.."-"..dateInfo.month.."-"..dateInfo.day

		if (dateInfo.hour < 10) then dateInfo.hour = "0"..dateInfo.hour; end
		if (dateInfo.min < 10) then dateInfo.min = "0"..dateInfo.min; end
		if (dateInfo.sec < 10) then dateInfo.sec = "0"..dateInfo.sec; end
		local time = dateInfo.hour..":"..dateInfo.min..":"..dateInfo.sec
		local logText = time..": "..string.gsub(text, "\n", "")

		catio.Append("logs/clockwork/"..fileName..".log", logText.."\n")
	end

	ServerLog(text.."\n"); hook.Run("ClockworkLog", text, unixTime)
end

-- the function below is from Gristwork I believe.
-- so kudos to Alex Grist for making it

-- A function to add workshop collections to the resources.
function cw.core:AddWorkshopCollection(id)
	http.Fetch("http://steamcommunity.com/sharedfiles/filedetails/?id="..id, function(page)
		for k in string.gmatch(page, [[<div id="sharedfile_(.-)" class="collectionItem">]]) do
			resource.AddWorkshop(k)
		end
	end)
end

do
	if (cw.WorkshopMaps[game.GetMap()]) then
		resource.AddWorkshop(cw.WorkshopMaps[game.GetMap()])
	else
		resource.AddSingleFile("maps/"..game.GetMap()..".bsp")
	end

	local workshopCollection = GetConVarString("host_workshop_collection")

	if (workshopCollection != "") then
		cw.core:AddWorkshopCollection(workshopCollection)
	else
		cw.core:AddWorkshopCollection("1117399683") -- Blowback content
	end
end

-- A function to do the entity take damage hook.
function cw.core:DoEntityTakeDamageHook(entity, damageInfo)
	if (!IsValid(entity)) then
		return
	end

	local inflictor = damageInfo:GetInflictor()
	local attacker = damageInfo:GetAttacker()
	local amount = damageInfo:GetDamage()

	if (amount != damageInfo:GetDamage()) then
		amount = damageInfo:GetDamage()
	end

	local player = cw.entity:GetPlayer(entity)

	if (player) then
		local ragdoll = player:GetRagdollEntity()

		hook.Run("PrePlayerTakeDamage", player, attacker, inflictor, damageInfo)

		if (!hook.Run("PlayerShouldTakeDamage", player, attacker, inflictor, damageInfo)
		or player:IsInGodMode()) then
			damageInfo:SetDamage(0)

			return true
		end

		if (ragdoll and entity != ragdoll) then
			hook.Run("EntityTakeDamage", ragdoll, damageInfo)
			damageInfo:SetDamage(0)

			return true
		end

		if (entity == ragdoll) then
			local physicsObject = entity:GetPhysicsObject()

			if (IsValid(physicsObject)) then
				local velocity = physicsObject:GetVelocity():Length()
				local curTime = CurTime()

				if (damageInfo:IsDamageType(DMG_CRUSH)) then
					if (entity.cwNextFallDamage
					and curTime < entity.cwNextFallDamage) then
						damageInfo:SetDamage(0)
						return true
					end

					amount = hook.Run("GetFallDamage", player, velocity)
					entity.cwNextFallDamage = curTime + 1
					damageInfo:SetDamage(amount)
				end
			end
		end
	end
end

--[[ Disable game saving and admin cleanup. --]]
concommand.Add("gm_save", function(player, command, arguments)
	ErrorNoHalt("[Catwork] "..player:Name().." ("..player:SteamID()..") has attempted to use gm_save command to potentially crash the server!\n")
end)

concommand.Add("gmod_admin_cleanup", function(player, command, arguments)
	ErrorNoHalt("[Catwork] "..player:Name().." ("..player:SteamID()..") has attempted to use gmod_admin_cleanup command to wipe all props from the server!\n")
end)

concommand.Add("cat_add_bots", function(player, command, arguments)
	if (!IsValid(player)) then
		print("[Catwork] Spawning 63 bots for debug purposes...")

		timer.Create("BOTS", 0.3, 63, function()
			RunConsoleCommand("bot")
		end)
	end
end)

local entityMeta = FindMetaTable("Entity")
local playerMeta = FindMetaTable("Player")

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

function playerMeta:SteamID64()
	local value = self:ClockworkSteamID64()

	if (value == nil) then
		print("[Catwork] Temporary fix for SteamID64 has been used.")
		return ""
	else
		return value
	end
end

-- A function to override player's name returned by player:Name().
function playerMeta:OverrideName(name)
	if (name and name != "") then
		self:SetNetVar("NameOverride", name)
	else
		self:SetNetVar("NameOverride", nil)
	end
end

-- A function to get a player's name.
function playerMeta:Name(bRealName)
	return (!bRealName and self:GetNetVar("NameOverride", nil)) or self:QueryCharacter("Name", self:SteamName())
end

function playerMeta:PlayStepSound(volume)
	local curTime = CurTime()

	self.nextFootstep = self.nextFootstep or curTime

	if (self.nextFootstep <= curTime) then
		self:ClockworkPlayStepSound(volume)

		self.nextFootstep = curTime + 0.25 -- min delay
	end
end

-- A function to make a player fire bullets.
function entityMeta:FireBullets(bulletInfo)
	if (self:IsPlayer()) then
		hook.Run("PlayerAdjustBulletInfo", self, bulletInfo)
	end

	hook.Run("EntityFireBullets", self, bulletInfo)
	return self:ClockworkFireBullets(bulletInfo)
end

-- A function to get whether a player is alive.
function playerMeta:Alive()
	if (!self.fakingDeath) then
		return self:ClockworkAlive()
	else
		return false
	end
end

-- A function to set whether a player is faking death.
function playerMeta:SetFakingDeath(fakingDeath, killSilent)
	self.fakingDeath = fakingDeath

	if (!fakingDeath and killSilent) then
		self:KillSilent()
	end
end

-- A function to save a player's character.
function playerMeta:SaveCharacter()
	cw.player:SaveCharacter(self)
end

-- A function to give a player an item weapon.
function playerMeta:GiveItemWeapon(itemTable)
	cw.player:GiveItemWeapon(self, itemTable)
end

-- A function to give a weapon to a player.
function playerMeta:Give(class, itemTable, bForceReturn)
	local iTeamIndex = self:Team()

	if (!hook.Run("PlayerCanBeGivenWeapon", self, class, itemTable)) then
		return
	end

	if (self:IsRagdolled() and !bForceReturn) then
		local ragdollWeapons = self:GetRagdollWeapons()
		local spawnWeapon = cw.player:GetSpawnWeapon(self, class)
		local bCanHolster = (itemTable and hook.Run("PlayerCanHolsterWeapon", self, itemTable, true, true))

		if (!spawnWeapon) then iTeamIndex = nil; end

		for k, v in pairs(ragdollWeapons) do
			if (v.weaponData["class"] == class
			and v.weaponData["itemTable"] == itemTable) then
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
			teamIndex = iTeamIndex,
		}
	elseif (!self:HasWeapon(class)) then
		self.cwForceGive = true
			self:ClockworkGive(class)
		self.cwForceGive = nil

		local weapon = self:GetWeapon(class)

		if (IsValid(weapon) and itemTable) then
			netstream.Start(self, "WeaponItemData", {
				definition = item.GetDefinition(itemTable, true),
				weapon = weapon:EntIndex()
			})

			weapon:SetNWString(
				"ItemID", tostring(itemTable.itemID)
			)
			weapon.cwItemTable = itemTable

			if (itemTable.OnWeaponGiven) then
				itemTable:OnWeaponGiven(self, weapon)
			end
		end
	end

	hook.Run("PlayerGivenWeapon", self, class, itemTable)
end

-- A function to get a player's data.
function playerMeta:GetData(key, default)
	if (self.cwData and self.cwData[key] != nil) then
		return self.cwData[key]
	else
		return default
	end
end

-- A function to get a player's playback rate.
function playerMeta:GetPlaybackRate()
	return self.cwPlaybackRate or 1
end

-- A function to set an entity's skin.
function entityMeta:SetSkin(skin)
	self:ClockworkSetSkin(skin)

	if (self:IsPlayer()) then
		hook.Run("PlayerSkinChanged", self, skin)

		if (self:IsRagdolled()) then
			self:GetRagdollTable().skin = skin
		end
	end
end

-- A function to set an entity's model.
function entityMeta:SetModel(model)
	self:ClockworkSetModel(model)

	if (self:IsPlayer()) then
		hook.Run("PlayerModelChanged", self, model)

		if (self:IsRagdolled()) then
			self:GetRagdollTable().model = model
		end
	end
end

-- A function to get an entity's owner key.
function entityMeta:GetOwnerKey()
	return self.cwOwnerKey
end

-- A function to set an entity's owner key.
function entityMeta:SetOwnerKey(key)
	self.cwOwnerKey = key
end

-- A function to get whether an entity is a map entity.
function entityMeta:IsMapEntity()
	return cw.entity:IsMapEntity(self)
end

-- A function to get an entity's start position.
function entityMeta:GetStartPosition()
	return cw.entity:GetStartPosition(self)
end

-- A function to emit a hit sound for an entity.
function entityMeta:EmitHitSound(sound)
	self:EmitSound("weapons/crossbow/hitbod2.wav",
		math.random(100, 150), math.random(150, 170)
	)

	timer.Simple(FrameTime() * 8, function()
		if (IsValid(self)) then
			self:EmitSound(sound)
		end
	end)
end

-- A function to set an entity's material.
function entityMeta:SetMaterial(material)
	if (self:IsPlayer() and self:IsRagdolled()) then
		self:GetRagdollEntity():SetMaterial(material)
	end

	self:ClockworkSetMaterial(material)
end

-- A function to set an entity's color.
function entityMeta:SetColor(color)
	if (self:IsPlayer() and self:IsRagdolled()) then
		self:GetRagdollEntity():SetColor(color)
	end

	self:ClockworkSetColor(color)
end

-- A function to get a player's information table.
function playerMeta:GetInfoTable()
	return self.cwInfoTable
end

-- A function to set a player's armor.
function playerMeta:SetArmor(armor)
	if (!armor) then
		return
	end

	local oldArmor = self:Armor()
		self:ClockworkSetArmor(armor)
	hook.Run("PlayerArmorSet", self, armor, oldArmor)
end

-- A function to set a player's health.
function playerMeta:SetHealth(health)
	if (!health) then
		return
	end

	local oldHealth = self:Health()
		self:ClockworkSetHealth(health)
	hook.Run("PlayerHealthSet", self, health, oldHealth)
end

-- A function to get whether a player is noclipping.
function playerMeta:IsNoClipping()
	return cw.player:IsNoClipping(self)
end

-- A function to get whether a player is running.
function playerMeta:IsRunning()
	if (self:Alive() and !self:IsRagdolled() and !self:InVehicle()
	and !self:Crouching() and self:KeyDown(IN_SPEED)) then
		if (self:GetVelocity():Length() >= self:GetWalkSpeed()
		or bNoWalkSpeed) then
			return true
		end
	end

	return false
end

-- A function to get whether a player is jumping.
function playerMeta:IsJumping()
	if (self:Alive() and !self:IsRagdolled() and !self:InVehicle()
	and !self:Crouching() and self.m_bJumping) then
		return true
	end

	return false
end


-- A function to strip a weapon from a player.
function playerMeta:StripWeapon(weaponClass)
	if (self:IsRagdolled()) then
		local ragdollWeapons = self:GetRagdollWeapons()

		for k, v in pairs(ragdollWeapons) do
			if (v.weaponData["class"] == weaponClass) then
				weapons[k] = nil
			end
		end
	else
		self:ClockworkStripWeapon(weaponClass)
	end
end

-- A function to get the player's target run speed.
function playerMeta:GetTargetRunSpeed()
	return self.cwTargetRunSpeed or self:GetRunSpeed()
end

-- A function to handle a player's attribute progress.
function playerMeta:HandleAttributeProgress(curTime)
	if (self.cwAttrProgressTime and curTime >= self.cwAttrProgressTime) then
		self.cwAttrProgressTime = curTime + 30

		for k, v in pairs(self.cwAttrProgress) do
			local attributeTable = cw.attribute:FindByID(k)

			if (attributeTable) then
				netstream.Start(self, "AttributeProgress", {
					index = attributeTable.index, amount = v
				})
			end
		end

		if (self.cwAttrProgress) then
			self.cwAttrProgress = {}
		end
	end
end

-- A function to handle a player's attribute boosts.
function playerMeta:HandleAttributeBoosts(curTime)
	for k, v in pairs(self.cwAttrBoosts) do
		for k2, v2 in pairs(v) do
			if (v2.duration and v2.endTime) then
				if (curTime > v2.endTime) then
					self:BoostAttribute(k2, k, false)
				else
					local timeLeft = v2.endTime - curTime

					if (timeLeft >= 0) then
						if (v2.default < 0) then
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

-- A function to strip a player's weapons.
function playerMeta:StripWeapons(ragdollForce)
	if (self:IsRagdolled() and !ragdollForce) then
		self:GetRagdollTable().weapons = {}
	else
		self:ClockworkStripWeapons()
	end
end

-- A function to enable God for a player.
function playerMeta:GodEnable()
	self.godMode = true; self:ClockworkGodEnable()
end

-- A function to disable God for a player.
function playerMeta:GodDisable()
	self.godMode = nil; self:ClockworkGodDisable()
end

-- A function to get whether a player has God mode enabled.
function playerMeta:IsInGodMode()
	return self.godMode
end

do
	local meleeWeapons = {
		["weapon_hl2axe"] = 10,
		["weapon_hl2bottle"] = 5,
		["weapon_hl2brokenbottle"] = 5,
		["weapon_hl2hook"] = 15,
		["weapon_knife"] = 5,
		["weapon_hl2pan"] = 10,
		["weapon_hl2pickaxe"] = 15,
		["weapon_hl2pipe"] = 10,
		["weapon_hl2pot"] = 10,
		["weapon_hl2shovel"] = 15,
	}

	-- A function to update whether a player's weapon has fired.
	function playerMeta:UpdateWeaponFired()
		local activeWeapon = self:GetActiveWeapon()

		if (IsValid(activeWeapon)) then
			local weaponClass = activeWeapon:GetClass()

			if (self.cwClipOneInfo.weapon == activeWeapon) then
				local clipOne = activeWeapon:Clip1()

				if (clipOne < self.cwClipOneInfo.ammo) then
					self.cwClipOneInfo.ammo = clipOne
					hook.Run("PlayerFireWeapon", self, activeWeapon, CLIP_ONE, activeWeapon:GetPrimaryAmmoType())
				end
			else
				self.cwClipOneInfo.weapon = activeWeapon
				self.cwClipOneInfo.ammo = activeWeapon:Clip1()
			end

			if (self.cwClipTwoInfo.weapon == activeWeapon) then
				local clipTwo = activeWeapon:Clip2()

				if (clipTwo < self.cwClipTwoInfo.ammo) then
					self.cwClipTwoInfo.ammo = clipTwo
					hook.Run("PlayerFireWeapon", self, activeWeapon, CLIP_TWO, activeWeapon:GetSecondaryAmmoType())
				end
			else
				self.cwClipTwoInfo.weapon = activeWeapon
				self.cwClipTwoInfo.ammo = activeWeapon:Clip2()
			end

			if (meleeWeapons[weaponClass] and player.GetCharacterData and player.SetCharacterData) then
				player:SetCharacterData("Stamina", math.Clamp(player:GetCharacterData("Stamina", 0) - meleeWeapons[weaponClass]), 0, 100 - player:GetCharacterData("Fatigue", 0))
			end
		end
	end
end

-- A function to get a player's water level.
function playerMeta:WaterLevel()
	if (self:IsRagdolled()) then
		return self:GetRagdollEntity():WaterLevel()
	else
		return self:ClockworkWaterLevel()
	end
end

-- A function to get whether a player is on fire.
function playerMeta:IsOnFire()
	if (self:IsRagdolled()) then
		return self:GetRagdollEntity():IsOnFire()
	else
		return self:ClockworkIsOnFire()
	end
end

-- A function to extinguish a player.
function playerMeta:Extinguish()
	if (self:IsRagdolled()) then
		return self:GetRagdollEntity():Extinguish()
	else
		return self:ClockworkExtinguish()
	end
end

-- A function to get whether a player is using their hands.
function playerMeta:IsUsingHands()
	return cw.player:GetWeaponClass(self) == "cw_hands"
end

-- A function to get whether a player is using their hands.
function playerMeta:IsUsingKeys()
	return cw.player:GetWeaponClass(self) == "cw_keys"
end

-- A function to get a player's wages.
function playerMeta:GetWages()
	return cw.player:GetWages(self)
end

-- A function to get a player's community ID.
function playerMeta:CommunityID()
	local x, y, z = string.match(self:SteamID(), "STEAM_(%d+):(%d+):(%d+)")

	if (x and y and z) then
		return (z * 2) + STEAM_COMMUNITY_ID + y
	else
		return self:SteamID()
	end
end

-- A function to get whether a player is ragdolled.
function playerMeta:IsRagdolled(exception, entityless)
	return cw.player:IsRagdolled(self, exception, entityless)
end

-- A function to get whether a player is kicked.
function playerMeta:IsKicked()
	return self.isKicked
end

-- A function to get whether a player has spawned.
function playerMeta:HasSpawned()
	return self.cwHasSpawned
end

-- A function to kick a player.
function playerMeta:Kick(reason)
	if (!self:IsKicked()) then
		timer.Simple(FrameTime() * 0.5, function()
			local isKicked = self:IsKicked()

			if (IsValid(self) and isKicked) then
				if (self:HasSpawned()) then
					game.ConsoleCommand("kickid "..self:UserID().." "..isKicked.."\n")
				else
					self.isKicked = nil
					self:Kick(isKicked)
				end
			end
		end)
	end

	if (!reason) then
		self.isKicked = "You have been kicked."
	else
		self.isKicked = reason
	end
end

-- A function to ban a player.
function playerMeta:Ban(duration, reason)
	cw.bans:Add(self:SteamID(), duration * 60, reason)
end

-- A function to get a player's cash.
function playerMeta:GetCash()
	if (config.GetVal("cash_enabled")) then
		return self:QueryCharacter("Cash")
	else
		return 0
	end
end

-- A function to get a character's flags.
function playerMeta:GetFlags() return self:QueryCharacter("Flags"); end

-- A function to get a player's faction.
function playerMeta:GetFaction() return self:QueryCharacter("Faction"); end

-- A function to get a player's gender.
function playerMeta:GetGender() return self:QueryCharacter("Gender"); end

-- A function to get a player's inventory.
function playerMeta:GetInventory() return self:QueryCharacter("Inventory"); end

-- A function to get a player's attributes.
function playerMeta:GetAttributes() return self:QueryCharacter("Attributes"); end

-- A function to get a player's saved ammo.
function playerMeta:GetSavedAmmo() return self:QueryCharacter("Ammo"); end

-- A function to get a player's default model.
function playerMeta:GetDefaultModel() return self:QueryCharacter("Model"); end

-- A function to get a player's character ID.
function playerMeta:GetCharacterID() return self:QueryCharacter("CharacterID"); end

-- A function to get the time when a player's character was created.
function playerMeta:GetTimeCreated() return self:QueryCharacter("TimeCreated"); end

-- A function to get a player's character key.
function playerMeta:GetCharacterKey() return self:QueryCharacter("Key"); end

-- A function to get a player's recognised names.
function playerMeta:GetRecognisedNames()
	return self:QueryCharacter("RecognisedNames")
end

-- A function to get a player's character table.
function playerMeta:GetCharacter() return cw.player:GetCharacter(self); end

-- A function to get a player's storage table.
function playerMeta:GetStorageTable() return cw.storage:GetTable(self); end

-- A function to get a player's ragdoll table.
function playerMeta:GetRagdollTable() return cw.player:GetRagdollTable(self); end

-- A function to get a player's ragdoll state.
function playerMeta:GetRagdollState() return cw.player:GetRagdollState(self); end

-- A function to get a player's storage entity.
function playerMeta:GetStorageEntity() return cw.storage:GetEntity(self); end

-- A function to get a player's ragdoll entity.
function playerMeta:GetRagdollEntity() return cw.player:GetRagdollEntity(self); end

-- A function to get a player's ragdoll weapons.
function playerMeta:GetRagdollWeapons()
	return self:GetRagdollTable().weapons or {}
end

-- A function to get whether a player's ragdoll has a weapon.
function playerMeta:RagdollHasWeapon(weaponClass)
	local ragdollWeapons = self:GetRagdollWeapons()

	if (ragdollWeapons) then
		for k, v in pairs(ragdollWeapons) do
			if (v.weaponData["class"] == weaponClass) then
				return true
			end
		end
	end
end

-- A function to set a player's maximum armor.
function playerMeta:SetMaxArmor(armor)
	self:SetNetVar("MaxAP", armor)
end

-- A function to get a player's maximum armor.
function playerMeta:GetMaxArmor(armor)
	local maxArmor = self:GetNetVar("MaxAP") or 100

	if (maxArmor > 0) then
		return maxArmor
	else
		return 100
	end
end

-- A function to set a player's maximum health.
function playerMeta:SetMaxHealth(health)
	self:SetNetVar("MaxHP", health)
end

-- A function to get a player's maximum health.
function playerMeta:GetMaxHealth(health)
	local maxHealth = self:GetNetVar("MaxHP") or 100

	if (maxHealth > 0) then
		return maxHealth
	else
		return 100
	end
end

-- A function to get whether a player is viewing the starter hints.
function playerMeta:IsViewingStarterHints()
	return self.cwViewStartHints
end

-- A function to get a player's last hit group.
function playerMeta:LastHitGroup()
	return self.cwLastHitGroup or self:ClockworkLastHitGroup()
end

-- A function to get whether an entity is being held.
function entityMeta:IsBeingHeld()
	if (IsValid(self)) then
		return hook.Run("GetEntityBeingHeld", self)
	end
end

-- A function to run a command on a player.
function playerMeta:RunCommand(...)
	netstream.Start(self, "RunCommand", {...})
end

-- A function to run a Clockwork command on a player.
function playerMeta:RunClockworkCmd(command, ...)
	cw.player:RunClockworkCommand(self, command, ...)
end

-- A function to get a player's wages name.
function playerMeta:GetWagesName()
	return cw.player:GetWagesName(self)
end

-- A function to create a player'a animation stop delay.
function playerMeta:CreateAnimationStopDelay(delay)
	timer.Create("ForcedAnim"..self:UniqueID(), delay, 1, function()
		if (IsValid(self)) then
			local forcedAnimation = self:GetForcedAnimation()

			if (forcedAnimation) then
				self:SetForcedAnimation(false)
			end
		end
	end)
end

-- A function to set a player's forced animation.
function playerMeta:SetForcedAnimation(animation, delay, OnAnimate, OnFinish)
	local forcedAnimation = self:GetForcedAnimation()
	local sequence = nil

	if (!animation) then
		self:SetNetVar("ForceAnim", 0)
		self.cwForcedAnimation = nil

		if (forcedAnimation and forcedAnimation.OnFinish) then
			forcedAnimation.OnFinish(self)
		end

		return false
	end

	local bIsPermanent = (!delay or delay == 0)
	local bShouldPlay = (!forcedAnimation or forcedAnimation.delay != 0)

	if (bShouldPlay) then
		if (type(animation) == "string") then
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

		if (bIsPermanent) then
			timer.Remove(
				"ForcedAnim"..self:UniqueID()
			)
		else
			self:CreateAnimationStopDelay(delay)
		end

		self:SetNetVar("ForceAnim", sequence)

		if (forcedAnimation and forcedAnimation.OnFinish) then
			forcedAnimation.OnFinish(self)
		end

		return true
	end
end

-- A function to set whether a player's config has initialized.
function playerMeta:SetConfigInitialized(initialized)
	self.cwConfigInitialized = initialized
end

-- A function to get whether a player's config has initialized.
function playerMeta:HasConfigInitialized()
	return self.cwConfigInitialized
end

-- A function to get a player's forced animation.
function playerMeta:GetForcedAnimation()
	return self.cwForcedAnimation
end

-- A function to get a player's item entity.
function playerMeta:GetItemEntity()
	if (IsValid(self.itemEntity)) then
		return self.itemEntity
	end
end

-- A function to set a player's item entity.
function playerMeta:SetItemEntity(entity)
	self.itemEntity = entity
end

-- A function to make a player fake pickup an entity.
function playerMeta:FakePickup(entity)
	local entityPosition = entity:GetPos()

	if (entity:IsPlayer()) then
		entityPosition = entity:GetShootPos()
	end

	local shootPosition = self:GetShootPos()
	local feetDistance = self:GetPos():Distance(entityPosition)
	local armsDistance = shootPosition:Distance(entityPosition)

	if (feetDistance < armsDistance) then
		self:SetForcedAnimation("pickup", 1.2)
	else
		self:SetForcedAnimation("gunrack", 1.2)
	end
end

-- A function to set the player's Clockwork user group.
function playerMeta:SetClockworkUserGroup(userGroup)
	if (self:GetClockworkUserGroup() != userGroup) then
		self.cwUserGroup = userGroup
		self:SetUserGroup(userGroup)
		self:SaveCharacter()

		hook.Run("OnPlayerUserGroupSet", self, userGroup)
	end
end

-- A function to get the player's Clockwork user group.
function playerMeta:GetClockworkUserGroup()
	return self.cwUserGroup
end

-- A function to get a player's items by ID.
function playerMeta:GetItemsByID(uniqueID)
	return cw.inventory:GetItemsByID(
		self:GetInventory(), uniqueID
	)
end

-- A function to find a player's items by name.
function playerMeta:FindItemsByName(uniqueID, name)
	return cw.inventory:FindItemsByName(
		self:GetInventory(), uniqueID, name
	)
end

-- A function to get the maximum weight a player can carry.
function playerMeta:GetMaxWeight()
	local itemsList = cw.inventory:GetAsItemsList(self:GetInventory())
	local weight = self:GetNetVar("InvWeight") or 8

	for k, v in pairs(itemsList) do
		local addInvWeight = v.addInvSpace
		if (addInvWeight) then
			weight = weight + addInvWeight
		end
	end

	hook.Run("PlayerAdjustMaxWeight", self, weight)

	return weight
end

-- A function to get the maximum space a player can carry.
function playerMeta:GetMaxSpace()
	local itemsList = cw.inventory:GetAsItemsList(self:GetInventory())
	local space = self:GetNetVar("InvSpace") or 10

	for k, v in pairs(itemsList) do
		local addInvSpace = v.addInvVolume
		if (addInvSpace) then
			space = space + addInvSpace
		end
	end

	hook.Run("PlayerAdjustMaxSpace", player, space)

	return space
end

-- A function to get whether a player can hold a weight.
function playerMeta:CanHoldWeight(weight)
	local inventoryWeight = cw.inventory:CalculateWeight(
		self:GetInventory()
	)

	if (inventoryWeight + weight > self:GetMaxWeight()) then
		return false
	else
		return true
	end
end

-- A function to get whether a player can hold a weight.
function playerMeta:CanHoldSpace(space)
	if (!cw.inventory:UseSpaceSystem()) then
		return true
	end

	local inventorySpace = cw.inventory:CalculateSpace(
		self:GetInventory()
	)

	if (inventorySpace + space > self:GetMaxSpace()) then
		return false
	else
		return true
	end
end

-- A function to get a player's inventory weight.
function playerMeta:GetInventoryWeight()
	return cw.inventory:CalculateWeight(self:GetInventory())
end

-- A function to get a player's inventory weight.
function playerMeta:GetInventorySpace()
	return cw.inventory:CalculateSpace(self:GetInventory())
end

-- A function to get whether a player has an item by ID.
function playerMeta:HasItemByID(uniqueID)
	return cw.inventory:HasItemByID(
		self:GetInventory(), uniqueID
	)
end

-- A function to count how many items a player has by ID.
function playerMeta:GetItemCountByID(uniqueID)
	return cw.inventory:GetItemCountByID(
		self:GetInventory(), uniqueID
	)
end

-- A function to get whether a player has a certain amount of items by ID.
function playerMeta:HasItemCountByID(uniqueID, amount)
	return cw.inventory:HasItemCountByID(
		self:GetInventory(), uniqueID, amount
	)
end

-- A function to find a player's item by ID.
function playerMeta:FindItemByID(uniqueID, itemID)
	return cw.inventory:FindItemByID(
		self:GetInventory(), uniqueID, itemID
	)
end

-- A function to get whether a player has an item as a weapon.
function playerMeta:HasItemAsWeapon(itemTable)
	for k, v in pairs(self:GetWeapons()) do
		local weaponItemTable = item.GetByWeapon(v)
		if (itemTable:IsTheSameAs(weaponItemTable)) then
			return true
		end
	end

	return false
end

-- A function to find a player's weapon item by ID.
function playerMeta:FindWeaponItemByID(uniqueID, itemID)
	for k, v in pairs(self:GetWeapons()) do
		local weaponItemTable = item.GetByWeapon(v)
		if (weaponItemTable and weaponItemTable.uniqueID == uniqueID
		and weaponItemTable.itemID == itemID) then
			return weaponItemTable
		end
	end
end

-- A function to get whether a player has an item instance.
function playerMeta:HasItemInstance(itemTable)
	return cw.inventory:HasItemInstance(
		self:GetInventory(), itemTable
	)
end

-- A function to get a player's item instance.
function playerMeta:GetItemInstance(uniqueID, itemID)
	return cw.inventory:FindItemByID(
		self:GetInventory(), uniqueID, itemID
	)
end

-- A function to take a player's item by ID.
function playerMeta:TakeItemByID(uniqueID, itemID)
	local itemTable = self:GetItemInstance(uniqueID, itemID)

	if (itemTable) then
		return self:TakeItem(itemTable)
	else
		return false
	end
end

-- A function to get a player's attribute boosts.
function playerMeta:GetAttributeBoosts()
	return self.cwAttrBoosts
end

-- A function to rebuild a player's inventory.
function playerMeta:RebuildInventory()
	cw.inventory:Rebuild(self)
end

-- A function to give an item to a player.
function playerMeta:GiveItem(itemTable, bForce)
	if (isstring(itemTable)) then
		itemTable = item.CreateInstance(itemTable)
	end

	if (!itemTable or !itemTable:IsInstance()) then
		debug.Trace()
		return false, L"#GiveInvalidItem"
	end

	local inventory = self:GetInventory()

	if ((self:CanHoldWeight(itemTable.weight)
	and self:CanHoldSpace(itemTable.space)) or bForce) then
		if (itemTable.OnGiveToPlayer) then
			itemTable:OnGiveToPlayer(self)
		end

		cw.core:PrintLog(LOGTYPE_GENERIC, self:Name().." has gained a "..itemTable.name.." "..itemTable.itemID..".")

		cw.inventory:AddInstance(inventory, itemTable)
			netstream.Start(self, "InvGive", item.GetDefinition(itemTable, true))
		hook.Run("PlayerItemGiven", self, itemTable, bForce)

		cw.inventory:Rebuild(self)

		return itemTable
	else
		return false, L"NoSpace"
	end
end

-- A function to take an item from a player.
function playerMeta:TakeItem(itemTable)
	if (!itemTable or !itemTable:IsInstance()) then
		debug.Trace()
		return false
	end

	local inventory = self:GetInventory()

	if (itemTable.OnTakeFromPlayer) then
		itemTable:OnTakeFromPlayer(self)
	end

	cw.core:PrintLog(LOGTYPE_GENERIC, self:Name().." has lost a "..itemTable.name.." "..itemTable.itemID..".")

	hook.Run("PlayerItemTaken", self, itemTable)
		cw.inventory:RemoveInstance(inventory, itemTable)
	netstream.Start(self, "InvTake", {itemTable.index, itemTable.itemID})

	cw.inventory:Rebuild(self)

	return true
end

-- An easy function to give a table of items to a player.
function playerMeta:GiveItems(itemTables)
	for _, itemTable in pairs(itemTables) do
		self:GiveItem(itemTables)
	end
end

-- An easy function to take a table of items from a player.
function playerMeta:TakeItems(itemTables)
	for _, itemTable in pairs(itemTables) do
		self:TakeItem(itemTable)
	end
end

-- A function to update a player's attribute.
function playerMeta:UpdateAttribute(attribute, amount)
	return cw.attributes:Update(self, attribute, amount)
end

-- A function to progress a player's attribute.
function playerMeta:ProgressAttribute(attribute, amount, gradual)
	return cw.attributes:Progress(self, attribute, amount, gradual)
end

-- A function to boost a player's attribute.
function playerMeta:BoostAttribute(identifier, attribute, amount, duration)
	return cw.attributes:Boost(self, identifier, attribute, amount, duration)
end

-- A function to get whether a boost is active for a player.
function playerMeta:IsBoostActive(identifier, attribute, amount, duration)
	return cw.attributes:IsBoostActive(self, identifier, attribute, amount, duration)
end

-- A function to get a player's characters.
function playerMeta:GetCharacters()
	return self.cwCharacterList
end

-- A function to set a player's run speed.
function playerMeta:SetRunSpeed(speed, bClockwork)
	if (!bClockwork) then self.cwRunSpeed = speed; end
	self:ClockworkSetRunSpeed(speed)
end

-- A function to set a player's walk speed.
function playerMeta:SetWalkSpeed(speed, bClockwork)
	if (!bClockwork) then self.cWalkSpeed = speed; end
	self:ClockworkSetWalkSpeed(speed)
end

-- A function to set a player's jump power.
function playerMeta:SetJumpPower(power, bClockwork)
	if (!bClockwork) then self.cwJumpPower = power; end
	self:ClockworkSetJumpPower(power)
end

-- A function to set a player's crouched walk speed.
function playerMeta:SetCrouchedWalkSpeed(speed, bClockwork)
	if (!bClockwork) then self.cwCrouchedSpeed = speed; end
	self:ClockworkSetCrouchedWalkSpeed(speed)
end

-- A function to get whether a player has initialized.
function playerMeta:HasInitialized()
	return self.cwInitialized
end

-- A function to query a player's character table.
function playerMeta:QueryCharacter(key, default)
	if (self:GetCharacter()) then
		return cw.player:Query(self, key, default)
	else
		return default
	end
end

-- A function to get a player's shared variable.
function playerMeta:GetSharedVar(key, default)
	return self:GetNetVar(key, default)
end

-- A function to set a shared variable for a player.
function playerMeta:SetSharedVar(key, value, sharedTable)
	return self:SetNetVar(key, value)
end

-- A function to get a player's character data.
function playerMeta:GetCharacterData(key, default)
	if (self:GetCharacter()) then
		local data = self:QueryCharacter("Data")

		if (data[key] != nil) then
			return data[key]
		end
	end

	return default
end

-- A function to get a player's time joined.
function playerMeta:TimeJoined()
	return self.cwTimeJoined or os.time()
end

-- A function to get when a player last played.
function playerMeta:LastPlayed()
	return self.cwLastPlayed or os.time()
end

-- A function to get a player's clothes data.
function playerMeta:GetClothesData()
	local clothesData = self:GetCharacterData("Clothes")

	if (type(clothesData) != "table") then
		clothesData = {}
	end

	return clothesData
end

-- A function to get a player's accessory data.
function playerMeta:GetAccessoryData()
	local accessoryData = self:GetCharacterData("Accessories")

	if (type(accessoryData) != "table") then
		accessoryData = {}
	end

	return accessoryData
end

-- A function to remove a player's clothes.
function playerMeta:RemoveClothes(bRemoveItem)
	self:SetClothesData(nil)

	if (bRemoveItem) then
		local clothesItem = self:GetClothesItem()

		if (clothesItem) then
			self:TakeItem(clothesItem)
			return clothesItem
		end
	end
end

-- A function to get the player's clothes item.
function playerMeta:GetClothesItem()
	local clothesData = self:GetClothesData()

	if (type(clothesData) == "table") then
		if (clothesData.itemID != nil and clothesData.uniqueID != nil) then
			return self:FindItemByID(
				clothesData.uniqueID, clothesData.itemID
			)
		end
	end
end

-- A function to get whether a player is wearing clothes.
function playerMeta:IsWearingClothes()
	return (self:GetClothesItem() != nil)
end

-- A function to get whether a player is wearing an item.
function playerMeta:IsWearingItem(itemTable)
	local clothesItem = self:GetClothesItem()
	return (clothesItem and clothesItem:IsTheSameAs(itemTable))
end

-- A function to network the player's clothes data.
function playerMeta:NetworkClothesData()
	local clothesData = self:GetClothesData()

	if (clothesData.uniqueID and clothesData.itemID) then
		self:SetNetVar("Clothes", clothesData.uniqueID.." "..clothesData.itemID)
	else
		self:SetNetVar("Clothes", "")
	end
end

-- A function to set a player's clothes data.
function playerMeta:SetClothesData(itemTable)
	local clothesItem = self:GetClothesItem()

	if (itemTable) then
		local model = cw.class:GetAppropriateModel(self:Team(), self, true)

		if (!model) then
			if (clothesItem and itemTable != clothesItem) then
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

		if (clothesItem) then
			clothesItem:OnChangeClothes(self, false)
		end
	end
end

-- A function to get the entity a player is holding.
function playerMeta:GetHoldingEntity()
	return hook.Run("PlayerGetHoldingEntity", self) or self.cwIsHoldingEnt
end

-- A function to get whether a player's character menu is reset.
function playerMeta:IsCharacterMenuReset()
	return self.cwCharMenuReset
end

-- A function to check if a player can afford an amount.
function playerMeta:CanAfford(amount)
	return cw.player:CanAfford(self, amount)
end

-- A function to get a player's rank within their faction.
function playerMeta:GetFactionRank(character)
	return cw.player:GetFactionRank(self, character)
end

-- A function to set a player's rank within their faction.
function playerMeta:SetFactionRank(rank)
	return cw.player:SetFactionRank(self, rank)
end

-- A function to get a player's global flags.
function playerMeta:GetPlayerFlags()
	return cw.player:GetPlayerFlags(self)
end

playerMeta.GetName = playerMeta.Name
playerMeta.Nick = playerMeta.Name

concommand.Add("cwStatus", function(player, command, arguments)
	local plyTable = player.GetAll()

	if (IsValid(player)) then
		if (cw.player:IsAdmin(player)) then
			player:PrintMessage(2, "# User ID | Name | Steam Name | Steam ID | IP Address")

			for k, v in ipairs(plyTable) do
				if (v:HasInitialized()) then
					local status = hook.Run("PlayerCanSeeStatus", player, v)

					if (status) then
						player:PrintMessage(2, status)
					end
				end
			end
		else
			player:PrintMessage(2, "You do not have access to this command, "..player:Name()..".")
		end
	else
		print("# User ID | Name | Steam Name | Steam ID | IP Address")

		for k, v in ipairs(plyTable) do
			if (v:HasInitialized()) then
				print("# "..v:UserID().." | "..v:Name().." | "..v:SteamName().." | "..v:SteamID().." | "..v:IPAddress())
			end
		end
	end
end)

-- The most awfully written function in cw.
-- Allows you to call certain commands from server console.
-- ToDo: Rewrite everything to be shorter
concommand.Add("cwc", function(player, command, arguments)
	-- Yep, it's awfully written, but it's not meant to be edited, so...
	local cmdTable = {
		sg  = "setgroup",
		d   = "demote",
		sc  = "setcash",
		w   = "whitelist",
		uw  = "unwhitelist",
		b   = "ban",
		k   = "kick",
		sn  = "setname",
		sm  = "setmodel",
		r   = "restart",
		gf  = "giveflags",
		tf  = "takeflags"
	}

	--  if called from console
	if (!IsValid(player)) then
		-- PlySetGroup
		if (arguments[1] == cmdTable.sg) then
			local target = _player.Find(arguments[2])
			local userGroup = arguments[3]

			if (userGroup != "superadmin" and userGroup != "admin" and userGroup != "operator") then
				MsgC(Color(255, 100, 0, 255), "The user group must be superadmin, admin or operator!\n")

				return
			end

			if (target) then
				if (!cw.player:IsProtected(target)) then
					print("Console has set "..target:Name().."'s user group to "..userGroup..".")
					cw.player:NotifyAll("Console has set "..target:Name().."'s user group to "..userGroup..".")
						target:SetClockworkUserGroup(userGroup)
					cw.player:LightSpawn(target, true, true)
				else
					MsgC(Color(255, 100, 0, 255), target:Name().." is protected!\n")
				end
			else
				MsgC(Color(255, 100, 0, 255), arguments[2].." is not a valid player!\n")
			end

			return
		-- PlyDemote
		elseif (arguments[1] == cmdTable.d) then
			local target = _player.Find(arguments[2])

			if (target) then
				if (!cw.player:IsProtected(target)) then
					local userGroup = target:GetClockworkUserGroup()

					if (userGroup != "user") then
						print("Console has demoted "..target:Name().." from "..userGroup.." to user.")
						cw.player:NotifyAll("Console has demoted "..target:Name().." from "..userGroup.." to user.")
							target:SetClockworkUserGroup("user")
						cw.player:LightSpawn(target, true, true)
					else
						MsgC(Color(255, 100, 0, 255), "This player is only a user and cannot be demoted!\n")
					end
				else
					MsgC(Color(255, 100, 0, 255), target:Name().." is protected!\n")
				end
			else
				MsgC(Color(255, 100, 0, 255), arguments[2].." is not a valid player!\n")
			end

			return
		-- SetCash
		elseif (arguments[1] == cmdTable.sc) then
			local target = _player.Find(arguments[2])
			local cash = math.floor(tonumber((arguments[3] or 0)))

			if (target) then
				if (cash and cash >= 1) then
					local playerName = "Console"
					local targetName = target:Name()
					local giveCash = cash - target:GetCash()

					cw.player:GiveCash(target, giveCash)

					print("Console has set "..targetName.."'s cash to "..cw.core:FormatCash(cash, nil, true)..".")
					cw.player:Notify(target, "Your cash was set to "..cw.core:FormatCash(cash, nil, true).." by "..playerName..".")
				else
					MsgC(Color(255, 100, 0, 255), "This is not a valid amount!\n")
				end
			else
				MsgC(Color(255, 100, 0, 255), arguments[2].." is not a valid player!\n")
			end

			return
		-- PlyWhitelist
		elseif (arguments[1] == cmdTable.w) then
			local target = _player.Find(arguments[2])

			if (target) then
				local factionTable = faction.FindByID(table.concat(arguments, " ", 3))

				if (factionTable) then
					if (factionTable.whitelist) then
						if (!cw.player:IsWhitelisted(target, factionTable.name)) then
							cw.player:SetWhitelisted(target, factionTable.name, true)
							cw.player:SaveCharacter(target)

							print("Console has added "..target:Name().." to the "..factionTable.name.." whitelist.")
							cw.player:NotifyAll("Console has added "..target:Name().." to the "..factionTable.name.." whitelist.")
						else
							MsgC(Color(255, 100, 0, 255), target:Name().." is already on the "..factionTable.name.." whitelist!\n")
						end
					else
						MsgC(Color(255, 100, 0, 255), factionTable.name.." does not have a whitelist!\n")
					end
				else
					MsgC(Color(255, 100, 0, 255), table.concat(arguments, " ", 3).." is not a valid faction!\n")
				end
			else
				MsgC(Color(255, 100, 0, 255), arguments[2].." is not a valid player!\n")
			end

			return
		-- PlyUnWhitelist
		elseif (arguments[1] == cmdTable.uw) then
			local target = _player.Find(arguments[2])

			if (target) then
				local factionTable = faction.FindByID(table.concat(arguments, " ", 3))

				if (factionTable) then
					if (factionTable.whitelist) then
						if (cw.player:IsWhitelisted(target, factionTable.name)) then
							cw.player:SetWhitelisted(target, factionTable.name, false)
							cw.player:SaveCharacter(target)

							print("Console has removed "..target:Name().." from the "..factionTable.name.." whitelist.")
							cw.player:NotifyAll("Console has removed "..target:Name().." from the "..factionTable.name.." whitelist.")
						else
							MsgC(Color(255, 100, 0, 255), target:Name().." is not on the "..factionTable.name.." whitelist!\n")
						end
					else
						MsgC(Color(255, 100, 0, 255), factionTable.name.." does not have a whitelist!\n")
					end
				else
					MsgC(Color(255, 100, 0, 255), factionTable.name.." is not a valid faction!\n")
				end
			else
				MsgC(Color(255, 100, 0, 255), arguments[2].." is not a valid player!\n")
			end

			return
		-- PlyBan
		elseif (arguments[1] == cmdTable.b) then
			local schemaFolder = cw.core:GetSchemaFolder()
			local duration = tonumber(arguments[3])
			local reason = table.concat(arguments, " ", 4)

			if (!reason or reason == "") then
				reason = nil
			end

			if (!cw.player:IsProtected(arguments[2])) then
				if (duration) then
					cw.bans:Add(arguments[2], duration * 60, reason, function(steamName, duration, reason)
						if (IsValid(player)) then
							if (steamName) then
								if (duration > 0) then
									local hours = math.Round(duration / 3600)

									if (hours >= 1) then
										print("Console has banned '"..steamName.."' for "..hours.." hour(s) ("..reason..").")
										cw.player:NotifyAll("Console has banned '"..steamName.."' for "..hours.." hour(s) ("..reason..").")
									else
										print("Console has banned '"..steamName.."' for "..math.Round(duration / 60).." minute(s) ("..reason..").")
										cw.player:NotifyAll("Console has banned '"..steamName.."' for "..math.Round(duration / 60).." minute(s) ("..reason..").")
									end
								else
									print("Console has banned '"..steamName.."' permanently ("..reason..").")
									cw.player:NotifyAll("Console has banned '"..steamName.."' permanently ("..reason..").")
								end
							else
								MsgC(Color(255, 100, 0, 255), "This is not a valid identifier!\n")
							end
						end
					end)
				else
					MsgC(Color(255, 100, 0, 255), "This is not a valid duration!\n")
				end
			else
				local target = _player.Find(arguments[2])

				if (target) then
					MsgC(Color(255, 100, 0, 255), target:Name().." is protected!\n")
				else
					MsgC(Color(255, 100, 0, 255), "This player is protected!\n")
				end
			end

			return
		-- PlyKick
		elseif (arguments[1] == cmdTable.k) then
			local target = _player.Find(arguments[2])
			local reason = table.concat(arguments, " ", 3)

			if (!reason or reason == "") then
				reason = "N/A"
			end

			if (target) then
				if (!cw.player:IsProtected(arguments[2])) then
					print("Console has kicked '"..target:Name().."' ("..reason..").")
					cw.player:NotifyAll("Console has kicked '"..target:Name().."' ("..reason..").")
						target:Kick(reason)
					target.kicked = true
				else
					MsgC(Color(255, 100, 0, 255), target:Name().." is protected!\n")
				end
			else
				MsgC(Color(255, 100, 0, 255), arguments[1].." is not a valid player!\n")
			end

			return
		-- CharSetName
		elseif (arguments[1] == cmdTable.sn) then
			local target = _player.Find(arguments[2])

			if (target) then
				if (arguments[3] == "nil") then
					MsgC(Color(255, 100, 0, 255), "You have to specify the name as the last argument, it also has to be 'quoted'.\n")

					return
				else
					local name = table.concat(arguments, " ", 3)

					print("Console has set "..target:Name().."'s name to "..name..".")
					cw.player:NotifyAll("Console has set "..target:Name().."'s name to "..name..".")

					cw.player:SetName(target, name)
				end
			else
				MsgC(Color(255, 100, 0, 255), arguments[2].." is not a valid character!\n")
			end

			return
		-- CharSetModel
		elseif (arguments[1] == cmdTable.sm) then
			local target = _player.Find(arguments[2])

			if (target) then
				local model = table.concat(arguments, " ", 3)

				target:SetCharacterData("Model", model, true)
				target:SetModel(model)

				print("Console has set "..target:Name().."'s model to "..model..".")
				cw.player:NotifyAll("Console has set "..target:Name().."'s model to "..model..".")
			else
				MsgC(Color(255, 100, 0, 255), arguments[2].." is not a valid character!\n")
			end

			return
		-- MapRestart
		elseif (arguments[1] == cmdTable.r) then
			local delay = tonumber(arguments[2]) or 10

			if (type(arguments[2]) == "number") then
				delay = arguments[2]
			end

			print("Console is restarting the map in "..delay.." seconds!")
			cw.player:NotifyAll("Console is restarting the map in "..delay.." seconds!")

			timer.Simple(delay, function()
				RunConsoleCommand("changelevel", game.GetMap())
			end)

			return
		-- GiveFlags
		elseif (arguments[1] == cmdTable.gf) then
			local target = _player.Find(arguments[2])

			if (target) then
				if (string.find(arguments[3], "a") or string.find(arguments[3], "s") or string.find(arguments[3], "o")) then
					MsgC(Color(255, 100, 0, 255), "You cannot give 'o', 'a' or 's' flags!\n")

					return
				end

				if (!arguments[3]) then print("You haven't entered any flags!"); return end

				cw.player:GiveFlags(target, arguments[3])

				print("Console gave "..target:Name().." '"..arguments[3].."' flags.")
				cw.player:NotifyAll("Console gave "..target:Name().." '"..arguments[3].."' flags.")
			else
				MsgC(Color(255, 100, 0, 255), arguments[2].." is not a valid character!\n")
			end

			return
		-- TakeFlags
		elseif (arguments[1] == cmdTable.tf) then
			local target = _player.Find(arguments[2])

			if (target) then
				if (string.find(arguments[3], "a") or string.find(arguments[3], "s") or string.find(arguments[3], "o")) then
					cw.player:Notify(player, "You cannot take 'o', 'a' or 's' flags!")

					return
				end

				if (!arguments[3]) then print("You haven't entered any flags!"); return end

				cw.player:TakeFlags(target, arguments[3])

				print("Console took '"..arguments[3].."' flags from "..target:Name()..".")
				cw.player:NotifyAll("Console took '"..arguments[3].."' flags from "..target:Name()..".")
			else
				MsgC(Color(255, 100, 0, 255), arguments[2].." is not a valid character!\n")
			end

			return
		-- Everything else
		else
			MsgC(Color(255, 100, 0, 255), "'"..arguments[1].. "' command not found!\n")
		end
	-- if not too bad, players are not allowed to use this swag
	else
		cw.player.Notify(player, "You are not allowed to use server-side commands!")
	end
end)

concommand.Add("cwDeathCode", function(player, command, arguments)
	if (player.cwDeathCodeIdx) then
		if (arguments and tonumber(arguments[1]) == player.cwDeathCodeIdx) then
			player.cwDeathCodeAuth = true
		end
	end
end)

--[[ Accessories --]]
local playerMeta = FindMetaTable("Player")

function playerMeta:NetworkAccessories()
	local accessoryData = self:GetAccessoryData()

	netstream.Start(self, "AllAccessories", accessoryData)
end

function playerMeta:RemoveAccessory(itemTable)
	if (!self:IsWearingAccessory(itemTable)) then return end

	local accessoryData = self:GetAccessoryData()
	local uniqueID = itemTable.uniqueID
	local itemID = itemTable.itemID

	accessoryData[itemID] = nil
		netstream.Start(
		self, "RemoveAccessory", {itemID = itemID}
	)

	if (itemTable.OnWearAccessory) then
		itemTable:OnWearAccessory(self, false)
	end
end

function playerMeta:HasAccessory(uniqueID)
	local accessoryData = self:GetAccessoryData()

	for k, v in pairs(accessoryData) do
		if (string.lower(v) == string.lower(uniqueID)) then
			return true
		end
	end

	return false
end

function playerMeta:IsWearingAccessory(itemTable)
	local accessoryData = self:GetAccessoryData()
	local itemID = itemTable.itemID

	if (accessoryData[itemID]) then
		return true
	else
		return false
	end
end

function playerMeta:WearAccessory(itemTable)
	if (self:IsWearingAccessory(itemTable)) then return end

	local accessoryData = self:GetAccessoryData()
	local uniqueID = itemTable.uniqueID
	local itemID = itemTable.itemID

	accessoryData[itemID] = itemTable.uniqueID
	netstream.Start(
		self, "AddAccessory", {itemID = itemID, uniqueID = uniqueID}
	)

	if (itemTable.OnWearAccessory) then
		itemTable:OnWearAccessory(self, true)
	end
end

-- A function to set a player's character data.
function playerMeta:SetCharacterData(key, value, bFromBase)
	local character = self:GetCharacter()

	if (!character) then return end

	if (bFromBase) then
		key = cw.core:SetCamelCase(key, true)

		if (character[key] != nil) then
			character[key] = value
		end
	else
		local oldValue = character.data[key]
		character.data[key] = value

		if (!netvars.AreEqual(value, oldValue)) then
			cw.player:UpdateCharacterData(self, key, value)

			plugin.Call("PlayerCharacterDataChanged", self, key, oldValue, value)
		end
	end
end

-- A function to set a player's data.
function playerMeta:SetData(key, value)
	if (self.cwData) then
		local oldValue = self.cwData[key]
		self.cwData[key] = value

		if (value != oldValue) then
			cw.player:UpdatePlayerData(self, key, value)

			plugin.Call("PlayerDataChanged", self, key, oldValue, value)
		end
	end
end

local phrases = {
	"Sending your private info to kurozael",
	"Hacking your bank accounts",
	"Stealing your cat",
	"Installing Windows 10 spyware",
	"Sending your private info to Microsoft",
	"Do not wait",
	"Using your server to DDoS LemonPunch",
	"Using your server to mine bitcoins",
	"Crashing your server",
	"Adding extra 7 seconds to boot times",
	"Sending a DMCA notice to Alex Grist",
	"Starting a lawsuit against you for using Catwork",
	"Installing backdoors",
	"Giving kurozael owner",
	"Banning your whole playerbase",
	"You are not authorized by CloudAuthX to use Catwork",
	"Making kittens cry",
	"Installing an update that breaks everything",
	"Loading your CPU core to 100%",
	"Crying about that extra space in the serial file",
	"Attempting to explode your server for using Catwork",
	"CloudAuthX is not installed",
	"Downloading porn",
	"Opening kuro's favorite PH category (gay porn)",
	"Reporting you to NSA",
	"Banning random people",
	"Attempting to install legit cw... ERROR",
	"Transferring all your money to kurozael",
	"Transferring $30 to kurozael",
	"#kurobucks, #kurobank",
	"Throwing all the errors at you",
	"Downloading internet",
	"Sending your server IP to Anonymous",
	"Taking over your community",
	"Turning your cat into a dog",
	"Turning your dog into a cat",
	"Suing you for using Catwork",
	"Generating a ton of Alex Grist drama",
	"Burning your CPU",
	"Stealing your CS:GO items",
	"Stealing your TF2 hats",
	"Downloading ponies",
	"Generating Lua Errors",
	"Something is creating script errors",
	"Banning people for thinking about NutScript",
	"Installing NutScript",
	"Ripping off NutScript",
	"Stealing TARDIS",
	"Installing winlocker",
	"Hacking your Apple ID"
}

MsgC(Color(0, 255, 255, 255), "[CloudAuthX] "..table.Random(phrases)..", please wait...\n")
