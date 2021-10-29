--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

if (!cw.player) then
	include("sh_player.lua")
end

-- A function to get whether the local player can hold a weight.
function cw.player:CanHoldWeight(weight)
	local inventoryWeight = cw.inventory:CalculateWeight(
		cw.inventory:GetClient()
	)

	if (inventoryWeight + weight > self:GetMaxWeight()) then
		return false
	else
		return true
	end
end

-- A function to get whether the local player can fit a space.
function cw.player:CanHoldSpace(space)
	local inventorySpace = cw.inventory:CalculateSpace(
		cw.inventory:GetClient()
	)

	if (inventorySpace + space > self:GetMaxSpace()) then
		return false
	else
		return true
	end
end

-- A function to get the maximum amount of weight the local player can carry.
function cw.player:GetMaxWeight()
	local itemsList = cw.inventory:GetAsItemsList(
		cw.inventory:GetClient()
	)

	local weight = cw.client:GetNetVar("InvWeight") or config.GetVal("default_inv_weight")

	for k, v in pairs(itemsList) do
		local addInvWeight = v.addInvSpace

		if (addInvWeight) then
			weight = weight + addInvWeight
		end
	end

	return weight
end

-- A function to get the maximum amount of space the local player can carry.
function cw.player:GetMaxSpace()
	local itemsList = cw.inventory:GetAsItemsList(
		cw.inventory:GetClient()
	)
	local space = cw.client:GetNetVar("InvSpace") or config.GetVal("default_inv_space")

	for k, v in pairs(itemsList) do
		local addInvSpace = v.addInvVolume

		if (addInvSpace) then
			space = space + addInvSpace
		end
	end

	return space
end

-- A function to get the local player's clothes data.
function cw.player:GetClothesData()
	return cw.ClothesData
end

-- A function to get the local player's accessory data.
function cw.player:GetAccessoryData()
	return cw.AccessoryData
end

-- A function to get the local player's clothes item.
function cw.player:GetClothesItem()
	local clothesData = self:GetClothesData()

	if (clothesData.itemID != nil and clothesData.uniqueID != nil) then
		return cw.inventory:FindItemByID(
			cw.inventory:GetClient(),
			clothesData.uniqueID, clothesData.itemID
		)
	end
end

-- A function to get whether the local player is wearing clothes.
function cw.player:IsWearingClothes()
	return (self:GetClothesItem() != nil)
end

-- A function to get whether the local player has an accessory.
function cw.player:HasAccessory(uniqueID)
	local accessoryData = self:GetAccessoryData()

	for k, v in pairs(accessoryData) do
		if (string.lower(v) == string.lower(uniqueID)) then
			return true
		end
	end

	return false
end

-- A function to get whether the local player is wearing an accessory.
function cw.player:IsWearingAccessory(itemTable)
	local accessoryData = self:GetAccessoryData()
	local itemID = itemTable.itemID

	if (accessoryData[itemID]) then
		return true
	else
		return false
	end
end

-- A function to get whether the local player is wearing an item.
function cw.player:IsWearingItem(itemTable)
	local clothesItem = self:GetClothesItem()
	return (clothesItem and clothesItem:IsTheSameAs(itemTable))
end

-- A function to get whether a player is noclipping.
function cw.player:IsNoClipping(player)
	if (player:GetMoveType() == MOVETYPE_NOCLIP
	and !player:InVehicle()) then
		return true
	end
end

-- A function to get whether a player is an admin.
function cw.player:IsAdmin(player)
	if (self:HasFlags(player, "o")) then
		return true
	end
end

-- A function to get whether the local player's data has streamed.
function cw.player:HasDataStreamed()
	return cw.DataHasStreamed
end

-- A function to get whether a player can hear another player.
function cw.player:CanHearPlayer(player, target, allowance)
	if (config.GetVal("messages_must_see_player")) then
		return self:CanSeePlayer(player, target, (allowance or 0.5), true)
	else
		return true
	end
end

-- A function to get whether the target recognises the local player.
function cw.player:DoesTargetRecognise()
	if (config.GetVal("recognise_system")) then
		return cw.client:GetNetVar("TargetKnows")
	else
		return true
	end
end

-- A function to get a player's real trace.
function cw.player:GetRealTrace(player, useFilterTrace)
	if (!IsValid(player)) then
		return
	end

	local angles = player:GetAimVector() * 4096
	local eyePos = EyePos()

	if (player != cw.client) then
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

	if ((IsValid(newTrace.Entity) and !newTrace.HitWorld and (!IsValid(trace.Entity)
	or string.find(trace.Entity:GetClass(), "vehicle"))) or useFilterTrace) then
		trace = newTrace
	end

	return trace
end

-- A function to get the local player's action.
function cw.player:GetAction(player, percentage)
	local startActionTime = player:GetNetVar("StartActTime") or 0
	local actionDuration = player:GetNetVar("ActDuration") or 0
	local curTime = CurTime()
	local action = player:GetNetVar("ActName") or "Unknown"

	if (curTime < startActionTime + actionDuration) then
		if (percentage) then
			return action, (100 / actionDuration) * (actionDuration - ((startActionTime + actionDuration) - curTime))
		else
			return action, actionDuration, startActionTime
		end
	else
		return "", 0, 0
	end
end

-- A function to get the local player's maximum characters.
function cw.player:GetMaximumCharacters()
	local whitelisted = cw.character:GetWhitelisted()
	local maximum = config.Get("additional_characters"):Get(2)

	for k, v in pairs(faction.GetStored()) do
		if (!v.whitelist or table.HasValue(whitelisted, v.name)) then
			maximum = maximum + 1
		end
	end

	return maximum
end

-- A function to get whether a player's weapon is raised.
function cw.player:GetWeaponRaised(player)
	return player:IsWeaponRaised()
end

-- A function to get a player's unrecognised name.
function cw.player:GetUnrecognisedName(player)
	local unrecognisedPhysDesc = self:GetPhysDesc(player)
	local unrecognisedName = config.Get("unrecognised_name"):Get()
	local usedPhysDesc

	if (unrecognisedPhysDesc) then
		unrecognisedName = unrecognisedPhysDesc
		usedPhysDesc = true
	end

	return unrecognisedName, usedPhysDesc
end

function cw.player:GetName(target)
	if (self:DoesRecognise(target)) then
		return target:Name()
	else
		return self:GetUnrecognisedName(target)
	end
end

-- A function to get whether a player can see an NPC.
function cw.player:CanSeeNPC(player, target, allowance, ignoreEnts)
	if (player:GetEyeTraceNoCursor().Entity == target) then
		return true
	else
		local trace = {}

		trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER
		trace.start = player:GetShootPos()
		trace.endpos = target:GetShootPos()
		trace.filter = {player, target}

		if (ignoreEnts) then
			if (type(ignoreEnts) == "table") then
				table.Add(trace.filter, ignoreEnts)
			else
				table.Add(trace.filter, ents.GetAll())
			end
		end

		trace = util.TraceLine(trace)

		if (trace.Fraction >= (allowance or 0.75)) then
			return true
		end
	end
end

-- A function to get whether a player can see a player.
function cw.player:CanSeePlayer(player, target, allowance, ignoreEnts)
	if (player:GetEyeTraceNoCursor().Entity == target) then
		return true
	elseif (target:GetEyeTraceNoCursor().Entity == player) then
		return true
	else
		local trace = {}

		trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER
		trace.start = player:GetShootPos()
		trace.endpos = target:GetShootPos()
		trace.filter = {player, target}

		if (ignoreEnts) then
			if (type(ignoreEnts) == "table") then
				table.Add(trace.filter, ignoreEnts)
			else
				table.Add(trace.filter, ents.GetAll())
			end
		end

		trace = util.TraceLine(trace)

		if (trace.Fraction >= (allowance or 0.75)) then
			return true
		end
	end
end

-- A function to get whether a player can see an entity.
function cw.player:CanSeeEntity(player, target, allowance, ignoreEnts)
	if (player:GetEyeTraceNoCursor().Entity == target) then
		return true
	else
		local trace = {}

		trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER
		trace.start = player:GetShootPos()
		trace.endpos = target:LocalToWorld(target:OBBCenter())
		trace.filter = {player, target}

		if (ignoreEnts) then
			if (type(ignoreEnts) == "table") then
				table.Add(trace.filter, ignoreEnts)
			else
				table.Add(trace.filter, ents.GetAll())
			end
		end

		trace = util.TraceLine(trace)

		if (trace.Fraction >= (allowance or 0.75)) then
			return true
		end
	end
end

-- A function to get whether a player can see a position.
function cw.player:CanSeePosition(player, position, allowance, ignoreEnts)
	local trace = {}

	trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER
	trace.start = player:GetShootPos()
	trace.endpos = position
	trace.filter = player

	if (ignoreEnts) then
		if (type(ignoreEnts) == "table") then
			table.Add(trace.filter, ignoreEnts)
		else
			table.Add(trace.filter, ents.GetAll())
		end
	end

	trace = util.TraceLine(trace)

	if (trace.Fraction >= (allowance or 0.75)) then
		return true
	end
end

-- A function to get a player's wages name.
function cw.player:GetWagesName(player)
	return cw.class:Query(player:Team(), "wagesName", config.Get("wages_name"):Get())
end

-- A function to check whether a player is ragdolled
function cw.player:IsRagdolled(player, exception, entityless)
	if (player:GetRagdollEntity() or entityless) then
		if (player:GetDTInt(INT_RAGDOLLSTATE) == 0) then
			return false
		elseif (player:GetDTInt(INT_RAGDOLLSTATE) == exception) then
			return false
		else
			return (player:GetDTInt(INT_RAGDOLLSTATE) != RAGDOLL_NONE)
		end
	end
end

-- A function to get whether the local player recognises another player.
function cw.player:DoesRecognise(player, status, isAccurate)
	if (!status) then
		return self:DoesRecognise(player, RECOGNISE_PARTIAL)
	elseif (config.Get("recognise_system"):Get()) then
		local key = self:GetCharacterKey(player)
		local realValue = false

		if (self:GetCharacterKey(cw.client) == key) then
			return true
		elseif (cw.RecognisedNames[key]) then
			if (isAccurate) then
				realValue = (cw.RecognisedNames[key] == status)
			else
				realValue = (cw.RecognisedNames[key] >= status)
			end
		end

		return hook.Run("PlayerDoesRecognisePlayer", player, status, isAccurate, realValue)
	else
		return true
	end
end

-- A function to get a player's character key.
function cw.player:GetCharacterKey(player)
	if (IsValid(player)) then
		return player:GetNetVar("Key")
	end
end

-- A function to get a player's ragdoll state.
function cw.player:GetRagdollState(player)
	if (player:GetDTInt(INT_RAGDOLLSTATE) == 0) then
		return false
	else
		return player:GetDTInt(INT_RAGDOLLSTATE)
	end
end

-- A function to get a player's physical description.
function cw.player:GetPhysDesc(player)
	if (!player) then
		player = cw.client
	end

	local physDesc = player:GetDTString(STRING_PHYSDESC)
	local team = player:Team()

	if (physDesc == "") then
		physDesc = cw.class:Query(team, "defaultPhysDesc", "")
	end

	if (physDesc == "") then
		physDesc = config.Get("default_physdesc"):Get()
	end

	if (!physDesc or physDesc == "") then
		physDesc = "Описание соответствует модели."
	else
		physDesc = cw.core:ModifyPhysDesc(physDesc)
	end

	local override = hook.Run("GetPlayerPhysDescOverride", player, physDesc)

	if (override) then
		physDesc = override
	end

	return physDesc
end

-- A function to get the local player's wages.
function cw.player:GetWages()
	return cw.client:GetNetVar("Wages")
end

-- A function to get the local player's cash.
function cw.player:GetCash()
	return cw.client:GetNetVar("Cash") or 0
end

-- A function to get a player's ragdoll entity.
function cw.player:GetRagdollEntity(player)
	local ragdollEntity = player:GetDTEntity(2)

	if (IsValid(ragdollEntity)) then
		return ragdollEntity
	end
end

-- A function to get a player's default skin.
function cw.player:GetDefaultSkin(player)
	local model, skin = cw.class:GetAppropriateModel(player:Team(), player)

	return skin
end

-- A function to get a player's default model.
function cw.player:GetDefaultModel(player)
	local model, skin = cw.class:GetAppropriateModel(player:Team(), player)
	return model
end

-- A function to check if a player has any flags.
function cw.player:HasAnyFlags(player, flags, bByDefault)
	local playerFlags = player:GetDTString(STRING_FLAGS)

	if (playerFlags != nil and playerFlags != "") then
		if (cw.class:HasAnyFlags(player:Team(), flags) and !bByDefault) then
			return true
		end

		for i = 1, #flags do
			local flag = string.utf8sub(flags, i, i)
			local bSuccess = true

			if (!bByDefault) then
				local hasFlag = hook.Run("PlayerDoesHaveFlag", player, flag)

				if (hasFlag != false) then
					if (hasFlag) then
						return true
					end
				else
					bSuccess = nil
				end
			end

			if (bSuccess) then
				if (flag == "s") then
					if (player:IsSuperAdmin()) then
						return true
					end
				elseif (flag == "a") then
					if (player:IsAdmin()) then
						return true
					end
				elseif (flag == "o") then
					if (player:IsSuperAdmin() or player:IsAdmin()) then
						return true
					elseif (player:IsUserGroup("operator")) then
						return true
					end
				elseif (string.find(playerFlags, flag)) then
					return true
				end
			end
		end
	end
end

-- A function to check if a player has access.
function cw.player:HasFlags(player, flags, bByDefault, bIsStrict)
	local playerFlags = player:GetDTString(STRING_FLAGS)

	if (playerFlags != nil and playerFlags != "") then
		if (cw.class:HasFlags(player:Team(), flags) and !bByDefault) then
			return true
		end

		if (!bIsStrict) then
			for k, v in ipairs(string.Explode("", flags)) do
				if (!bByDefault) then
					local hasFlag = hook.Run("PlayerDoesHaveFlag", player, v)

					if (hasFlag) then
						return true
					end
				end

				if (v == "s") then
					if (player:IsSuperAdmin()) then
						return true
					end
				elseif (v == "a") then
					if (player:IsAdmin()) then
						return true
					end
				elseif (v == "o") then
					if (player:IsUserGroup("operator") or player:IsAdmin()) then
						return true
					end
				end

				if (string.find(playerFlags, v)) then
					return true
				end
			end
		end

		for i = 1, #flags do
			local flag = string.utf8sub(flags, i, i)
			local bSuccess

			if (!bByDefault) then
				local hasFlag = hook.Run("PlayerDoesHaveFlag", player, flag)

				if (hasFlag != false) then
					if (hasFlag) then
						bSuccess = true
					end
				else
					return
				end
			end

			if (!bSuccess) then
				if (flag == "s") then
					if (!player:IsSuperAdmin()) then
						return
					end
				elseif (flag == "a") then
					if (!player:IsAdmin()) then
						return
					end
				elseif (flag == "o") then
					if (!player:IsSuperAdmin() and !player:IsAdmin()) then
						if (!player:IsUserGroup("operator")) then
							return
						end
					end
				elseif (!string.find(playerFlags, flag)) then
					return false
				end
			end
		end

		return true
	end
end

-- A function to get whether the local player is drunk.
function cw.player:GetDrunk()
	local isDrunk = LocalPlayer():GetNetVar("IsDrunk") or 0

	if (isDrunk and isDrunk > 0) then
		return isDrunk
	end
end

-- A function to get a player's chat icon.
function cw.player:GetChatIcon(player)
	local icon

	if (!IsValid(player)) then
		return "icon16/user_delete.png"
	end

	for k, v in pairs(cw.icon:GetAll()) do
		if (v.callback(player)) then
			if (!icon) then
				icon = v.path
			end

			if (v.isPlayer) then
				icon = v.path
				break
			end
		end
	end

	if (!icon) then
		local faction = player:GetFaction()

		icon = "icon16/user.png"

		if (faction and _faction.GetStored()[faction]) then
			if (_faction.GetStored()[faction].whitelist) then
				icon = "icon16/add.png"
			end
		end
	end

	return icon
end
