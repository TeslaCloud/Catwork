--[[
	© 2016 TeslaCloud Studios.
	Please do not use anywhere else.
--]]

function PLUGIN:PlayerSaveCharacterData(player, data)
	if (data["Hunger"]) then
		data["Hunger"] = math.Round(tonumber(data["Hunger"]))
	end

	if (data["Thirst"]) then
		data["Thirst"] = math.Round(tonumber(data["Thirst"]))
	end

	if (data["Fatigue"]) then
		data["Fatigue"] = math.Round(tonumber(data["Fatigue"]))
	end
end

function PLUGIN:PlayerRestoreCharacterData(player, data)
	data["Hunger"] = tonumber(data["Hunger"]) or 100
	data["Thirst"] = tonumber(data["Thirst"]) or 100
	data["Fatigue"] = tonumber(data["Fatigue"]) or 0
end

function PLUGIN:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	if (!firstSpawn and !lightSpawn) then
		player:SetCharacterData("Hunger", 100)
		player:SetCharacterData("Thirst", 100)
		player:SetCharacterData("Fatigue", 0)
	end
end

function PLUGIN:PlayerUseItem(player, itemTable)
	local category = itemTable.category:utf8lower()

	if (itemTable.hunger or itemTable.thirst or itemTable.fatigue or category:find("consumables") or category:find("alcohol") or category:find("uu-branded items") or category:find("food")) then
		local hungerRefill = itemTable.hunger or config.GetVal("hunger_default_refill") or 25
		local thirstRefill = itemTable.thirst or config.GetVal("hunger_default_refill") or 25
		local fatigueRefill = itemTable.fatigue or config.GetVal("hunger_default_refill") or 25

		if (itemTable.thirst or itemTable.name:utf8lower():find("water")) then
			hungerRefill = math.Round(hungerRefill * 0.4)
			player:SetCharacterData("Thirst", math.Clamp(player:GetCharacterData("Thirst") + thirstRefill, 0, 100))
		end

		if (itemTable.fatigue) then
			player:SetCharacterData("Fatigue", math.Clamp(player:GetCharacterData("Fatigue") - fatigueRefill, 0, 100))
		end

		player:SetCharacterData("Hunger", math.Clamp(player:GetCharacterData("Hunger") + math.Clamp(hungerRefill, 0, 100), 0, 100))
		player:SaveCharacter()
	end
end

function PLUGIN:PlayerHasHunger(player)
	return !player:IsCombine()
end

function PLUGIN:PlayerThink(player, curTime, infoTable)
	if (plugin.Call("PlayerHasNeeds", player)) then
		local scale = config.GetVal("thirst_drain_scale") or 50
		local decrease = 1 * (scale / 100)
		local fatdecreace = 0.01

		if (!player:IsNoClipping()) then
			local playerVelocityLength = player:GetVelocity():Length()

			if (infoTable.isJumping) then
				player:SetCharacterData(
					"Fatigue", math.Clamp(
						player:GetCharacterData("Fatigue") + fatdecreace, 0, 100
					)
				)
			end

			if ((infoTable.isRunning and !infoTable.isJumping and !player:IsOnGround()) and playerVelocityLength != 0) then
				player:SetCharacterData(
					"Fatigue", math.Clamp(
						player:GetCharacterData("Fatigue") + fatdecreace, 0, 100
					)
				)
			end

			if (infoTable.isJumping) then
				player:SetCharacterData(
					"Thirst", math.Clamp(
						player:GetCharacterData("Thirst") - decrease, 0, 100
					)
				)
			end

			if ((infoTable.isRunning and !infoTable.isJumping and !player:IsOnGround()) and playerVelocityLength != 0) then
				player:SetCharacterData(
					"Thirst", math.Clamp(
						player:GetCharacterData("Thirst") - decrease, 0, 100
					)
				)
			end
		end
	end
end

function PLUGIN:PlayerShouldThirstDrain(player)
	return !(player:IsCombine()) or player:GetFaction() == FACTION_MPF
end

function PLUGIN:OnePlayerSecond(player, curTime, infoTable)
	if (player:HasInitialized() and hook.Run("PlayerHasNeeds", player)) then
		local thirst = tonumber(player:GetCharacterData("Thirst")) or 0
		local hunger = math.Clamp(tonumber(player:GetCharacterData("Hunger")) or 0, 0, thirst)
		local fatigue =  tonumber(player:GetCharacterData("Fatigue")) or 0
		local stamina = tonumber(player:GetCharacterData("Stamina")) or 0
		local step = 100 / math.Round(tonumber(config.GetVal("hunger_tick")) or 3600)
		local thirstStep = 100 / math.Round(tonumber(config.GetVal("thirst_tick")) or 3600)
		local fatStep = 100 / 20000

		if (thirst) then
			player:SetCharacterData("Hunger", hunger)
		end

		player:SetCharacterData("Hunger", math.Clamp(hunger - step, 0, 100))
		player:SetCharacterData("Thirst", math.Clamp(thirst - thirstStep, 0, 100))
		player:SetCharacterData("Fatigue", math.Clamp(fatigue + fatStep, 0, 100))

		if (hunger < 15) then
			if (player:Health() > 50) then
				player:SetHealth(player:Health() - 0.1)
			end
		end

		if (hunger < 5) then
			if (player:Health() > 20) then
				player:SetHealth(player:Health() - 0.1)
			end
		end

		if (fatigue > 85) then
			cw.player:SetRagdollState(player, RAGDOLL_KNOCKEDOUT, 30)
			player:SetCharacterData("Fatigue", 0)
		end

		player:SetNetVar("Hunger", math.Round(tonumber(player:GetCharacterData("Hunger")) or 100))
		player:SetNetVar("Thirst", math.Round(tonumber(player:GetCharacterData("Thirst")) or 100))
		player:SetNetVar("Fatigue", math.Round(tonumber(player:GetCharacterData("Fatigue")) or 100))
	end
end

function PLUGIN:PlayerShouldHealthRegenerate(player)
	local thirst = tonumber(player:GetCharacterData("Thirst")) or 100
	local hunger = math.Clamp(tonumber(player:GetCharacterData("Hunger")) or 100, 0, thirst)

	if (hunger < 65) then
		return false
	end
end

function PLUGIN:PlayerShouldStaminaRegenerate(player)
	local thirst = tonumber(player:GetCharacterData("Thirst")) or 100

	if (thirst < 30) then
		return false
	end
end
