--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

DEFINE_BASECLASS("gamemode_base")

--[[
	@codebase Server
	@details Called when the server has initialized.
--]]
function GM:Initialize()
	catio.Initialize()

	local useLocalMachineDate = config.GetVal("use_local_machine_date")
	local useLocalMachineTime = config.GetVal("use_local_machine_time")
	local defaultDate = cw.option:GetKey("default_date")
	local defaultTime = cw.option:GetKey("default_time")
	local defaultDays = cw.option:GetKey("default_days")
	local username = config.GetVal("mysql_username")
	local password = config.GetVal("mysql_password")
	local database = config.GetVal("mysql_database")
	local dateInfo = os.date("*t")
	local host = string.gsub(config.GetVal("mysql_host"), "^http[s]?://", "", 1); -- Matches at beginning of string, matches http:// or https://, no need to check twice
	local port = config.GetVal("mysql_port")

	cw.database.Module = "mysqloo"

	if (!host or host == "" or host == " " or host == "example.com" or host == "sqlite" or host == "example") then
		cw.database.Module = "sqlite"
	end

	cw.database:Connect(host, username, password, database, port)

	if (useLocalMachineTime) then
		config.Get("minute_time"):Set(60)
	end

	config.SetInitialized(true)

	table.Merge(cw.time, defaultTime)
	table.Merge(cw.date, defaultDate)
	math.randomseed(os.time())

	if (useLocalMachineTime) then
		local realDay = dateInfo.wday - 1

		if (realDay == 0) then
			realDay = #defaultDays
		end

		table.Merge(cw.time, {
			minute = dateInfo.min,
			hour = dateInfo.hour,
			day = realDay
		})

		cw.NextDateTimeThink = SysTime() + (60 - dateInfo.sec)
	else
		table.Merge(cw.time, cw.core:RestoreSchemaData("time"))
	end

	if (useLocalMachineDate) then
		dateInfo.year = dateInfo.year + (defaultDate.year - dateInfo.year)

		table.Merge(cw.time, {
			month = dateInfo.month,
			year = dateInfo.year,
			day = dateInfo.yday
		})
	else
		table.Merge(cw.date, cw.core:RestoreSchemaData("date"))
	end

	CW_CONVAR_LOG = cw.core:CreateConVar("cwLog", 1)

	for k, v in pairs(config.stored) do
		hook.Run("ClockworkConfigInitialized", k, v.value)
	end

	hook.Run("ClockworkInitialized")
end

timer.Create("CW:PlayerWaterChecker", 1, 0, function()
	for k, v in ipairs(_player.GetAll()) do
		if (v.submerged) then
			local timeInWater = CurTime() - v.waterStartTime
			local decrease = 6

			if (timeInWater > 5) then
				v:SetCharacterData("Stamina", math.Clamp(v:GetCharacterData("Stamina") - decrease, 0, 100))
			end

			if (v:GetCharacterData("Stamina") <= 0) then
				v:TakeDamage(7)
			end
		end
	end
end)

function GM:OnePlayerSecond(player, curTime, infoTable)
	local weaponClass = cw.player:GetWeaponClass(player)
	local color = player:GetColor()
	local isDrunk = cw.player:GetDrunk(player)

	player:HandleAttributeProgress(curTime)
	player:HandleAttributeBoosts(curTime)

	player:SetDTString(STRING_FLAGS, player:GetFlags())
	player:SetNetVar("Model", player:GetDefaultModel())
	player:SetDTString(STRING_NAME, player:Name())
	player:SetNetVar("Cash", player:GetCash())

	local clothesItem = player:IsWearingClothes()

	if (clothesItem) then
		player:NetworkClothesData()
	else
		player:RemoveClothes()
	end

	if (config.GetVal("health_regeneration_enabled") and hook.Run("PlayerShouldHealthRegenerate", player)) then
		hook.Run("PlayerHealthRegenerate", player, health, maxHealth)
	end

	if (color.r == 255 and color.g == 0 and color.b == 0 and color.a == 0) then
		player:SetColor(Color(255, 255, 255, 255))
	end

	for k, v in pairs(player:GetWeapons()) do
		local ammoType = v:GetPrimaryAmmoType()

		if (ammoType == "grenade" and player:GetAmmoCount(ammoType) == 0) then
			player:StripWeapon(v:GetClass())
		end
	end

	if (player.cwDrunkTab) then
		for k, v in pairs(player.cwDrunkTab) do
			if (curTime >= v) then
				table.remove(player.cwDrunkTab, k)
			end
		end
	end

	if (isDrunk) then
		player:SetNetVar("IsDrunk", isDrunk)
	else
		player:SetNetVar("IsDrunk", 0)
	end

	if (!config.GetVal("cash_enabled")) then
		player:SetCharacterData("Cash", 0, true)
		infoTable.wages = 0
	end
end

-- Called at an interval while a player is connected.
function GM:PlayerThink(player, curTime, infoTable)
	if (player:WaterLevel() >= 3) then
		player.submerged = true
		player.waterStartTime = player.waterStartTime or curTime
	else
		player.submerged = false
		player.waterStartTime = nil
	end

	if (player:IsRagdolled()) then
		player:SetMoveType(MOVETYPE_OBSERVER)
	end

	local storageTable = player:GetStorageTable()

	if (storageTable and hook.Run("PlayerStorageShouldClose", player, storageTable)) then
		cw.storage:Close(player)
	end

	player:SetNetVar("InvWeight", math.ceil(infoTable.inventoryWeight))
	player:SetNetVar("InvSpace", math.ceil(infoTable.inventorySpace))
	player:SetNetVar("Wages", math.ceil(infoTable.wages))

	if (cw.event:CanRun("limb_damage", "disability")) then
		local leftLeg = cw.limb:GetDamage(player, HITGROUP_LEFTLEG, true)
		local rightLeg = cw.limb:GetDamage(player, HITGROUP_RIGHTLEG, true)
		local legDamage = math.max(leftLeg, rightLeg)

		-- looks like infoTable is necessary here for correct function. ayy...
		if (legDamage > 0) then
			player:SetJumpPower(infoTable.jumpPower / (1 + legDamage), true)
			player:SetRunSpeed(infoTable.runSpeed / (1 + legDamage), true)
		else
			player:SetJumpPower(infoTable.jumpPower, true)
			player:SetRunSpeed(infoTable.runSpeed, true)
		end
	end

	if (player:KeyDown(IN_BACK)) then
		player:SetRunSpeed(player:GetRunSpeed() * 0.5, true)
	end

	if (player:GetRunSpeed() < player:GetWalkSpeed()) then
		player:SetRunSpeed(player:GetWalkSpeed(), true)
	end

	--[[ Update whether the weapon has fired, or is being raised. --]]
	player:UpdateWeaponFired()
	player:SetDTBool(BOOL_ISRUNNING, infoTable.isRunning)

	local activeWeapon = player:GetActiveWeapon()
	local weaponItemTable = item.GetByWeapon(activeWeapon)

	if (weaponItemTable and weaponItemTable:IsInstance()) then
		local clipOne = activeWeapon:Clip1()
		local clipTwo = activeWeapon:Clip2()

		if (clipOne >= 0) then
			weaponItemTable:SetData("ClipOne", clipOne)
		end

		if (clipTwo >= 0) then
			weaponItemTable:SetData("ClipTwo", clipTwo)
		end
	end
end

-- Called when a player has disconnected.
function GM:PlayerDisconnected(player)
	if (IsValid(player) and player:HasInitialized()) then
		if (hook.Run("PlayerCharacterUnloaded", player) != true) then
			player:SaveCharacter()
		end

		cw.core:PrintLog(LOGTYPE_MINOR, player:Name().." ("..player:SteamID().." / "..player:IPAddress()..") has disconnected.")
		chatbox.AddText(nil, player:SteamName()..L"PlayerDisconnected", {filter = "events", icon = "icon16/user_delete.png", textColor = Color(180, 80, 150)})
	end
end

-- Called when Clockwork has initialized.
function GM:ClockworkInitialized()
	local cashName = cw.option:GetKey("name_cash")

	if (!config.GetVal("cash_enabled")) then
		cw.command:SetHidden("GiveCash", true)
		cw.command:SetHidden("DropCash", true)
		cw.command:SetHidden("StorageTakeCash", true)
		cw.command:SetHidden("StorageGiveCash", true)

		config.Get("scale_prop_cost"):Set(0, nil, true, true)
		config.Get("door_cost"):Set(0, nil, true, true)
	end

	if (config.GetVal("use_own_group_system")) then
		cw.command:SetHidden("PlySetGroup", true)
		cw.command:SetHidden("PlyDemote", true)
	end

	local gradientTexture = cw.option:GetKey("gradient")
	local schemaLogo = cw.option:GetKey("schema_logo")
	local introImage = cw.option:GetKey("intro_image")

	if (gradientTexture != "gui/gradient_up") then
		cw.core:AddFile("materials/"..gradientTexture..".png")
	end

	if (schemaLogo != "") then
		cw.core:AddFile("materials/"..schemaLogo..".png")
	end

	if (introImage != "") then
		cw.core:AddFile("materials/"..introImage..".png")
	end

	for k, v in pairs(cw.tool:GetAll()) do
		weapons.GetStored("gmod_tool").Tool[v.Mode] = v
	end
end

-- Called when the Clockwork database has connected.
function GM:DatabaseConnected()
	cw.bans:Load()
end

-- Called when the Clockwork database connection fails.
function GM:DatabaseConnectionFailed()
	cw.database:Error(errText)
end

-- Called when a player's model has changed.
function GM:PlayerModelChanged(player, model)
	local hands = player:GetHands()

	if (IsValid(hands) and hands:IsValid()) then
		self:PlayerSetHandsModel(player, player:GetHands())
	end
end

-- Called when a player's saved inventory should be added to.
function GM:PlayerAddToSavedInventory(player, character, Callback)
	for k, v in pairs(player:GetWeapons()) do
		local weaponItemTable = item.GetByWeapon(v)
		if (weaponItemTable) then
			Callback(weaponItemTable)
		end
	end
end

-- Called when a player's unlock info is needed.
function GM:PlayerGetUnlockInfo(player, entity)
	if (cw.entity:IsDoor(entity)) then
		local unlockTime = config.GetVal("unlock_time")

		if (cw.event:CanRun("limb_damage", "unlock_time")) then
			local leftArm = cw.limb:GetDamage(player, HITGROUP_LEFTARM, true)
			local rightArm = cw.limb:GetDamage(player, HITGROUP_RIGHTARM, true)
			local armDamage = math.max(leftArm, rightArm)

			if (armDamage > 0) then
				unlockTime = unlockTime * (1 + armDamage)
			end
		end

		return {
			duration = unlockTime,
			Callback = function(player, entity)
				entity:Fire("unlock", "", 0)
			end
		}
	end
end

-- Called when a player's lock info is needed.
function GM:PlayerGetLockInfo(player, entity)
	if (cw.entity:IsDoor(entity)) then
		local lockTime = config.GetVal("lock_time")

		if (cw.event:CanRun("limb_damage", "lock_time")) then
			local leftArm = cw.limb:GetDamage(player, HITGROUP_LEFTARM, true)
			local rightArm = cw.limb:GetDamage(player, HITGROUP_RIGHTARM, true)
			local armDamage = math.max(leftArm, rightArm)

			if (armDamage > 0) then
				lockTime = lockTime * (1 + armDamage)
			end
		end

		return {
			duration = lockTime,
			Callback = function(player, entity)
				entity:Fire("lock", "", 0)
			end
		}
	end
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

	-- Called when a player attempts to fire a weapon.
	function GM:PlayerCanFireWeapon(player, bIsRaised, weapon, bIsSecondary)
		local canShootTime = player.cwNextShootTime
		local curTime = CurTime()
		local weaponClass = weapon:GetClass()

		if (meleeWeapons[weaponClass]) then
			if (player:GetCharacterData("Stamina") < meleeWeapons[weaponClass]) then
				return false
			end
		end

		if (player:IsRunning() and config.GetVal("sprint_lowers_weapon")) then
			return false
		end

		if (!bIsRaised and !hook.Run("PlayerCanUseLoweredWeapon", player, weapon, bIsSecondary)) then
			return false
		end

		if (canShootTime and canShootTime > curTime) then
			return false
		end

		if (cw.event:CanRun("limb_damage", "weapon_fire")) then
			local leftArm = cw.limb:GetDamage(player, HITGROUP_LEFTARM, true)
			local rightArm = cw.limb:GetDamage(player, HITGROUP_RIGHTARM, true)
			local armDamage = math.max(leftArm, rightArm)

			if (armDamage == 0) then return true end

			if (player.cwArmDamageNoFire) then
				if (curTime >= player.cwArmDamageNoFire) then
					player.cwArmDamageNoFire = nil
				end

				return false
			else
				if (!player.cwNextArmDamage) then
					player.cwNextArmDamage = curTime + (1 - (armDamage * 0.5))
				end

				if (curTime >= player.cwNextArmDamage) then
					player.cwNextArmDamage = nil

					if (math.random() <= armDamage * 0.75) then
						player.cwArmDamageNoFire = curTime + (1 + (armDamage * 2))
					end
				end
			end
		end

		return true
	end
end

-- Called when a player attempts to use a lowered weapon.
function GM:PlayerCanUseLoweredWeapon(player, weapon, secondary)
	if (secondary) then
		return weapon.NeverRaised or (weapon.Secondary and weapon.Secondary.NeverRaised)
	else
		return weapon.NeverRaised or (weapon.Primary and weapon.Primary.NeverRaised)
	end
end

-- Called when a player has been given flags.
function GM:PlayerFlagsGiven(player, flags)
	if (string.find(flags, "p") and player:Alive()) then
		cw.player:GiveSpawnWeapon(player, "weapon_physgun")
	end

	if (string.find(flags, "t") and player:Alive()) then
		cw.player:GiveSpawnWeapon(player, "gmod_tool")
	end

	player:SetDTString(STRING_FLAGS, player:GetFlags())
end

-- Called when a player has had flags taken.
function GM:PlayerFlagsTaken(player, flags)
	if (string.find(flags, "p") and player:Alive()) then
		if (!cw.player:HasFlags(player, "p")) then
			cw.player:TakeSpawnWeapon(player, "weapon_physgun")
		end
	end

	if (string.find(flags, "t") and player:Alive()) then
		if (!cw.player:HasFlags(player, "t")) then
			cw.player:TakeSpawnWeapon(player, "gmod_tool")
		end
	end

	player:SetDTString(STRING_FLAGS, player:GetFlags())
end

-- Called when a player's default skin is needed.
function GM:GetPlayerDefaultSkin(player)
	local model, skin = cw.class:GetAppropriateModel(player:Team(), player)
	return skin
end

-- Called when a player's default model is needed.
function GM:GetPlayerDefaultModel(player)
	local model, skin = cw.class:GetAppropriateModel(player:Team(), player)
	return model
end

-- Called when a player's default inventory is needed.
function GM:GetPlayerDefaultInventory(player, character, inventory)
	local startingInv = faction.FindByID(character.faction).startingInv

	if (istable(startingInv)) then
		for k, v in pairs(startingInv) do
			cw.inventory:AddInstance(
				inventory, item.CreateInstance(k), v
			)
		end
	end
end

-- Called to get whether a player's weapon is raised.
function GM:GetPlayerWeaponRaised(player, class, weapon)
	if (cw.core:IsDefaultWeapon(weapon)) then
		return true
	end

	if (player:IsRunning() and config.GetVal("sprint_lowers_weapon")) then
		return false
	end

	if (weapon:GetNWInt("Zoom") != 0) then
		return true
	end

	if (weapon:GetNWBool("Scope")) then
		return true
	end

	if (config.GetVal("raised_weapon_system")) then
		if (player.cwWeaponRaiseClass == class) then
			return true
		else
			player.cwWeaponRaiseClass = nil
		end

		if (player.cwAutoWepRaised == class) then
			return true
		else
			player.cwAutoWepRaised = nil
		end

		return false
	end

	return true
end

-- Called to get whether a player can give an item to storage.
function GM:PlayerCanGiveToStorage(player, storageTable, itemTable)
	itemTable.cwPropertyTab = itemTable.cwPropertyTab or {}
	itemTable.cwPropertyTab.key = player:GetCharacterKey()
	itemTable.cwPropertyTab.uniqueID = player:UniqueID()

	return true
end

-- Called to get whether a player can take an item to storage.
function GM:PlayerCanTakeFromStorage(player, storageTable, itemTable)
	if (itemTable.cwPropertyTab) then
		if (cw.entity:BelongsToAnotherCharacter(player, itemTable)) then
			cw.player:Notify(player, L"#CantTakeOthersCharactersItems")
			cw.core:PrintLog(LOGTYPE_MAJOR, player:Name().." has attempted to take an item stored by another character.")

			return false
		else
			itemTable.cwPropertyTab = nil
		end
	end

	return true
end

-- Called when a player has given an item to storage.
function GM:PlayerGiveToStorage(player, storageTable, itemTable)
	if (player:IsWearingItem(itemTable)) then
		player:RemoveClothes()
	end

	if (player:IsWearingAccessory(itemTable)) then
		player:RemoveAccessory(itemTable)
	end
end

-- Called when a player is given an item.
function GM:PlayerItemGiven(player, itemTable, bForce)
	cw.storage:SyncItem(player, itemTable)
end

-- Called when a player has an item taken.
function GM:PlayerItemTaken(player, itemTable)
	cw.storage:SyncItem(player, itemTable)

	if (player:IsWearingItem(itemTable)) then
		player:RemoveClothes()
	end

	if (player:IsWearingAccessory(itemTable)) then
		player:RemoveAccessory(itemTable)
	end
end

-- Called when a player's cash has been updated.
function GM:PlayerCashUpdated(player, amount, reason, bNoMsg)
	cw.storage:SyncCash(player)
end

-- A function to scale damage by hit group.
function GM:PlayerScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, baseDamage)
	if (attacker:IsVehicle() or (attacker:IsPlayer() and attacker:InVehicle())) then
		damageInfo:ScaleDamage(0.25)
	end
end

-- Called when a player switches their flashlight on or off.
function GM:PlayerSwitchFlashlight(player, bIsOn)
	if (player:HasInitialized() and bIsOn
	and player:IsRagdolled()) then
		return false
	end

	return true
end

-- Called when Clockwork config has initialized.
function GM:ClockworkConfigInitialized(key, value)
	if (key == "cash_enabled" and !value) then
		for k, v in pairs(item.GetAll()) do
			v.cost = 0
		end
	elseif (key == "local_voice") then
		if (value) then
			RunConsoleCommand("sv_alltalk", "0")
		end
	end

	RunConsoleCommand("sv_maxrate", "80000")
end

-- Called when a Clockwork ConVar has changed.
function GM:ClockworkConVarChanged(name, previousValue, newValue)
	if (name == "local_voice" and newValue) then
		RunConsoleCommand("sv_alltalk", "1")
	end
end

-- Called when Clockwork config has changed.
function GM:ClockworkConfigChanged(key, data, previousValue, newValue)
	local plyTable = _player.GetAll()

	if (key == "default_flags") then
		for k, v in ipairs(plyTable) do
			if (v:HasInitialized() and v:Alive()) then
				if (string.find(previousValue, "p")) then
					if (!string.find(newValue, "p")) then
						if (!cw.player:HasFlags(v, "p")) then
							cw.player:TakeSpawnWeapon(v, "weapon_physgun")
						end
					end
				elseif (!string.find(previousValue, "p")) then
					if (string.find(newValue, "p")) then
						cw.player:GiveSpawnWeapon(v, "weapon_physgun")
					end
				end

				if (string.find(previousValue, "t")) then
					if (!string.find(newValue, "t")) then
						if (!cw.player:HasFlags(v, "t")) then
							cw.player:TakeSpawnWeapon(v, "gmod_tool")
						end
					end
				elseif (!string.find(previousValue, "t")) then
					if (string.find(newValue, "t")) then
						cw.player:GiveSpawnWeapon(v, "gmod_tool")
					end
				end
			end
		end
	elseif (key == "use_own_group_system") then
		if (newValue) then
			cw.command:SetHidden("PlySetGroup", true)
			cw.command:SetHidden("PlyDemote", true)
		else
			cw.command:SetHidden("PlySetGroup", false)
			cw.command:SetHidden("PlyDemote", false)
		end
	elseif (key == "crouched_speed") then
		for k, v in ipairs(plyTable) do
			v:SetCrouchedWalkSpeed(newValue)
		end
	elseif (key == "ooc_interval") then
		for k, v in ipairs(plyTable) do
			v.cwNextTalkOOC = nil
		end
	elseif (key == "jump_power") then
		for k, v in ipairs(plyTable) do
			v:SetJumpPower(newValue)
		end
	elseif (key == "walk_speed") then
		for k, v in ipairs(plyTable) do
			v:SetWalkSpeed(newValue)
		end
	elseif (key == "run_speed") then
		for k, v in ipairs(plyTable) do
			v:SetRunSpeed(newValue)
		end
	end
end

-- Called when a player attempts to sprays their tag.
function GM:PlayerSpray(player)
	if (!player:Alive() or player:IsRagdolled()) then
		return true
	elseif (cw.event:CanRun("config", "player_spray")) then
		return config.GetVal("disable_sprays")
	end
end

-- Called when a player attempts to use an entity.
function GM:PlayerUse(player, entity)
	if (player:IsRagdolled(RAGDOLL_FALLENOVER)) then
		return false
	else
		return true
	end
end

-- Called when a player's move data is set up.
function GM:SetupMove(player, moveData) end

-- Called when a player attempts to save a recognised name.
function GM:PlayerCanSaveRecognisedName(player, target)
	if (player != target) then return true end
end

-- Called when a player attempts to restore a recognised name.
function GM:PlayerCanRestoreRecognisedName(player, target)
	if (player != target) then return true end
end

-- Called when a player attempts to order an item shipment.
function GM:PlayerCanOrderShipment(player, itemTable)
	local curTime = CurTime()

	if (player.cwNextOrderTime and curTime < player.cwNextOrderTime) then
		return false
	end

	return true
end

-- Called when a player attempts to get up.
function GM:PlayerCanGetUp(player) return true end

-- Called when a player attempts to throw a punch.
function GM:PlayerCanThrowPunch(player) return true end

-- Called when a player attempts to punch an entity.
function GM:PlayerCanPunchEntity(player, entity) return false end

-- Called when a player attempts to knock a player out with a punch.
function GM:PlayerCanPunchKnockout(player, target, trace)
	if (trace.HitGroup == HITGROUP_HEAD) then
		return true
	end
end

-- Called when a player attempts to bypass the faction limit.
function GM:PlayerCanBypassFactionLimit(player, character) return false end

-- Called when a player attempts to bypass the class limit.
function GM:PlayerCanBypassClassLimit(player, class) return false end

-- Called when a player's pain sound should be played.
function GM:PlayerPlayPainSound(player, gender, damageInfo, hitGroup)
	if (damageInfo:IsBulletDamage() and math.random() <= 0.5) then
		if (hitGroup == HITGROUP_HEAD) then
			return "vo/npc/"..gender.."01/ow0"..math.random(1, 2)..".wav"
		elseif (hitGroup == HITGROUP_CHEST or hitGroup == HITGROUP_GENERIC) then
			return "vo/npc/"..gender.."01/hitingut0"..math.random(1, 2)..".wav"
		elseif (hitGroup == HITGROUP_LEFTLEG or hitGroup == HITGROUP_RIGHTLEG) then
			return "vo/npc/"..gender.."01/myleg0"..math.random(1, 2)..".wav"
		elseif (hitGroup == HITGROUP_LEFTARM or hitGroup == HITGROUP_RIGHTARM) then
			return "vo/npc/"..gender.."01/myarm0"..math.random(1, 2)..".wav"
		elseif (hitGroup == HITGROUP_GEAR) then
			return "vo/npc/"..gender.."01/startle0"..math.random(1, 2)..".wav"
		end
	end

	return "vo/npc/"..gender.."01/pain0"..math.random(1, 9)..".wav"
end

-- Called when a player has spawned.
function GM:PlayerSpawn(player)
	if (player:HasInitialized()) then
		player:ShouldDropWeapon(false)

		if (!player.cwLightSpawn) then
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

			if (player:FlashlightIsOn()) then
				player:Flashlight(false)
			end

			player:SetForcedAnimation(false)
			player:SetCollisionGroup(COLLISION_GROUP_PLAYER)
			player:SetMaterial("")
			player:SetMoveType(MOVETYPE_WALK)
			player:Extinguish()
			player:UnSpectate()
			player:GodDisable()
			player:RunCommand("-duck")
			player:SetColor(Color(255, 255, 255, 255))
			player:SetupHands()

			player:SetCrouchedWalkSpeed(config.GetVal("crouched_speed") / config.GetVal("walk_speed"))
			player:SetWalkSpeed(config.GetVal("walk_speed"))
			player:SetJumpPower(config.GetVal("jump_power"))
			player:SetRunSpeed(config.GetVal("run_speed"))
			player:CrosshairDisable()

			player:SetMaxHealth(FACTION.maxHealth or 100)
			player:SetMaxArmor(FACTION.maxArmor or 0)
			player:SetHealth(FACTION.maxHealth or 100)
			player:SetArmor(FACTION.maxArmor or 0)

			if (rank) then
				player:SetMaxHealth(rank.maxHealth or player:GetMaxHealth())
				player:SetMaxArmor(rank.maxArmor or player:GetMaxArmor())
				player:SetHealth(rank.maxHealth or player:GetMaxHealth())
				player:SetArmor(rank.maxArmor or player:GetMaxArmor())
			end

			if (istable(FACTION.respawnInv)) then
				local inventory = player:GetInventory()
				local itemQuantity

				for k, v in pairs(FACTION.respawnInv) do
					for i = 1, (v or 1) do
						itemQuantity = table.Count(inventory[k])

						if (itemQuantity < v) then
							player:GiveItem(item.CreateInstance(k), true)
						end
					end
				end
			end

			if (prevRelation) then
				for k, v in pairs(ents.GetAll()) do
					if (v:IsNPC()) then
						prevRelation[player:SteamID()] = prevRelation[player:SteamID()] or {}
						local prevRelationVal = prevRelation[player:SteamID()][v:GetClass()]

						if (prevRelationVal) then
							v:AddEntityRelationship(player, prevRelationVal, 1)
						end
					end
				end
			end

			if (istable(relation)) then
				local relationEnts

				prevRelation = prevRelation or {}
				prevRelation[player:SteamID()] = prevRelation[player:SteamID()] or {}

				for k, v in pairs(relation) do
					relationEnts = ents.FindByClass(k)

					if (relationEnts) then
						for k2, v2 in pairs(relationEnts) do
							if (string.lower(v) == "like") then
								prevRelation[player:SteamID()][k] = v2:Disposition(player)
								v2:AddEntityRelationship(player, D_LI, 1)
							elseif (string.lower(v) == "fear") then
								prevRelation[player:SteamID()][k] = v2:Disposition(player)
								v2:AddEntityRelationship(player, D_FR, 1)
							elseif (string.lower(v) == "hate") then
								prevRelation[player:SteamID()][k] = v2:Disposition(player)
								v2:AddEntityRelationship(player, D_HT, 1)
							else
								ErrorNoHalt("Attempting to add relationship using invalid relation '"..v.."' towards faction '"..FACTION.name.."'.\r\n")
							end
						end
					end
				end
			end

			if (player.cwFirstSpawn) then
				local ammo = player:GetSavedAmmo()

				for k, v in pairs(ammo) do
					if (!string.find(k, "p_") and !string.find(k, "s_")) then
						player:GiveAmmo(v, k); ammo[k] = nil
					end
				end
			else
				player:UnLock()
			end
		end

		if (player.cwLightSpawn and player.cwSpawnCallback) then
			player.cwSpawnCallback(player, true)
			player.cwSpawnCallback = nil
		end

		hook.Run("PostPlayerSpawn", player, player.cwLightSpawn, player.cwChangeClass, player.cwFirstSpawn)
		cw.player:SetRecognises(player, player, RECOGNISE_TOTAL)

		local accessoryData = player:GetAccessoryData()
		local clothesItem = player:GetClothesItem()

		if (clothesItem) then
			player:SetClothesData(clothesItem)
		end

		for k, v in pairs(accessoryData) do
			local itemTable = player:FindItemByID(v, k)

			if (itemTable) then
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

-- Choose the model for hands according to their player model.
function GM:PlayerSetHandsModel(player, entity)
	local model = player:GetModel()
	local simpleModel = player_manager.TranslateToPlayerModelName(model)
	local info = cw.animation:GetHandsInfo(model) or player_manager.TranslatePlayerHands(simpleModel)

	if (info) then
		entity:SetModel(info.model)
		entity:SetSkin(info.skin)

		local bodyGroups = tostring(info.body)

		if (bodyGroups) then
			bodyGroups = string.Explode("", bodyGroups)

			for k, v in pairs(bodyGroups) do
				local num = tonumber(v)

				if (num) then
					entity:SetBodygroup(k, num)
				end
			end
		end
	end

	hook.Run("PostCModelHandsSet", player, model, entity, info)
end

-- Called when a player attempts to connect to the server.
function GM:CheckPassword(steamID, ipAddress, svPassword, clPassword, name)
	steamID = util.SteamIDFrom64(steamID)
	local banTable = cw.bans.stored[ipAddress] or cw.bans.stored[steamID]

	if (banTable) then
		local unixTime = os.time()
		local unbanTime = tonumber(banTable.unbanTime)
		local timeLeft = unbanTime - unixTime
		local hoursLeft = math.Round(math.max(timeLeft / 3600, 0))
		local minutesLeft = math.Round(math.max(timeLeft / 60, 0))

		if (unbanTime > 0 and unixTime < unbanTime) then
			local bannedMessage = config.Get("banned_message"):Get()

			if (hoursLeft >= 1) then
				hoursLeft = tostring(hoursLeft)

				bannedMessage = string.gsub(bannedMessage, "!t", hoursLeft)
				bannedMessage = string.gsub(bannedMessage, "!f", "hour(s)")
			elseif (minutesLeft >= 1) then
				minutesLeft = tostring(minutesLeft)

				bannedMessage = string.gsub(bannedMessage, "!t", minutesLeft)
				bannedMessage = string.gsub(bannedMessage, "!f", "minutes(s)")
			else
				timeLeft = tostring(timeLeft)

				bannedMessage = string.gsub(bannedMessage, "!t", timeLeft)
				bannedMessage = string.gsub(bannedMessage, "!f", "second(s)")
			end

			return false, bannedMessage
		elseif (unbanTime == 0) then
			return false, banTable.reason
		else
			cw.bans:Remove(ipAddress)
			cw.bans:Remove(steamID)
		end
	end
end

-- Called when the Clockwork data is saved.
function GM:SaveData()
	for k, v in ipairs(_player.GetAll()) do
		if (v:HasInitialized()) then
			v:SaveCharacter()
		end
	end

	if (!config.GetVal("use_local_machine_time")) then
		cw.core:SaveSchemaData("time", cw.time:GetSaveData())
	end

	if (!config.GetVal("use_local_machine_date")) then
		cw.core:SaveSchemaData("date", cw.date:GetSaveData())
	end
end

function GM:PlayerCanInteractCharacter(player, action, character)
	if (cw.quiz:GetEnabled() and !cw.quiz:GetCompleted(player)) then
		return false, 'Вы допустили ошибки в тесте!'
	else
		return true
	end
end

-- Called whe the map entities are initialized.
function GM:InitPostEntity()
	for k, v in pairs(ents.GetAll()) do
		if (IsValid(v)) then
			if (v:GetModel()) then
				cw.entity:SetMapEntity(v, true)
				cw.entity:SetStartAngles(v, v:GetAngles())
				cw.entity:SetStartPosition(v, v:GetPos())

				if (cw.entity:SetChairAnimations(v)) then
					v:SetCollisionGroup(COLLISION_GROUP_WEAPON)

					local physicsObject = v:GetPhysicsObject()

					if (IsValid(physicsObject)) then
						physicsObject:EnableMotion(false)
					end
				end
			end

			if (cw.entity:IsDoor(v)) then
				local entIndex = v:EntIndex()

				if (!cw.entity.DoorEntities) then cw.entity.DoorEntities = {}; end

				local doorEnts = cw.entity.DoorEntities

				if (!doorEnts[entIndex]) then
					doorEnts[entIndex] = v
				end
			end
		end
	end

	netvars.SetNetVar("NoMySQL", cw.NoMySQL)
	hook.Run("ClockworkInitPostEntity")

	for k, v in ipairs(ents.GetAll()) do
		local model = v:GetModel()

		if (!v:IsPlayer() and model and (model:find("wood") or model:find("table") or model:find("bench")
		or model:find("table") or model:find("chair") or model:find("box") or model:find("cardboard")
		or model:find("pallet"))) then
			v:SetKeyValue("negated", "1")
		end
	end
end

-- Called when a player initially spawns.
function GM:PlayerInitialSpawn(player)
	player.cwCharacterList = player.cwCharacterList or {}
	player.cwHasSpawned = true
	player.cwSharedVars = player.cwSharedVars or {}

	if (IsValid(player)) then
		player:KillSilent()
	end

	if (player:IsBot()) then
		config.Send(player)
	end

	if (!player:IsKicked()) then
		cw.core:PrintLog(LOGTYPE_MINOR, player:SteamName().." ("..player:SteamID().." / "..player:IPAddress()..") has connected.")
		chatbox.AddText(nil, player:SteamName()..L"PlayerConnected", {filter = "events", icon = "icon16/user_add.png", textColor = Color(150, 80, 210)})
	end
end

-- Called every frame while a player is dead.
function GM:PlayerDeathThink(player)
	local action = cw.player:GetAction(player)

	if (!player:HasInitialized() or player:GetCharacterData("CharBanned")) then
		return true
	end

	if (player:IsCharacterMenuReset()) then
		return true
	end

	if (action == "spawn") then
		return true
	else
		player:Spawn()
	end
end

-- Called when a player's data has loaded.
function GM:PlayerDataLoaded(player)
	if (config.GetVal("clockwork_intro_enabled")) then
		if (!player:GetData("ClockworkIntro")) then
			netstream.Start(player, "ClockworkIntro", true)

			player:SetData("ClockworkIntro", true)
		end
	end
end

-- Called when a player attempts to be given a weapon.
function GM:PlayerCanBeGivenWeapon(player, class, itemTable)
	return true
end

-- Called when a player has been given a weapon.
function GM:PlayerGivenWeapon(player, class, itemTable)
	cw.inventory:Rebuild(player)

	if (item.IsWeapon(itemTable) and !itemTable:IsFakeWeapon()) then
		if (!itemTable:IsMeleeWeapon() and !itemTable:IsThrowableWeapon()) then
			if (itemTable.weight <= 2) then
				cw.player:CreateGear(player, "Secondary", itemTable)
			else
				cw.player:CreateGear(player, "Primary", itemTable)
			end
		elseif (itemTable:IsThrowableWeapon()) then
			cw.player:CreateGear(player, "Throwable", itemTable)
		else
			cw.player:CreateGear(player, "Melee", itemTable)
		end
	end
end

-- Called when a player attempts to create a character.
function GM:PlayerCanCreateCharacter(player, character, characterID)
	if (cw.quiz:GetEnabled() and !cw.quiz:GetCompleted(player)) then
		return "Вы не прошли тестирование!"
	else
		return true
	end
end

-- Called when a player's bullet info should be adjusted.
function GM:PlayerAdjustBulletInfo(player, bulletInfo) end

-- Called when an entity fires some bullets.
function GM:EntityFireBullets(entity, bulletInfo) end

-- Called when a player's fall damage is needed.
function GM:GetFallDamage(player, velocity)
	local ragdollEntity = nil
	local position = player:GetPos()
	local damage = math.max((velocity - 464) * 0.225225225, 0) * config.GetVal("scale_fall_damage")
	local filter = {player}

	if (config.GetVal("wood_breaks_fall")) then
		if (player:IsRagdolled()) then
			ragdollEntity = player:GetRagdollEntity()
			position = ragdollEntity:GetPos()
			filter = {player, ragdollEntity}
		end

		local traceLine = util.TraceLine({
			endpos = position - Vector(0, 0, 64),
			start = position,
			filter = filter
		})

		if (IsValid(traceLine.Entity) and traceLine.MatType == MAT_WOOD) then
			if (string.find(traceLine.Entity:GetClass(), "prop_physics")) then
				traceLine.Entity:Fire("break", "", 0)
				damage = damage * 0.25
			end
		end
	end

	if (damage > 30) then
		timer.Simple(0, function()
			cw.player:SetRagdollState(player, RAGDOLL_FALLENOVER, nil)

			player:SetDTBool(BOOL_FALLENOVER, true)
		end)
	end

	return damage
end

-- Called when a player's data stream info has been sent.
function GM:PlayerDataStreamInfoSent(player)
	if (player:IsBot()) then
		cw.player:LoadData(player, function(player)
			hook.Run("PlayerDataLoaded", player)

			local factions = table.ClearKeys(faction.GetAll(), true)
			local faction = factions[math.random(1, #factions)]

			if (faction) then
				local genders = {GENDER_MALE, GENDER_FEMALE}
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
	elseif (table.Count(faction.GetAll()) > 0) then
		cw.player:LoadData(player, function()
			hook.Run("PlayerDataLoaded", player)

			local whitelisted = player:GetData("Whitelisted")
			local steamName = player:SteamName()
			local unixTime = os.time()

			cw.player:SetCharacterMenuState(player, CHARACTER_MENU_OPEN)

			if (whitelisted) then
				for k, v in pairs(whitelisted) do
					if (_faction.GetStored()[v]) then
						netstream.Start(player, "SetWhitelisted", {v, true})
					else
						whitelisted[k] = nil
					end
				end
			end

			cw.player:GetCharacters(player, function(characters)
				if (characters) then
					for k, v in pairs(characters) do
						cw.player:ConvertCharacterMySQL(v)
						player.cwCharacterList[v.characterID] = {}

						for k2, v2 in pairs(v) do
							if (k2 == "timeCreated") then
								if (v2 == "") then
									player.cwCharacterList[v.characterID][k2] = unixTime
								else
									player.cwCharacterList[v.characterID][k2] = v2
								end
							elseif (k2 == "lastPlayed") then
								player.cwCharacterList[v.characterID][k2] = unixTime
							elseif (k2 == "steamName") then
								player.cwCharacterList[v.characterID][k2] = steamName
							else
								player.cwCharacterList[v.characterID][k2] = v2
							end
						end
					end

					for k, v in pairs(player.cwCharacterList) do
						local bDelete = hook.Run("PlayerAdjustCharacterTable", player, v)

						if (!bDelete) then
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

-- Called when a player's data stream info should be sent.
function GM:PlayerSendDataStreamInfo(player)
	netstream.Start(player, "SharedTables", cw.SharedTables)

	if (cw.OverrideColorMod and cw.OverrideColorMod != nil) then
		netstream.Start(player, "SystemColGet", cw.OverrideColorMod)
	end
end

-- Called when a player's death sound should be played.
function GM:PlayerPlayDeathSound(player, gender)
	return "vo/npc/"..string.lower(gender).."01/pain0"..math.random(1, 9)..".wav"
end

-- Called when a player's character data should be restored.
function GM:PlayerRestoreCharacterData(player, data)
	if (data["PhysDesc"]) then
		data["PhysDesc"] = cw.core:ModifyPhysDesc(data["PhysDesc"])
	end

	if (!data["LimbData"]) then
		data["LimbData"] = {}
	end

	if (!data["Clothes"]) then
		data["Clothes"] = {}
	end

	if (!data["Accessories"]) then
		data["Accessories"] = {}
	end

	cw.player:RestoreCharacterData(player, data)
end

-- Called when a player's limb damage is bIsHealed.
function GM:PlayerLimbDamageHealed(player, hitGroup, amount) end

-- Called when a player's limb takes damage.
function GM:PlayerLimbTakeDamage(player, hitGroup, damage) end

-- Called when a player's limb damage is reset.
function GM:PlayerLimbDamageReset(player) end

-- Called when a player's character data should be saved.
function GM:PlayerSaveCharacterData(player, data)
	if (config.Get("save_attribute_boosts"):Get()) then
		cw.core:SavePlayerAttributeBoosts(player, data)
	end

	data["Health"] = player:Health()
	data["Armor"] = player:Armor()

	if (data["Health"] <= 1) then
		data["Health"] = nil
	end

	if (data["Armor"] <= 1) then
		data["Armor"] = nil
	end
end

-- Called when a player's data should be saved.
function GM:PlayerSaveData(player, data)
	if (data["Whitelisted"] and table.Count(data["Whitelisted"]) == 0) then
		data["Whitelisted"] = nil
	end
end

-- Called when a player's storage should close.
function GM:PlayerStorageShouldClose(player, storageTable)
	local entity = player:GetStorageEntity()

	if (player:IsRagdolled() or !player:Alive() or (storageTable.entity and !entity)
	or (storageTable.entity and storageTable.distance
	and player:GetShootPos():Distance(entity:GetPos()) > storageTable.distance)) then
		return true
	elseif (storageTable.ShouldClose and storageTable.ShouldClose(player, storageTable)) then
		return true
	end
end

-- Called when a player attempts to pickup a weapon.
function GM:PlayerCanPickupWeapon(player, weapon)
	if (player.cwForceGive or (player:GetEyeTraceNoCursor().Entity == weapon and player:KeyDown(IN_USE))) then
		return true
	else
		return false
	end
end

-- Called to modify the wages interval.
function GM:ModifyWagesInterval(info) end

-- Called to modify a player's wages info.
function GM:PlayerModifyWagesInfo(player, info) end

function GM:OneSecond()
	local sysTime = SysTime()
	local curTime = CurTime()

	if (!cw.NextHint or curTime >= cw.NextHint) then
		cw.hint:Distribute()
		cw.NextHint = curTime + config.Get("hint_interval"):Get()
	end

	if (!cw.NextWagesTime or curTime >= cw.NextWagesTime) then
		cw.core:DistributeWagesCash()

		local info = {
			interval = config.GetVal("wages_interval")
		}

		hook.Run("ModifyWagesInterval", info)

		cw.NextWagesTime = curTime + info.interval
	end

	if (!cw.NextDateTimeThink or sysTime >= cw.NextDateTimeThink) then
		cw.core:PerformDateTimeThink()
		cw.NextDateTimeThink = sysTime + config.Get("minute_time"):Get()
	end

	if (!cw.NextSaveData or sysTime >= cw.NextSaveData) then
		hook.Run("PreSaveData")
			hook.Run("SaveData")
		hook.Run("PostSaveData")

		cw.NextSaveData = sysTime + config.Get("save_data_interval"):Get()
	end

	if (!cw.NextCheckEmpty) then
		cw.NextCheckEmpty = sysTime + 1200
	end

	if (sysTime >= cw.NextCheckEmpty) then
		cw.NextCheckEmpty = nil

		if (#_player.GetAll() == 0) then
			RunConsoleCommand("changelevel", game.GetMap())
		end
	end
end

do
	local defaultInvWeight = config.GetVal("default_inv_weight")
	local defaultInvSpace = config.GetVal("default_inv_weight")
	local thinkRate = 0.150
	local cwNextThink = 0
	local cwNextSecond = 0

	-- Called each tick.
	function GM:Tick()
		local curTime = CurTime()

		if (curTime >= cwNextThink) then
			for k, v in ipairs(player.GetAll()) do
				if (v:HasInitialized()) then
					local infoTable = v.cwInfoTable

					infoTable.inventoryWeight = defaultInvWeight
					infoTable.inventorySpace = defaultInvSpace
					infoTable.crouchedSpeed = v.cwCrouchedSpeed
					infoTable.jumpPower = v.cwJumpPower
					infoTable.walkSpeed = v.cwWalkSpeed
					infoTable.isRunning = v:IsRunning()
					infoTable.isJumping = v:IsJumping()
					infoTable.runSpeed = v.cwRunSpeed
					infoTable.wages = cw.class:Query(v:Team(), "wages", 0)

					hook.Run("PlayerThink", v, curTime, infoTable)

					if (curTime >= cwNextSecond) then
						hook.Run("OnePlayerSecond", v, curTime, infoTable)
					end
				end
			end

			cwNextThink = curTime + thinkRate

			if (curTime >= cwNextSecond) then
				cwNextSecond = curTime + 1
			end
		end
	end
end

-- Called every frame.
function GM:Think() end

-- Called when a player's health should regenerate.
function GM:PlayerShouldHealthRegenerate(player)
	return true
end

-- Called to get the entity that a player is holding.
function GM:PlayerGetHoldingEntity(player) end

-- A function to regenerate a player's health.
function GM:PlayerHealthRegenerate(player, health, maxHealth)
	local curTime = CurTime()
	local maxHealth = player:GetMaxHealth()
	local health = player:Health()

	if (player:Alive() and (!player.cwNextHealthRegen or curTime >= player.cwNextHealthRegen)) then
		if (health >= (maxHealth / 2) and (health < maxHealth)) then
			player:SetHealth(math.Clamp(
				health + 2, 0, maxHealth)
			)

			player.cwNextHealthRegen = curTime + 5
		elseif (health > 0) then
			player:SetHealth(
				math.Clamp(health + 2, 0, maxHealth)
			)

			player.cwNextHealthRegen = curTime + 10
		end
	end
end

-- Called when a player picks an item up.
function GM:PlayerPickupItem(player, itemTable, itemEntity, bQuickUse) end

-- Called when a player uses an item.
function GM:PlayerUseItem(player, itemTable, itemEntity) end

-- Called when a player drops an item.
function GM:PlayerDropItem(player, itemTable, position, entity) end

-- Called when a player destroys an item.
function GM:PlayerDestroyItem(player, itemTable) end

-- Called when a player drops a weapon.
function GM:PlayerDropWeapon(player, itemTable, entity, weapon)
	if (itemTable:IsInstance() and IsValid(weapon)) then
		local clipOne = weapon:Clip1()
		local clipTwo = weapon:Clip2()

		if (clipOne > 0) then
			itemTable:SetData("ClipOne", clipOne)
		end

		if (clipTwo > 0) then
			itemTable:SetData("ClipTwo", clipTwo)
		end
	end
end

-- Called when a player's data should be restored.
function GM:PlayerRestoreData(player, data)
	if (!data["Whitelisted"]) then
		data["Whitelisted"] = {}
	end
end

-- Called to get whether a player can pickup an entity.
function GM:AllowPlayerPickup(player, entity)
	return false
end

-- Called when a player selects a custom character option.
function GM:PlayerSelectCharacterOption(player, character, option) end

-- Called when a player attempts to see another player's status.
function GM:PlayerCanSeeStatus(player, target)
	return "# "..target:UserID().." | "..target:Name().." | "..target:SteamName().." | "..target:SteamID().." | "..target:IPAddress()
end

-- Called when a player attempts to see a player's chat.
function GM:PlayerCanSeePlayersChat(text, teamOnly, listener, speaker)
	return true
end

-- Called when a player attempts to hear another player's voice.
function GM:PlayerCanHearPlayersVoice(listener, speaker)
	if (!config.GetVal("voice_enabled")) then
		return false
	elseif (speaker:GetData("VoiceBan")) then
		return false
	elseif (!cw.player:HasFlags(speaker, "x")) then
		return false
	end

	if (config.Get("local_voice"):Get()) then
		if (listener:IsRagdolled(RAGDOLL_KNOCKEDOUT) or !listener:Alive()) then
			return false
		elseif (speaker:IsRagdolled(RAGDOLL_KNOCKEDOUT) or !speaker:Alive()) then
			return false
		elseif (listener:GetPos():Distance(speaker:GetPos()) > config.Get("talk_radius"):Get()) then
			return false
		end
	end

	return true, true
end

-- Called when a player attempts to delete a character.
function GM:PlayerCanDeleteCharacter(player, character) end

-- Called when a player attempts to switch to a character.
function GM:PlayerCanSwitchCharacter(player, character)
	if (!player:Alive() and !player:IsCharacterMenuReset() and !player:GetNetVar("CharBanned")) then
		return L"#CantSwitchWhenDead"
	elseif (player:GetRagdollState() == RAGDOLL_KNOCKEDOUT) then
		return L"#CantSwitchWhenUnc"
	end

	return true
end

-- Called when a player attempts to use a character.
function GM:PlayerCanUseCharacter(player, character)
	if (character.data["CharBanned"]) then
		return character.name..L"#CharIsBanned"
	end

	local faction = faction.FindByID(character.faction)
	local playerRank, rank = player:GetFactionRank(character)
	local factionCount = 0
	local rankCount = 0

	for k, v in ipairs(_player.GetAll()) do
		if (v:HasInitialized()) then
			if (v:GetFaction() == character.faction) then
				if (player != v) then
					if (rank and v:GetFactionRank() == playerRank) then
						rankCount = rankCount + 1
					end

					factionCount = factionCount + 1
				end
			end
		end
	end

	if (faction.playerLimit and factionCount >= faction.playerLimit) then
		return L"#TooManyCharFaction"
	end

	if (rank and rank.playerLimit and rankCount >= rank.playerLimit) then
		return L"#TooManyCharClass"
	end
end

-- Called when a player's weapons should be given.
function GM:PlayerGiveWeapons(player)
	local rankName, rank = player:GetFactionRank()
	local faction = faction.FindByID(player:GetFaction())

	if (rank and rank.weapons) then
		for k, v in pairs(rank.weapons) do
			cw.player:GiveSpawnWeapon(player, v)
		end
	end

	if (faction and faction.weapons) then
		for k, v in pairs(faction.weapons) do
			cw.player:GiveSpawnWeapon(player, v)
		end
	end
end

-- Called when a player deletes a character.
function GM:PlayerDeleteCharacter(player, character) end

-- Called when a player's armor is set.
function GM:PlayerArmorSet(player, newArmor, oldArmor)
	if (player:IsRagdolled()) then
		player:GetRagdollTable().armor = newArmor
	end
end

-- Called when a player's health is set.
function GM:PlayerHealthSet(player, newHealth, oldHealth)
	local bIsRagdolled = player:IsRagdolled()
	local maxHealth = player:GetMaxHealth()

	if (newHealth > oldHealth) then
		cw.limb:HealBody(player, (newHealth - oldHealth) / 2)
	end

	if (newHealth >= maxHealth) then
		cw.limb:HealBody(player, 100)
		player:RemoveAllDecals()

		if (bIsRagdolled) then
			player:GetRagdollEntity():RemoveAllDecals()
		end
	end

	if (bIsRagdolled) then
		player:GetRagdollTable().health = newHealth
	end
end

-- Called when a player attempts to own a door.
function GM:PlayerCanOwnDoor(player, door)
	if (cw.entity:IsDoorUnownable(door)) then
		return false
	else
		return true
	end
end

-- Called when a player attempts to view a door.
function GM:PlayerCanViewDoor(player, door)
	if (cw.entity:IsDoorUnownable(door)) then
		return false
	end

	return true
end

-- Called when a player attempts to holster a weapon.
function GM:PlayerCanHolsterWeapon(player, itemTable, weapon, bForce, bNoMsg)
	if (cw.player:GetSpawnWeapon(player, itemTable:GetWeaponClass())) then
		if (!bNoMsg) then
			cw.player:Notify(player, L(player, "CannotHolsterWeapon"))
		end

		return false
	elseif (itemTable.CanHolsterWeapon) then
		return itemTable:CanHolsterWeapon(player, weapon, bForce, bNoMsg)
	else
		return true
	end
end

-- Called when a player attempts to drop a weapon.
function GM:PlayerCanDropWeapon(player, itemTable, weapon, bNoMsg)
	if (cw.player:GetSpawnWeapon(player, itemTable:GetWeaponClass())) then
		if (!bNoMsg) then
			cw.player:Notify(player, L(player, "CannotDropWeapon"))
		end

		return false
	elseif (itemTable.CanDropWeapon) then
		return itemTable:CanDropWeapon(player, bNoMsg)
	else
		return true
	end
end

-- Called when a player attempts to use an item.
function GM:PlayerCanUseItem(player, itemTable, bNoMsg)
	local isWeapon = item.IsWeapon(itemTable)
	local isSpawnWeapon = false

	if (isWeapon) then
		itemTable = item.Validate(itemTable, true)

		isSpawnWeapon = cw.player:GetSpawnWeapon(player, itemTable:GetWeaponClass())
	end

	if (isWeapon and isSpawnWeapon) then
		if (!bNoMsg) then
			cw.player:Notify(player, L(player, "CannotUseWeapon"))
		end

		return false
	else
		return true
	end
end

-- Called when a player attempts to drop an item.
function GM:PlayerCanDropItem(player, itemTable, bNoMsg) return true end

-- Called when a player attempts to destroy an item.
function GM:PlayerCanDestroyItem(player, itemTable, bNoMsg) return true end

-- Called when a player attempts to knockout a player.
function GM:PlayerCanKnockout(player, target) return true end

-- Called when a player attempts to use the radio.
function GM:PlayerCanRadio(player, text, listeners, eavesdroppers) return true end

-- Called when death attempts to clear a player's name.
function GM:PlayerCanDeathClearName(player, attacker, damageInfo) return false end

-- Called when death attempts to clear a player's recognised names.
function GM:PlayerCanDeathClearRecognisedNames(player, attacker, damageInfo) return false end

-- Called when a player's ragdoll attempts to take damage.
function GM:PlayerRagdollCanTakeDamage(player, ragdoll, inflictor, attacker, hitGroup, damageInfo)
	if (!attacker:IsPlayer() and player:GetRagdollTable().immunity) then
		if (CurTime() <= player:GetRagdollTable().immunity) then
			return false
		end
	end

	return true
end

-- Called when the player attempts to be ragdolled.
function GM:PlayerCanRagdoll(player, state, delay, decay, ragdoll)
	return true
end

-- Called when the player attempts to be unragdolled.
function GM:PlayerCanUnragdoll(player, state, ragdoll)
	return true
end

-- Called when a player has been ragdolled.
function GM:PlayerRagdolled(player, state, ragdoll)
	player:SetDTBool(BOOL_FALLENOVER, false)
end

-- Called when a player has been unragdolled.
function GM:PlayerUnragdolled(player, state, ragdoll)
	player:SetDTBool(BOOL_FALLENOVER, false)
end

-- Called to check if a player does have a flag.
function GM:PlayerDoesHaveFlag(player, flag)
	if (string.find(config.Get("default_flags"):Get(), flag)) then
		return true
	end
end

-- Called when a player's model should be set.
function GM:PlayerSetModel(player)
	cw.player:SetDefaultModel(player)
	cw.player:SetDefaultSkin(player)
end

-- Called to check if a player does have door access.
function GM:PlayerDoesHaveDoorAccess(player, door, access, isAccurate)
	if (cw.entity:GetOwner(door) != player) then
		local key = player:GetCharacterKey()

		if (door.accessList and door.accessList[key]) then
			if (isAccurate) then
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

-- Called to check if a player does know another player.
function GM:PlayerDoesRecognisePlayer(player, target, status, isAccurate, realValue)
	return realValue
end

-- Called when a player attempts to lock an entity.
function GM:PlayerCanLockEntity(player, entity)
	if (cw.entity:IsDoor(entity)) then
		return cw.player:HasDoorAccess(player, entity)
	else
		return true
	end
end

-- Called when a player's class has been set.
function GM:PlayerClassSet(player, newClass, oldClass, noRespawn, addDelay, noModelChange)
	player:SetCharacterData("Class", newClass.name)
end

-- Called when a player attempts to unlock an entity.
function GM:PlayerCanUnlockEntity(player, entity)
	if (cw.entity:IsDoor(entity)) then
		return cw.player:HasDoorAccess(player, entity)
	else
		return true
	end
end

-- Called when a player attempts to use a door.
function GM:PlayerCanUseDoor(player, door)
	if (cw.entity:GetOwner(door) and !cw.player:HasDoorAccess(player, door)) then
		return false
	end

	if (cw.entity:IsDoorFalse(door)) then
		return false
	end

	return true
end

-- Called when a player uses a door.
function GM:PlayerUseDoor(player, door) end

-- Called when a player attempts to use an entity in a vehicle.
function GM:PlayerCanUseEntityInVehicle(player, entity, vehicle)
	if (entity.UsableInVehicle or cw.entity:IsDoor(entity)) then
		return true
	end
end

-- Called when a player's ragdoll attempts to decay.
function GM:PlayerCanRagdollDecay(player, ragdoll, seconds)
	return true
end

-- Called when a player attempts to exit a vehicle.
function GM:CanExitVehicle(vehicle, player)
	if (player.cwNextExitVehicle and player.cwNextExitVehicle > CurTime()) then
		return false
	end

	if (IsValid(player) and player:IsPlayer()) then
		local trace = player:GetEyeTraceNoCursor()

		if (IsValid(trace.Entity) and !trace.Entity:IsVehicle()) then
			if (hook.Run("PlayerCanUseEntityInVehicle", player, trace.Entity, vehicle)) then
				return false
			end
		end
	end

	if (cw.entity:IsChairEntity(vehicle) and !IsValid(vehicle:GetParent())) then
		local trace = player:GetEyeTraceNoCursor()

		if (trace.HitPos:Distance(player:GetShootPos()) <= 192) then
			trace = {
				start = trace.HitPos,
				endpos = trace.HitPos - Vector(0, 0, 1024),
				filter = {player, vehicle}
			}

			player.cwExitVehiclePos = util.TraceLine(trace).HitPos

			player:SetMoveType(MOVETYPE_NOCLIP)
		else
			return false
		end
	end

	return true
end

-- Called when a player leaves a vehicle.
function GM:PlayerLeaveVehicle(player, vehicle)
	timer.Simple(FrameTime() * 0.5, function()
		if (IsValid(player) and !player:InVehicle()) then
			if (IsValid(vehicle)) then
				if (cw.entity:IsChairEntity(vehicle)) then
					local position = player.cwExitVehiclePos or vehicle:GetPos()
					local targetPosition = cw.player:GetSafePosition(player, position, vehicle)

					if (targetPosition) then
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

-- Called when a player attempts to enter a vehicle.
function GM:CanPlayerEnterVehicle(player, vehicle, role)
	return true
end

-- Called when a player enters a vehicle.
function GM:PlayerEnteredVehicle(player, vehicle, class)
	timer.Simple(FrameTime() * 0.5, function()
		if (IsValid(player)) then
			local model = player:GetModel()
			local class = cw.animation:GetModelClass(model)

			if (IsValid(vehicle) and !string.find(model, "/player/")) then
				if (class == "maleHuman" or class == "femaleHuman") then
					if (cw.entity:IsChairEntity(vehicle)) then
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

-- Called when a player attempts to change class.
function GM:PlayerCanChangeClass(player, class)
	local curTime = CurTime()

	if (player.cwNextChangeClass and curTime < player.cwNextChangeClass) then
		cw.player:Notify(player, L(player, "CannotChangeClassFor",
			math.ceil(player.cwNextChangeClass - curTime))
		)

		return false
	else
		return true
	end
end

-- Called when a player attempts to earn wages cash.
function GM:PlayerCanEarnWagesCash(player, cash)
	return true
end

-- Called when a player is given wages cash.
function GM:PlayerGiveWagesCash(player, cash, wagesName)
	return true
end

-- Called when a player earns wages cash.
function GM:PlayerEarnWagesCash(player, cash) end

-- Called when Clockwork has loaded all of the entities.
function GM:ClockworkInitPostEntity() end

-- Called when a player attempts to say something in-character.
function GM:PlayerCanSayIC(player, text)
	if ((!player:Alive() or player:IsRagdolled(RAGDOLL_FALLENOVER)) and !cw.player:GetDeathCode(player, true)) then
		cw.player:Notify(player, L(player, "CannotActionRightNow"))

		return false
	else
		return true
	end
end

-- Called when a player attempts to say something out-of-character.
function GM:PlayerCanSayOOC(player, text) return true end

-- Called when a player attempts to say something locally out-of-character.
function GM:PlayerCanSayLOOC(player, text) return true end

-- Called when attempts to use a command.
function GM:PlayerCanUseCommand(player, commandTable, arguments)
	return true
end

-- Called when a player speaks from the client.
function GM:PlayerSay(player, text, bPublic)
	local prefix = config.Get("command_prefix"):Get()
	local prefixLength = string.len(prefix)

 	if (string.sub(text, 1, prefixLength) == prefix) then
		local arguments = cw.core:ExplodeByTags(text, " ", "\"", "\"", true)
		local command = string.sub(arguments[1], prefixLength + 1)
		local realCommand = cw.command:GetAlias()[command] or command

		return string.Replace(text, prefix..command, prefix..realCommand)
 	end
end

-- Called when a player attempts to suicide.
function GM:CanPlayerSuicide(player) return false end

-- Called when a player attempts to punt an entity with the gravity gun.
function GM:GravGunPunt(player, entity)
	return config.Get("enable_gravgun_punt"):Get()
end

-- Called when a player attempts to pickup an entity with the gravity gun.
function GM:GravGunPickupAllowed(player, entity)
	if (IsValid(entity)) then
		if (!cw.player:IsAdmin(player) and !cw.entity:IsInteractable(entity)) then
			return false
		else
			return self.BaseClass:GravGunPickupAllowed(player, entity)
		end
	end

	return false
end

-- Called when a player picks up an entity with the gravity gun.
function GM:GravGunOnPickedUp(player, entity)
	player.cwIsHoldingEnt = entity
	entity.cwIsBeingHeld = player
end

-- Called when a player drops an entity with the gravity gun.
function GM:GravGunOnDropped(player, entity)
	player.cwIsHoldingEnt = nil
	entity.cwIsBeingHeld = nil
end

-- Called when a player attempts to unfreeze an entity.
function GM:CanPlayerUnfreeze(player, entity, physicsObject)
	local bIsAdmin = cw.player:IsAdmin(player)

	if (config.Get("enable_prop_protection"):Get() and !bIsAdmin) then
		local ownerKey = entity:GetOwnerKey()

		if (ownerKey and player:GetCharacterKey() != ownerKey) then
			return false
		end
	end

	if (!bIsAdmin and !cw.entity:IsInteractable(entity)) then
		return false
	end

	if (entity:IsVehicle()) then
		if (IsValid(entity:GetDriver())) then
			return false
		end
	end

	return true
end

-- Called when a player attempts to freeze an entity with the physics gun.
function GM:OnPhysgunFreeze(weapon, physicsObject, entity, player)
	local bIsAdmin = cw.player:IsAdmin(player)

	-- Let operators freeze static entities.
	if (IsValid(entity) and entity:GetPersistent() and cw.player:HasFlags(player, "o")) then
		return BaseClass.OnPhysgunFreeze(self, weapon, physicsObject, entity, player)
	end

	if (config.GetVal("enable_prop_protection") and !bIsAdmin) then
		local ownerKey = entity:GetOwnerKey()

		if (ownerKey and player:GetCharacterKey() != ownerKey) then
			return false
		end
	end

	if (!bIsAdmin and cw.entity:IsChairEntity(entity)) then
		local entities = ents.FindInSphere(entity:GetPos(), 64)

		for k, v in pairs(entities) do
			if (cw.entity:IsDoor(v)) then
				return false
			end
		end
	end

	if (entity:GetPhysicsObject():IsPenetrating()) then
		return false
	end

	if (!bIsAdmin and entity.PhysgunDisabled) then
		return false
	end

	if (!bIsAdmin and !cw.entity:IsInteractable(entity)) then
		return false
	else
		return self.BaseClass:OnPhysgunFreeze(weapon, physicsObject, entity, player)
	end
end

-- Called when a player attempts to pickup an entity with the physics gun.
function GM:PhysgunPickup(player, entity)
	local bCanPickup = nil
	local bIsAdmin = cw.player:IsAdmin(player)

	if (!config.Get("enable_map_props_physgrab"):Get()) then
		if (cw.entity:IsMapEntity(entity)) then
			bCanPickup = false
		end
	end

	if (!bIsAdmin and !cw.entity:IsInteractable(entity)) then
		return false
	end

	if (!bIsAdmin and cw.entity:IsPlayerRagdoll(entity)) then
		return false
	end

	if (!bIsAdmin and entity:GetClass() == "prop_ragdoll") then
		local ownerKey = entity:GetOwnerKey()

		if (ownerKey and player:GetCharacterKey() != ownerKey) then
			return false
		end
	end

	if (!bIsAdmin) then
		bCanPickup = self.BaseClass:PhysgunPickup(player, entity)
	else
		bCanPickup = true
	end

	if (cw.entity:IsChairEntity(entity) and !bIsAdmin) then
		local entities = ents.FindInSphere(entity:GetPos(), 256)

		for k, v in pairs(entities) do
			if (cw.entity:IsDoor(v)) then
				return false
			end
		end
	end

	if (config.Get("enable_prop_protection"):Get() and !bIsAdmin) then
		local ownerKey = entity:GetOwnerKey()

		if (ownerKey and player:GetCharacterKey() != ownerKey) then
			bCanPickup = false
		end
	end

	if (entity:IsPlayer() and entity:InVehicle() or entity.cwObserverMode) then
		bCanPickup = false
	end

	if (bCanPickup) then
		player.cwIsHoldingEnt = entity
		entity.cwIsBeingHeld = player

		if (!entity:IsPlayer()) then
			if (config.Get("prop_kill_protection"):Get()
			and !entity.cwLastCollideGroup) then
				cw.entity:StopCollisionGroupRestore(entity)
				entity.cwLastCollideGroup = entity:GetCollisionGroup()
				entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			end

			entity.cwDamageImmunity = CurTime() + 60
		elseif (!entity.cwMoveType) then
			entity.cwMoveType = entity:GetMoveType()
			entity:SetMoveType(MOVETYPE_NOCLIP)
		end

		return true
	else
		return false
	end
end

-- Called when a player attempts to drop an entity with the physics gun.
function GM:PhysgunDrop(player, entity)
	if (!entity:IsPlayer() and entity.cwLastCollideGroup) then
		cw.entity:ReturnCollisionGroup(
			entity, entity.cwLastCollideGroup
		)

		entity.cwLastCollideGroup = nil
	elseif (entity.cwMoveType) then
		entity:SetMoveType(MOVETYPE_WALK)
		entity.cwMoveType = nil
	end

	entity.cwDamageImmunity = CurTime() + 60
	player.cwIsHoldingEnt = nil
	entity.cwIsBeingHeld = nil
end

-- Called when a player attempts to spawn an NPC.
function GM:PlayerSpawnNPC(player, model)
	if (!cw.player:HasFlags(player, "n")) then
		return false
	end

	if (!player:Alive() or player:IsRagdolled()) then
		cw.player:Notify(player, L(player, "CannotActionRightNow"))

		return false
	end

	if (!cw.player:IsAdmin(player)) then
		return false
	else
		return true
	end
end

-- Called when an NPC has been killed.
function GM:OnNPCKilled(entity, attacker, inflictor) end

-- Called to get whether an entity is being held.
function GM:GetEntityBeingHeld(entity)
	return entity.cwIsBeingHeld or entity:IsPlayerHolding()
end

-- Called when an entity is removed.
function GM:EntityRemoved(entity)
	if (!cw.core:IsShuttingDown()) then
		if (IsValid(entity)) then
			if (entity:GetClass() == "prop_ragdoll") then
				if (entity.cwIsBelongings and entity.cwInventory and entity.cwCash
				and (table.Count(entity.cwInventory) > 0 or entity.cwCash > 0)) then
					local belongings = ents.Create("cw_belongings")

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

			if (entity.cwGiveRefundTab
			and CurTime() <= entity.cwGiveRefundTab[1]) then
				if (IsValid(entity.cwGiveRefundTab[2])) then
					cw.player:GiveCash(entity.cwGiveRefundTab[2], entity.cwGiveRefundTab[3], L"PropRefund")
				end
			end

			allProperty[entIndex] = nil

			if (entity:GetClass() == "csItem") then
				item.RemoveItemEntity(entity)
			end
		end

		cw.entity:ClearProperty(entity)
	end
end

-- Called when an entity's menu option should be handled.
function GM:EntityHandleMenuOption(player, entity, option, arguments)
	local class = entity:GetClass()

	if (class == "cw_item" and (arguments == "cw.itemTake" or arguments == "cw.itemUse")) then
		if (cw.entity:BelongsToAnotherCharacter(player, entity)) then
			cw.player:Notify(player, L(player, "DroppedItemsOtherChar"))
			return
		end

		local itemTable = entity.cwItemTable
		local bQuickUse = (arguments == "cw.itemUse")

		if (itemTable) then
			local bDidPickupItem = true
			local bCanPickup = (!itemTable.CanPickup or itemTable:CanPickup(player, bQuickUse, entity))

			if (bCanPickup != false) then
				player:SetItemEntity(entity)

				if (bQuickUse) then
					itemTable = player:GiveItem(itemTable, true)

					if (!cw.player:InventoryAction(player, itemTable, "use")) then
						player:TakeItem(itemTable, true)
						bDidPickupItem = false
					else
						player:FakePickup(entity)
					end
				else
					local bSuccess, fault = player:GiveItem(itemTable)

					if (!bSuccess) then
						cw.player:Notify(player, fault)
						bDidPickupItem = false
					else
						player:FakePickup(entity)
					end
				end

				hook.Run(
					"PlayerPickupItem", player, itemTable, entity, bQuickUse
				)

				if (bDidPickupItem) then
					if (!itemTable.OnPickup or itemTable:OnPickup(player, bQuickUse, entity) != false) then
						entity:Remove()
					end
				end

				local pickupSound = itemTable.pickupSound or "physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav"

				if (type(pickupSound) == "table") then
					pickupSound = pickupSound[math.random(1, #pickupSound)]
				end

				player:EmitSound(pickupSound)

				player:SetItemEntity(nil)
			end

		end
	elseif (class == "cw_item" and arguments == "cw.itemExamine") then
		local itemTable = entity.cwItemTable
		local examineText = itemTable.description

		if (itemTable.GetEntityExamineText) then
			examineText = itemTable:GetEntityExamineText(entity)
		end

		cw.player:Notify(player, examineText)
	elseif (class == "cw_item" and arguments == "cw.itemAmmo") then
		local itemTable = entity.cwItemTable

		if (item.IsWeapon(itemTable)) then
			if (itemTable:HasSecondaryClip() or itemTable:HasPrimaryClip()) then
				local clipOne = itemTable:GetData("ClipOne")
				local clipTwo = itemTable:GetData("ClipTwo")

				if (clipTwo > 0) then
					player:GiveAmmo(clipTwo, itemTable.secondaryAmmoClass)
				end

				if (clipOne > 0) then
					player:GiveAmmo(clipOne, itemTable.primaryAmmoClass)
				end

				itemTable:SetData("ClipOne", 0)
				itemTable:SetData("ClipTwo", 0)

				player:FakePickup(entity)
			end
		end
	elseif (class == "cw_item") then
		local itemTable = entity.cwItemTable

		if (itemTable and itemTable.EntityHandleMenuOption) then
			itemTable:EntityHandleMenuOption(player, entity, option, arguments)
		end
	elseif (entity:GetClass() == "cw_belongings" and arguments == "cwBelongingsOpen") then
		player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav")

		cw.storage:Open(player, {
			name = "Belongings",
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
				if (IsValid(entity)) then
					if ((!entity.cwInventory and !entity.cwCash)
					or (table.Count(entity.cwInventory) == 0 and entity.cwCash == 0)) then
						entity:Explode(entity:BoundingRadius() * 2)
						entity:Remove()
					end
				end
			end,
			CanGiveItem = function(player, storageTable, itemTable)
				return false
			end
		})
	elseif (class == "cw_shipment" and arguments == "cwShipmentOpen") then
		player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav")
		player:FakePickup(entity)

		cw.storage:Open(player, {
			name = "Shipment",
			weight = entity.cwWeight,
			space = entity.cwSpace,
			entity = entity,
			distance = 192,
			inventory = entity.cwInventory,
			isOneSided = true,
			OnClose = function(player, storageTable, entity)
				if (IsValid(entity) and cw.inventory:IsEmpty(entity.cwInventory)) then
					entity:Explode(entity:BoundingRadius() * 2)
					entity:Remove()
				end
			end,
			CanGiveItem = function(player, storageTable, itemTable)
				return false
			end
		})
	elseif (class == "cw_cash" and arguments == "cwCashTake") then
		if (cw.entity:BelongsToAnotherCharacter(player, entity)) then
			cw.player:Notify(player, L(player, "DroppedCashOtherChar", cw.option:GetKey("name_cash", true)))
			return
		end

		cw.player:GiveCash(player, entity.cwAmount, cw.option:GetKey("name_cash"))
		player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav")
		player:FakePickup(entity)

		entity:Remove()
	end
end

-- Called when a player has spawned a prop.
function GM:PlayerSpawnedProp(player, model, entity)
	if (IsValid(entity)) then
		local scalePropCost = config.Get("scale_prop_cost"):Get()

		if (player.cwObserverMode) then scalePropCost = 0 end

		if (scalePropCost > 0) then
			local cost = math.ceil(math.max((entity:BoundingRadius() / 2) * scalePropCost, 1))
			local info = {cost = cost, name = "Prop"}

			hook.Run("PlayerAdjustPropCostInfo", player, entity, info)

			if (cw.player:CanAfford(player, info.cost)) then
				cw.player:GiveCash(player, -info.cost, info.name)
				entity.cwGiveRefundTab = {CurTime() + 10, player, info.cost}
			else
				cw.player:Notify(player, L(player, "YouNeedAnother", cw.core:FormatCash(info.cost - player:GetCash(), nil, true)))
				entity:Remove()
				return
			end
		end

		if (IsValid(entity)) then
			self.BaseClass:PlayerSpawnedProp(player, model, entity)
			entity:SetOwnerKey(player:GetCharacterKey())

			if (IsValid(entity)) then
				cw.core:PrintLog(LOGTYPE_URGENT, player:Name().." has spawned '"..tostring(model).."'.")

				if (config.Get("prop_kill_protection"):Get()) then
					entity.cwDamageImmunity = CurTime() + 60
				end
			end
		end
	end
end

-- Called when a player attempts to spawn a prop.
function GM:PlayerSpawnProp(player, model)
	if (!cw.player:HasFlags(player, "e")) then
		return false
	end

	if (!player:Alive() or player:IsRagdolled()) then
		cw.player:Notify(player, L(player, "CannotActionRightNow"))
		return false
	end

	if (cw.player:IsAdmin(player)) then
		return true
	end

	return self.BaseClass:PlayerSpawnProp(player, model)
end

-- Called when a player attempts to spawn a ragdoll.
function GM:PlayerSpawnRagdoll(player, model)
	if (!cw.player:HasFlags(player, "r")) then return false end

	if (!player:Alive() or player:IsRagdolled()) then
		cw.player:Notify(player, L(player, "CannotActionRightNow"))

		return false
	end

	if (!cw.player:IsAdmin(player)) then
		return false
	else
		return true
	end
end

-- Called when a player attempts to spawn an effect.
function GM:PlayerSpawnEffect(player, model)
	if (!player:Alive() or player:IsRagdolled()) then
		cw.player:Notify(player, L(player, "CannotActionRightNow"))

		return false
	end

	if (!cw.player:IsAdmin(player)) then
		return false
	else
		return true
	end
end

-- Called when a player attempts to spawn a vehicle.
function GM:PlayerSpawnVehicle(player, model)
	if (!string.find(model, "chair") and !string.find(model, "seat")) then
		if (!cw.player:HasFlags(player, "C")) then
			return false
		end
	elseif (!cw.player:HasFlags(player, "c")) then
		return false
	end

	if (!player:Alive() or player:IsRagdolled()) then
		cw.player:Notify(player, L(player, "CannotActionRightNow"))

		return false
	end

	if (cw.player:IsAdmin(player)) then
		return true
	end

	return self.BaseClass:PlayerSpawnVehicle(player, model)
end

-- Called when a player attempts to use a tool.
function GM:CanTool(player, trace, tool)
	local bIsAdmin = cw.player:IsAdmin(player)

	if (IsValid(trace.Entity)) then
		local bPropProtectionEnabled = config.Get("enable_prop_protection"):Get()
		local characterKey = player:GetCharacterKey()

		if (!bIsAdmin and !cw.entity:IsInteractable(trace.Entity)) then
			return false
		end

		if (!bIsAdmin and cw.entity:IsPlayerRagdoll(trace.Entity)) then
			return false
		end

		if (bPropProtectionEnabled and !bIsAdmin) then
			local ownerKey = trace.Entity:GetOwnerKey()

			if (ownerKey and characterKey != ownerKey) then
				return false
			end
		end

		if (!bIsAdmin) then
			if (tool == "nail") then
				local newTrace = {}

				newTrace.start = trace.HitPos
				newTrace.endpos = trace.HitPos + player:GetAimVector() * 16
				newTrace.filter = {player, trace.Entity}

				newTrace = util.TraceLine(newTrace)

				if (IsValid(newTrace.Entity)) then
					if (!cw.entity:IsInteractable(newTrace.Entity) or cw.entity:IsPlayerRagdoll(newTrace.Entity)) then
						return false
					end

					if (bPropProtectionEnabled) then
						local ownerKey = newTrace.Entity:GetOwnerKey()

						if (ownerKey and characterKey != ownerKey) then
							return false
						end
					end
				end
			elseif (tool == "remover" and player:KeyDown(IN_ATTACK2) and !player:KeyDownLast(IN_ATTACK2)) then
				if (!trace.Entity:IsMapEntity()) then
					local entities = constraint.GetAllConstrainedEntities(trace.Entity)

					for k, v in pairs(entities) do
						if (v:IsMapEntity() or cw.entity:IsPlayerRagdoll(v)) then
							return false
						end

						if (bPropProtectionEnabled) then
							local ownerKey = v:GetOwnerKey()

							if (ownerKey and characterKey != ownerKey) then
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

	if (!bIsAdmin) then
		if (tool == "dynamite" or tool == "duplicator") then
			return false
		end

		return self.BaseClass:CanTool(player, trace, tool)
	else
		return true
	end
end

-- Called when a player attempts to use the property menu.
function GM:CanProperty(player, property, entity)
	local bIsAdmin = cw.player:IsAdmin(player)

	if (!player:Alive() or player:IsRagdolled() or !bIsAdmin) then
		return false
	end

	return self.BaseClass:CanProperty(player, property, entity)
end

-- Called when a player attempts to use drive.
function GM:CanDrive(player, entity)
	local bIsAdmin = cw.player:IsAdmin(player)

	if (!player:Alive() or player:IsRagdolled() or !bIsAdmin) then
		return false
	end

	return self.BaseClass:CanDrive(player, entity)
end

-- Called when a player attempts to NoClip.
function GM:PlayerNoClip(player)
	if (player:IsRagdolled()) then
		return false
	elseif (player:IsSuperAdmin()) then
		return true
	else
		return false
	end
end

-- Called when a player's character has initialized.
function GM:PlayerCharacterInitialized(player)
	netstream.Start(player, "InvClear", true)
	netstream.Start(player, "AttrClear", true)
	netstream.Start(player, "ReceiveLimbDamage", player:GetCharacterData("LimbData"))

	if (!cw.class:FindByID(player:Team()) and !player:GetCharacterData("Class")) then
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
		"Directory",
		"Give Name",
		"Target Recognises",
		"Raise Weapon"
	}

	for k, v in pairs(starterHintsTable) do
		local hintTable = cw.hint:Find(v)

		if (hintTable and !player:GetData("Hint"..k)) then
			if (!hintTable.Callback or hintTable.Callback(player) != false) then
				timer.Simple(startHintsDelay, function()
					if (IsValid(player)) then
						cw.hint:Send(player, hintTable.text, 30)
						player:SetData("Hint"..k, true)
					end
				end)

				startHintsDelay = startHintsDelay + 30
			end
		end
	end

	if (startHintsDelay > 4) then
		player.cwViewStartHints = true

		timer.Simple(startHintsDelay, function()
			if (IsValid(player)) then
				player.cwViewStartHints = false
			end
		end)
	end

	timer.Simple(FrameTime() * 0.5, function()
		cw.inventory:SendUpdateAll(player)
		player:NetworkAccessories()
	end)

	netstream.Start(player, "CharacterInit", player:GetCharacterKey())

	local playerFaction = player:GetFaction()
	local spawnRank = _faction.GetDefaultRank(playerFaction) or _faction.GetLowestRank(playerFaction)

	player:SetFactionRank(player:GetFactionRank() or spawnRank)

	if (string.find(player:Name(), "SCN")) then
		player:SetFactionRank("SCN")
	end

	local rankName, rankTable = player:GetFactionRank()

	if (rankTable) then
		if (rankTable.class and cw.class:GetAll()[rankTable.class]) then

			cw.class:Set(player, rankTable.class)
		end

		if (rankTable.model) then
			player:SetModel(rankTable.model)
		end
	end
end

-- Called when a player has used their death code.
function GM:PlayerDeathCodeUsed(player, commandTable, arguments) end

-- Called when a player has created a character.
function GM:PlayerCharacterCreated(player, character) end

-- Called when a player's character has unloaded.
function GM:PlayerCharacterUnloaded(player)
	cw.player:SetupRemovePropertyDelays(player)
	cw.player:DisableProperty(player)
	cw.player:SetRagdollState(player, RAGDOLL_RESET)
	cw.storage:Close(player, true)
	player:SetTeam(TEAM_UNASSIGNED)
end

-- Called when a player's character has loaded.
function GM:PlayerCharacterLoaded(player)
	player:SetNetVar("InvWeight", config.Get("default_inv_weight"):Get())
	player:SetNetVar("InvSpace", config.Get("default_inv_space"):Get())
	player.cwCharLoadedTime = CurTime()
	player.cwCrouchedSpeed = config.Get("crouched_speed"):Get()
	player.cwClipTwoInfo = {weapon = NULL, ammo = 0}
	player.cwClipOneInfo = {weapon = NULL, ammo = 0}
	player.cwInitialized = true
	player.cwAttrBoosts = player.cwAttrBoosts or {}
	player.cwRagdollTab = player.cwRagdollTab or {}
	player.cwSpawnWeps = player.cwSpawnWeps or {}
	player.cwFirstSpawn = true
	player.cwLightSpawn = false
	player.cwChangeClass = false
	player.cwInfoTable = player.cwInfoTable or {}
	player.cwSpawnAmmo = player.cwSpawnAmmo or {}
	player.cwJumpPower = config.Get("jump_power"):Get()
	player.cwWalkSpeed = config.Get("walk_speed"):Get()
	player.cwRunSpeed = config.Get("run_speed"):Get()

	hook.Run("PlayerRestoreCharacterData", player, player:QueryCharacter("Data"))

	cw.player:SetCharacterMenuState(player, CHARACTER_MENU_CLOSE)

	hook.Run("PlayerCharacterInitialized", player)

	cw.player:RestoreRecognisedNames(player)
	cw.player:ReturnProperty(player)
	cw.player:SetInitialized(player, true)

	player.cwFirstSpawn = false

	local charactersTable = config.Get("mysql_characters_table"):Get()
	local schemaFolder = cw.core:GetSchemaFolder()
	local characterID = player:GetCharacterID()
	local onNextLoad = player:QueryCharacter("OnNextLoad")
	local steamID = player:SteamID()
	local query = "UPDATE "..charactersTable.." SET _OnNextLoad = \"\" WHERE"
	local playerFlags = player:GetPlayerFlags()

	if (onNextLoad != "") then
		local queryObj = cw.database:Update(charactersTable)
			queryObj:Update("_OnNextLoad", "")
			queryObj:Where("_Schema", schemaFolder)
			queryObj:Where("_SteamID", steamID)
			queryObj:Where("_CharacterID", characterID)
		queryObj:Execute()

		player:SetCharacterData("OnNextLoad", "", true)

		CHARACTER = player:GetCharacter()
			PLAYER = player
				RunString(onNextLoad, md5.sumhexa(onNextLoad))
			PLAYER = nil
		CHARACTER = nil
	end

	local itemsList = cw.inventory:GetAsItemsList(
		player:GetInventory()
	)

	for k, v in pairs(itemsList) do
		if (v.OnRestorePlayerGear) then
			v:OnRestorePlayerGear(player)
		end
	end

	if (playerFlags) then
		cw.player:GiveFlags(player, playerFlags)
	end

	local className = player:GetCharacterData("Class")

	if (className) then
		local class = cw.class:FindByID(className)

		cw.class:Set(player, class.index, nil, true)
	end
end

-- Called when a player's property should be restored.
function GM:PlayerReturnProperty(player) end

-- Called when config has initialized for a player.
function GM:PlayerConfigInitialized(player)
	hook.Run("PlayerSendDataStreamInfo", player)

	if (!player:IsBot()) then
		timer.Simple(FrameTime() * 32, function()
			if (IsValid(player)) then
				netstream.Start(player, "DataStreaming", true)
			end
		end)
	else
		hook.Run("PlayerDataStreamInfoSent", player)
	end
end

-- Called when a player has used their radio.
function GM:PlayerRadioUsed(player, text, listeners, eavesdroppers) end

-- Called when a player's drop weapon info should be adjusted.
function GM:PlayerAdjustDropWeaponInfo(player, info)
	return true
end

-- Called when a player's character creation info should be adjusted.
function GM:PlayerAdjustCharacterCreationInfo(player, info, data) end

-- Called when a player's order item should be adjusted.
function GM:PlayerAdjustOrderItemTable(player, itemTable) end

-- Called when a player's next punch info should be adjusted.
function GM:PlayerAdjustNextPunchInfo(player, info) end

-- Called when a player uses an unknown item function.
function GM:PlayerUseUnknownItemFunction(player, itemTable, itemFunction) end

-- Called when a player's character table should be adjusted.
function GM:PlayerAdjustCharacterTable(player, character) end

-- Called when a player's character screen info should be adjusted.
function GM:PlayerAdjustCharacterScreenInfo(player, character, info)
	local playerRank, rank = player:GetFactionRank()

	if (rank and rank.model) then
		info.model = rank.model
	end
end

-- Called when a player's prop cost info should be adjusted.
function GM:PlayerAdjustPropCostInfo(player, entity, info) end

-- Called when a player's death info should be adjusted.
function GM:PlayerAdjustDeathInfo(player, info) end

-- Called when chat box info should be adjusted.
function GM:ChatBoxAdjustInfo(info)
	if (info.class == "ic") then
		cw.core:PrintLog(LOGTYPE_GENERIC, info.speaker:Name().." says: \""..info.text.."\"")
	elseif (info.class == "looc") then
		cw.core:PrintLog(LOGTYPE_GENERIC, "[LOOC] "..info.speaker:Name()..": "..info.text)
	end
end

-- Called when a player's radio text should be adjusted.
function GM:PlayerAdjustRadioInfo(player, info) end

-- Called when a player should gain a frag.
function GM:PlayerCanGainFrag(player, victim) return true end

-- Called just after a player spawns.
function GM:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)	
	if (firstSpawn) then
		local attrBoosts = player:GetCharacterData("AttrBoosts")
		local health = player:GetCharacterData("Health")
		local armor = player:GetCharacterData("Armor")

		if (health and health > 1) then
			player:SetHealth(health)
		end

		if (armor and armor > 1) then
			player:SetArmor(armor)
		end

		if (attrBoosts) then
			for k, v in pairs(attrBoosts) do
				for k2, v2 in pairs(v) do
					cw.attributes:Boost(player, k2, k, v2.amount, v2.duration)
				end
			end
		end
	else
		player:SetCharacterData("AttrBoosts", nil)
		player:SetCharacterData("Health", nil)
		player:SetCharacterData("Armor", nil)
	end

	player:Fire("targetname", player:GetFaction(), 0)
end

-- Called just before a player would take damage.
function GM:PrePlayerTakeDamage(player, attacker, inflictor, damageInfo) end

-- Called when a player should take damage.
function GM:PlayerShouldTakeDamage(player, attacker, inflictor, damageInfo)
	return !cw.player:IsNoClipping(player)
end

-- Called when a player is attacked by a trace.
function GM:PlayerTraceAttack(player, damageInfo, direction, trace)
	player.cwLastHitGroup = trace.HitGroup
	return false
end

-- Called just before a player dies.
function GM:DoPlayerDeath(player, attacker, damageInfo)
	cw.player:DropWeapons(player, attacker)
	cw.player:SetAction(player, false)
	cw.player:SetDrunk(player, false)

	local deathSound = hook.Run("PlayerPlayDeathSound", player, player:GetGender())
	local decayTime = config.Get("body_decay_time"):Get()

	if (decayTime > 0) then
		cw.player:SetRagdollState(player, RAGDOLL_KNOCKEDOUT, nil, decayTime, cw.core:ConvertForce(damageInfo:GetDamageForce() * 32))
	else
		cw.player:SetRagdollState(player, RAGDOLL_KNOCKEDOUT, nil, 600, cw.core:ConvertForce(damageInfo:GetDamageForce() * 32))
	end

	if (hook.Run("PlayerCanDeathClearRecognisedNames", player, attacker, damageInfo)) then
		cw.player:ClearRecognisedNames(player)
	end

	if (hook.Run("PlayerCanDeathClearName", player, attacker, damageInfo)) then
		cw.player:ClearName(player)
	end

	if (deathSound) then
		player:EmitSound("physics/flesh/flesh_impact_hard"..math.random(1, 5)..".wav", 150)

		timer.Simple(FrameTime() * 25, function()
			if (IsValid(player)) then
				player:EmitSound(deathSound)
			end
		end)
	end

	player:SetForcedAnimation(false)
	player:SetCharacterData("Ammo", {}, true)
	player:StripWeapons()
	player:Extinguish()
	player.cwSpawnAmmo = {}
	player:StripAmmo()
	player:AddDeaths(1)
	player:UnLock()

	if (IsValid(attacker) and attacker:IsPlayer() and player != attacker) then
		if (hook.Run("PlayerCanGainFrag", attacker, player)) then
			attacker:AddFrags(1)
		end
	end
end

-- Called when a player dies.
function GM:PlayerDeath(player, inflictor, attacker, damageInfo)

	cw.core:CalculateSpawnTime(player, inflictor, attacker, damageInfo)

	local ragdoll = player:GetRagdollEntity()

	if (ragdoll) then		
		if (IsValid(inflictor) and inflictor:GetClass() == "prop_combine_ball") then
			if (damageInfo) then
				cw.entity:Disintegrate(ragdoll, 3, damageInfo:GetDamageForce() * 32)
			else
				cw.entity:Disintegrate(ragdoll, 3)
			end
		end
	end

	if (attacker:IsPlayer() and damageInfo) then
		if (IsValid(attacker:GetActiveWeapon())) then
			local weapon = attacker:GetActiveWeapon()
			local itemTable = item.GetByWeapon(weapon)

			if (IsValid(weapon) and itemTable) then
				cw.core:PrintLog(LOGTYPE_CRITICAL, attacker:Name().." has dealt "..tostring(math.ceil(damageInfo:GetDamage())).." damage to "..player:Name().." with "..itemTable.name..", killing them!")
			else
				cw.core:PrintLog(LOGTYPE_CRITICAL, attacker:Name().." has dealt "..tostring(math.ceil(damageInfo:GetDamage())).." damage to "..player:Name().." with "..cw.player:GetWeaponClass(attacker)..", killing them!")
			end
		else
			cw.core:PrintLog(LOGTYPE_CRITICAL, attacker:Name().." has dealt "..tostring(math.ceil(damageInfo:GetDamage())).." damage to "..player:Name()..", killing them!")
		end
	else
		if (damageInfo) then
			cw.core:PrintLog(LOGTYPE_CRITICAL, attacker:GetClass().." has dealt "..tostring(math.ceil(damageInfo:GetDamage())).." damage to "..player:Name()..", killing them!")
		end
	end
end

-- Called when an item entity has taken damage.
function GM:ItemEntityTakeDamage(itemEntity, itemTable, damageInfo)
	return false
end

-- Called when an item entity has been destroyed.
function GM:ItemEntityDestroyed(itemEntity, itemTable) end

-- Called when an item's network observers are needed.
function GM:ItemGetNetworkObservers(itemTable, info)
	local uniqueID = itemTable.uniqueID
	local itemID = itemTable.itemID
	local entity = item.FindEntityByInstance(itemTable)

	if (entity) then
		info.sendToAll = true
		return false
	end

	for k, v in ipairs(_player.GetAll()) do
		if (v:HasInitialized()) then
			local inventory = cw.storage:Query(v, "inventory")

			if ((inventory and inventory[uniqueID]
			and inventory[uniqueID][itemID]) or v:HasItemInstance(itemTable)) then
				info.observers[v] = v
			elseif (v:HasItemAsWeapon(itemTable)) then
				info.observers[v] = v
			end
		end
	end
end

-- Called when a player's weapons should be given.
function GM:PlayerLoadout(player)
	local weapons = cw.class:Query(player:Team(), "weapons")
	local ammo = cw.class:Query(player:Team(), "ammo")

	player.cwSpawnWeps = {}
	player.cwSpawnAmmo = {}

	if (cw.player:HasFlags(player, "t")) then
		cw.player:GiveSpawnWeapon(player, "gmod_tool")
	end

	if (cw.player:HasFlags(player, "p")) then
		cw.player:GiveSpawnWeapon(player, "weapon_physgun")

		if (config.Get("custom_weapon_color"):Get()) then
			local weaponColor = player:GetInfo("cl_weaponcolor")

			player:SetWeaponColor(Vector(weaponColor))
		end
	end

	cw.player:GiveSpawnWeapon(player, "weapon_physcannon")

	if (config.Get("give_hands"):Get()) then
		cw.player:GiveSpawnWeapon(player, "cw_hands")
	end

	if (config.Get("give_keys"):Get()) then
		cw.player:GiveSpawnWeapon(player, "cw_keys")
	end

	if (weapons) then
		for k, v in pairs(weapons) do
			if (!player:HasItemByID(v)) then
				local itemTable = item.CreateInstance(v)

				if (!cw.player:GiveSpawnItemWeapon(player, itemTable)) then
					player:Give(v)
				end
			end
		end
	end

	if (ammo) then
		for k, v in pairs(ammo) do
			cw.player:GiveSpawnAmmo(player, k, v)
		end
	end

	hook.Run("PlayerGiveWeapons", player)

	if (config.Get("give_hands"):Get()) then
		player:SelectWeapon("cw_hands")
	end
end

-- Called when the server shuts down.
function GM:ShutDown()
	hook.Run("PreSaveData")
		hook.Run("SaveData")
	hook.Run("PostSaveData")

	cw.ShuttingDown = true
end

-- Called when a player presses F1.
function GM:ShowHelp(player)
	netstream.Start(player, "InfoToggle", true)
end

-- Called when a player presses F2.
function GM:ShowTeam(ply)
	if (!cw.player:IsNoClipping(ply)) then
		local doRecogniseMenu = true
		local entity = ply:GetEyeTraceNoCursor().Entity
		local plyTable = _player.GetAll()

		if (IsValid(entity) and cw.entity:IsDoor(entity)) then
			if (entity:GetPos():Distance(ply:GetShootPos()) <= 192) then
				if (hook.Run("PlayerCanViewDoor", ply, entity)) then
					if (hook.Run("PlayerUse", ply, entity)) then
						local owner = cw.entity:GetOwner(entity)

						if (IsValid(owner)) then
							if (cw.player:HasDoorAccess(ply, entity, DOOR_ACCESS_COMPLETE)) then
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
									if (v != ply and v != owner) then
										if (cw.player:HasDoorAccess(v, entity, DOOR_ACCESS_COMPLETE)) then
											data.accessList[v] = DOOR_ACCESS_COMPLETE
										elseif (cw.player:HasDoorAccess(v, entity, DOOR_ACCESS_BASIC)) then
											data.accessList[v] = DOOR_ACCESS_BASIC
										end
									end
								end

								netstream.Start(ply, "DoorManagement", data)
							end
						else
							netstream.Start(ply, "PurchaseDoor", entity)
						end
					end
				end

				doRecogniseMenu = false
			end
		end

		if (config.Get("recognise_system"):Get()) then
			if (doRecogniseMenu) then
				netstream.Start(ply, "RecogniseMenu", true)
			end
		end
	end
end

-- Called when a player selects a custom character option.
function GM:PlayerSelectCustomCharacterOption(player, action, character) end

-- Called when a player takes damage.
function GM:PlayerTakeDamage(player, inflictor, attacker, hitGroup, damageInfo)
	if (damageInfo:IsBulletDamage() and cw.event:CanRun("limb_damage", "stumble")) then
		if (hitGroup == HITGROUP_LEFTLEG or hitGroup == HITGROUP_RIGHTLEG) then
			local rightLeg = cw.limb:GetDamage(player, HITGROUP_RIGHTLEG)
			local leftLeg = cw.limb:GetDamage(player, HITGROUP_LEFTLEG)

			if (rightLeg > 50 and leftLeg > 50 and !player:IsRagdolled()) then
				cw.player:SetRagdollState(
					player, RAGDOLL_FALLENOVER, 8, nil, cw.core:ConvertForce(damageInfo:GetDamageForce() * 32)
				)
				damageInfo:ScaleDamage(0.25)
			end
		end
	end
end

-- Called when an entity takes damage.
function GM:EntityTakeDamage(entity, damageInfo)

	--[[if (entity:IsPlayer() and damageInfo:IsExplosionDamage() and !entity:IsRagdolled()) then
		local data = {}
			data.start = damageInfo:GetDamagePosition()
			data.endpos = entity:GetPos()
		local trace = util.TraceLine(data)

		cw.player:SetRagdollState(entity, RAGDOLL_FALLENOVER, nil, nil, nil, nil, function(physicsObject, boneIndex, ragdoll, velocity, force)
			physicsObject:SetVelocity(trace.Normal * damageInfo:GetReportedPosition())
		end)
		entity:SetDTBool(BOOL_FALLENOVER, true)
		entity:SetDSP(36, false)
	end]]

	if (cw.core:DoEntityTakeDamageHook(entity, damageInfo)) then
		return
	end

	local inflictor = damageInfo:GetInflictor()
	local attacker = damageInfo:GetAttacker()
	local amount = damageInfo:GetDamage()

	if (config.Get("prop_kill_protection"):Get()) then
		local curTime = CurTime()

		if ((IsValid(inflictor) and inflictor.cwDamageImmunity and inflictor.cwDamageImmunity > curTime and !inflictor:IsVehicle())
		or (IsValid(attacker) and attacker.cwDamageImmunity and attacker.cwDamageImmunity > curTime)) then
			entity.cwDamageImmunity = curTime + 1

			damageInfo:SetDamage(0)
			return false
		end

		if (IsValid(attacker) and attacker:GetClass() == "worldspawn"
		and entity.cwDamageImmunity and entity.cwDamageImmunity > curTime) then
			damageInfo:SetDamage(0)
			return false
		end

		if ((IsValid(inflictor) and inflictor:IsBeingHeld())
		or attacker:IsBeingHeld()) then
			damageInfo:SetDamage(0)
			return false
		end
	end

	if (entity:IsPlayer() and entity:InVehicle() and !IsValid(entity:GetVehicle():GetParent())) then
		entity.cwLastHitGroup = cw.core:GetRagdollHitBone(entity, damageInfo:GetDamagePosition(), HITGROUP_GEAR)

		if (damageInfo:IsBulletDamage()) then
			if ((attacker:IsPlayer() or attacker:IsNPC()) and attacker != player) then
				damageInfo:ScaleDamage(10000)
			end
		end
	end

	if (damageInfo:GetDamage() == 0) then
		return
	end

	local isPlayerRagdoll = cw.entity:IsPlayerRagdoll(entity)
	local player = cw.entity:GetPlayer(entity)

	if (player and (entity:IsPlayer() or isPlayerRagdoll)) then
		if (damageInfo:IsFallDamage() or config.Get("damage_view_punch"):Get()) then
			player:ViewPunch(
				Angle(math.random(amount, amount), math.random(amount, amount), math.random(amount, amount))
			)
		end

		if (!isPlayerRagdoll) then
			if (damageInfo:IsDamageType(DMG_CRUSH) and damageInfo:GetDamage() < 10) then
				damageInfo:SetDamage(0)
			else
				local lastHitGroup = player:LastHitGroup()
				local killed = nil

				if (player:InVehicle() and damageInfo:IsExplosionDamage()) then
					if (!damageInfo:GetDamage() or damageInfo:GetDamage() == 0) then
						damageInfo:SetDamage(player:GetMaxHealth())
					end
				end

				self:ScaleDamageByHitGroup(player, attacker, lastHitGroup, damageInfo, amount)

				if (damageInfo:GetDamage() > 0) then
					cw.core:CalculatePlayerDamage(player, lastHitGroup, damageInfo)
					player:SetVelocity(cw.core:ConvertForce(damageInfo:GetDamageForce() * 32, 200))

					if (player:Alive() and player:Health() == 1) then
						player:SetFakingDeath(true)
							hook.Run("DoPlayerDeath", player, attacker, damageInfo)
							hook.Run("PlayerDeath", player, inflictor, attacker, damageInfo)
							cw.core:CreateBloodEffects(damageInfo:GetDamagePosition(), 1, player, damageInfo:GetDamageForce())
						player:SetFakingDeath(false, true)
					else
						local bNoMsg = hook.Run("PlayerTakeDamage", player, inflictor, attacker, lastHitGroup, damageInfo)
						local sound = hook.Run("PlayerPlayPainSound", player, player:GetGender(), damageInfo, lastHitGroup)

						cw.core:CreateBloodEffects(damageInfo:GetDamagePosition(), 1, player, damageInfo:GetDamageForce())

						if (sound and !bNoMsg) then
							player:EmitHitSound(sound)
						end

						local armor = "!"

						if (player:Armor() > 0) then
							armor = " and "..player:Armor().." armor!"
						end

						if (attacker:IsPlayer()) then
							cw.core:PrintLog(LOGTYPE_MAJOR, player:Name().." has taken "..tostring(math.ceil(damageInfo:GetDamage())).." damage from "..attacker:Name().." with "..cw.player:GetWeaponClass(attacker, "an unknown weapon")..", leaving them at "..player:Health().." health"..armor)
						else
							cw.core:PrintLog(LOGTYPE_MAJOR, player:Name().." has taken "..tostring(math.ceil(damageInfo:GetDamage())).." damage from "..attacker:GetClass()..", leaving them at "..player:Health().." health"..armor)
						end
					end
				end

				damageInfo:SetDamage(0)
				player.cwLastHitGroup = nil
			end
		else
			local hitGroup = cw.core:GetRagdollHitGroup(entity, damageInfo:GetDamagePosition())
			local curTime = CurTime()
			local killed = nil

			self:ScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, amount)

			if (hook.Run("PlayerRagdollCanTakeDamage", player, entity, inflictor, attacker, hitGroup, damageInfo)
			and damageInfo:GetDamage() > 0) then
				if (!attacker:IsPlayer()) then
					if (attacker:GetClass() == "prop_ragdoll" or cw.entity:IsDoor(attacker)
					or damageInfo:GetDamage() < 5) then
						return
					end
				end

				if (damageInfo:GetDamage() >= 10 or damageInfo:IsBulletDamage()) then
					cw.core:CreateBloodEffects(damageInfo:GetDamagePosition(), 1, entity, damageInfo:GetDamageForce())
				end

				cw.core:CalculatePlayerDamage(player, hitGroup, damageInfo)

				if (player:Alive() and player:Health() == 1) then
					player:SetFakingDeath(true)
						player:GetRagdollTable().health = 0
						player:GetRagdollTable().armor = 0

						hook.Run("DoPlayerDeath", player, attacker, damageInfo)
						hook.Run("PlayerDeath", player, inflictor, attacker, damageInfo)
					player:SetFakingDeath(false, true)
				elseif (player:Alive()) then
					local bNoMsg = hook.Run("PlayerTakeDamage", player, inflictor, attacker, hitGroup, damageInfo)
					local sound = hook.Run("PlayerPlayPainSound", player, player:GetGender(), damageInfo, hitGroup)

					if (sound and !bNoMsg) then
						entity:EmitHitSound(sound)
					end

					local armor = "!"

					if (player:Armor() > 0) then
						armor = " and "..player:Armor().." armor!"
					end

					if (attacker:IsPlayer()) then
						cw.core:PrintLog(LOGTYPE_MAJOR, player:Name().." has taken "..tostring(math.ceil(damageInfo:GetDamage())).." damage from "..attacker:Name().." with "..cw.player:GetWeaponClass(attacker, "an unknown weapon")..", leaving them at "..player:Health().." health"..armor)
					else
						cw.core:PrintLog(LOGTYPE_MAJOR, player:Name().." has taken "..tostring(math.ceil(damageInfo:GetDamage())).." damage from "..attacker:GetClass()..", leaving them at "..player:Health().." health"..armor)
					end
				end
			end

			damageInfo:SetDamage(0)
		end
	elseif (entity:GetClass() == "prop_ragdoll") then
		if (damageInfo:GetDamage() >= 20 or damageInfo:IsBulletDamage()) then
			if (!string.find(entity:GetModel(), "matt") and !string.find(entity:GetModel(), "gib")) then
				local matType = util.QuickTrace(entity:GetPos(), entity:GetPos()).MatType

				if (matType == MAT_FLESH or matType == MAT_BLOODYFLESH) then
					cw.core:CreateBloodEffects(damageInfo:GetDamagePosition(), 1, entity, damageInfo:GetDamageForce())
				end
			end
		end

		if (inflictor:GetClass() == "prop_combine_ball") then
			if (!entity.disintegrating) then
				cw.entity:Disintegrate(entity, 3, damageInfo:GetDamageForce())

				entity.disintegrating = true
			end
		end
	elseif (entity:IsNPC()) then
		if (attacker:IsPlayer() and IsValid(attacker:GetActiveWeapon())
		and cw.player:GetWeaponClass(attacker) == "weapon_crowbar") then
			damageInfo:ScaleDamage(0.25)
		end
	end
end

-- Called when the death sound for a player should be played.
function GM:PlayerDeathSound(player) return true end

-- Called when a player attempts to spawn a SWEP.
function GM:PlayerSpawnSWEP(player, class, weapon)
	if (!player:IsSuperAdmin()) then
		return false
	else
		return true
	end
end

-- Called when a player is given a SWEP.
function GM:PlayerGiveSWEP(player, class, weapon)
	if (!player:IsSuperAdmin()) then
		return false
	else
		return true
	end
end

-- Called when attempts to spawn a SENT.
function GM:PlayerSpawnSENT(player, class)
	if (!player:IsSuperAdmin()) then
		return false
	else
		return true
	end
end

-- Called when a player presses a key.
function GM:KeyPress(player, key)
	if (key == IN_USE) then
		local trace = player:GetEyeTraceNoCursor()

		if (IsValid(trace.Entity) and trace.HitPos:Distance(player:GetShootPos()) <= 192) then
			if (hook.Run("PlayerUse", player, trace.Entity)) then
				if (cw.entity:IsDoor(trace.Entity) and !trace.Entity:HasSpawnFlags(256)
				and !trace.Entity:HasSpawnFlags(8192) and !trace.Entity:HasSpawnFlags(32768)) then
					if (hook.Run("PlayerCanUseDoor", player, trace.Entity)) then
						hook.Run("PlayerUseDoor", player, trace.Entity)
						cw.entity:OpenDoor(trace.Entity, 0, nil, nil, player:GetPos())
					end
				elseif (trace.Entity.UsableInVehicle) then
					if (player:InVehicle()) then
						if (trace.Entity.Use) then
							trace.Entity:Use(player, player)

							player.cwNextExitVehicle = CurTime() + 1
						end
					end
				end
			end
		end
	elseif (key == IN_WALK) then
		local velocity = player:GetVelocity():Length()

		if (velocity == 0 and player:KeyDown(IN_SPEED)) then
			if (player:Crouching()) then
				player:RunCommand("-duck")
			else
				player:RunCommand("+duck")
			end
		end
	end
end

--[[
	@codebase Server
	@details Called when a player presses a button down.
	@param Player The player that is pressing a button.
	@param Enum The button that was pressed.
--]]
function GM:PlayerButtonDown(player, button)
	if (button == KEY_B) then
		if (config.Get("quick_raise_enabled"):GetBoolean()) then
			if (hook.Run("PlayerCanQuickRaise", player, player:GetActiveWeapon())) then
				cw.player:ToggleWeaponRaised(player)
			end
		end
	end

	return self.BaseClass:PlayerButtonDown(player, button)
end

--[[
	@codebase Server
	@details Called to determine whether or not a player can quickly raise their weapon by pressing the x button.
	@param Player The player that is attempting to quickly raise their weapon.
	@param Weapon The player's current active weapon.
--]]
function GM:PlayerCanQuickRaise(player, weapon) return true end

-- Called when a player releases a key.
function GM:KeyRelease(player, key) end

-- A function to setup a player's visibility.
function GM:SetupPlayerVisibility(player)
	local ragdollEntity = player:GetRagdollEntity()

	if (ragdollEntity) then
		AddOriginToPVS(ragdollEntity:GetPos())
	end
end

-- Called after a player has spawned an NPC.
function GM:PlayerSpawnedNPC(player, npc)
	local faction
	local relation

	prevRelation = prevRelation or {}
	prevRelation[player:SteamID()] = prevRelation[player:SteamID()] or {}

	for k, v in ipairs(_player.GetAll()) do
		faction = faction.FindByID(v:GetFaction())

		if (faction) then
			relation = faction.entRelationship
		end

		if (istable(relation)) then
			for k2, v2 in pairs(relation) do
				if (k2 == npc:GetClass()) then
					if (string.lower(v2) == "like") then
						prevRelation[player:SteamID()][k2] = prevRelation[player:SteamID()][k2] or npc:Disposition(v)
						npc:AddEntityRelationship(v, D_LI, 1)
					elseif (string.lower(v2) == "fear") then
						prevRelation[player:SteamID()][k2] = prevRelation[player:SteamID()][k2] or npc:Disposition(v)
						npc:AddEntityRelationship(v, D_FR, 1)
					elseif (string.lower(v2) == "hate") then
						prevRelation[player:SteamID()][k2] = prevRelation[player:SteamID()][k2] or npc:Disposition(v)
						npc:AddEntityRelationship(v, D_HT, 1)
					else
						ErrorNoHalt("Attempting to add relationship using invalid relation '"..v2.."' towards faction '"..faction.name.."'.\r\n")
					end
				end
			end
		end
	end
end

--[[
	@codebase Server
	@details Called when an attribute is progressed to edit the amount it is progressed by.
	@param Player The player that has progressed the attribute.
	@param Table The attribute table of the attribute being progressed.
	@param Number The amount that is being progressed for editing purposes.
--]]
function GM:OnAttributeProgress(player, attribute, amount)
	amount = amount * config.Get("scale_attribute_progress"):Get()
end

--[[
	@codebase Server
	@details Called to add ammo types to be checked for and saved.
	@param Table The table filled with the current ammo types.
--]]
function GM:AdjustAmmoTypes(ammoTable)
	ammoTable["sniperpenetratedround"] = true
	ammoTable["striderminigun"] = true
	ammoTable["helicoptergun"] = true
	ammoTable["combinecannon"] = true
	ammoTable["smg1_grenade"] = true
	ammoTable["gaussenergy"] = true
	ammoTable["sniperround"] = true
	ammoTable["ar2altfire"] = true
	ammoTable["rpg_round"] = true
	ammoTable["xbowbolt"] = true
	ammoTable["buckshot"] = true
	ammoTable["alyxgun"] = true
	ammoTable["grenade"] = true
	ammoTable["thumper"] = true
	ammoTable["gravity"] = true
	ammoTable["battery"] = true
	ammoTable["pistol"] = true
	ammoTable["slam"] = true
	ammoTable["smg1"] = true
	ammoTable["357"] = true
	ammoTable["ar2"] = true
end

--[[
	@codebase Server
	@details Called after a player uses a command.
	@param Player The player that used the commmand.
	@param Table The table of the command that is being used.
	@param Table The arguments that have been given with the command, if any.
--]]
function GM:PostCommandUsed(player, command, arguments) end

-- A function to scale damage by hit group.
function GM:ScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, baseDamage)
	if (!damageInfo:IsFallDamage() and !damageInfo:IsDamageType(DMG_CRUSH)) then
		if (hitGroup == HITGROUP_HEAD) then
			damageInfo:ScaleDamage(config.Get("scale_head_dmg"):Get())
			player:SetDSP(35, false)
			player:ViewPunch(AngleRand())
		elseif (hitGroup == HITGROUP_CHEST or hitGroup == HITGROUP_GENERIC) then
			damageInfo:ScaleDamage(config.Get("scale_chest_dmg"):Get())
		elseif (hitGroup == HITGROUP_LEFTARM or hitGroup == HITGROUP_RIGHTARM or hitGroup == HITGROUP_LEFTLEG
		or hitGroup == HITGROUP_RIGHTLEG or hitGroup == HITGROUP_GEAR) then
			damageInfo:ScaleDamage(config.Get("scale_limb_dmg"):Get())
		end
	end

	hook.Run("PlayerScaleDamageByHitGroup", player, attacker, hitGroup, damageInfo, baseDamage)
end
