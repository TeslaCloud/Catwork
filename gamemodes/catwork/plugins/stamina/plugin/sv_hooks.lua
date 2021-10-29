--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- Called when a player's character data should be saved.
function cwStamina:PlayerSaveCharacterData(player, data)
	if (data["stamina"]) then
		data["stamina"] = math.Round(data["stamina"])
	end
end

-- Called when a player's character data should be restored.
function cwStamina:PlayerRestoreCharacterData(player, data)
	if (!data["Stamina"]) then
		data["Stamina"] = 100
	end
end

-- Called just after a player spawns.
function cwStamina:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	if (!firstSpawn and !lightSpawn) then
		player:SetCharacterData("Stamina", 100)
	end
end

-- Called when a player attempts to throw a punch.
function cwStamina:PlayerCanThrowPunch(player)
	if (player:GetCharacterData("Stamina") <= 10) then
		return false
	end
end

-- Called when a player throws a punch.
function cwStamina:PlayerPunchThrown(player)
	local attribute = cw.attributes:Fraction(player, ATB_ENDURANCE, 1.5, 0.25)
	local decrease = 5 / (1 + attribute)

	player:SetCharacterData("Stamina", math.Clamp(player:GetCharacterData("Stamina") - decrease, 0, 100))
	player:ProgressAttribute(ATB_MELEE, 1, true)
end

-- Called when a player's shared variables should be set.
function cwStamina:OnePlayerSecond(player, curTime)
	player:SetNetVar("Stamina", math.floor(player:GetCharacterData("Stamina")))
end

-- Called when a player's stamina should regenerate.
function cwStamina:PlayerShouldStaminaRegenerate(player)
	return true
end

-- Called when a player's stamina should drain.
function cwStamina:PlayerShouldStaminaDrain(player)
	return true
end

do
	local running = {}
	local regenScale = 0
	local drainScale = 0
	local run_speed = 0

	local function IsRunning(player)
		return running[player]
	end

	local function StartRunning(player, shouldDrain)
		local steamID = player:SteamID()
		local timerName = "Stam::Run::"..steamID

		if (drainScale == 0) then
			drainScale = config.GetVal("stam_drain_scale")
		end

		running[player] = true

		timer.Pause("Stam::Regen::"..steamID)

		if (shouldDrain) then
			if (!timer.Exists(timerName)) then
				timer.Create(timerName, 0.2, 0, function()
					local attribute = cw.attributes:Fraction(player, ATB_ENDURANCE, 1, 0.25)
					local maxHealth = player:GetMaxHealth()
					local healthScale = (drainScale * (math.Clamp(player:Health(), maxHealth * 0.1, maxHealth) / maxHealth))
					local decrease = (drainScale + (drainScale - healthScale)) - ((drainScale * 0.5) * attribute)
					local newStamina = math.Clamp(player:GetCharacterData("Stamina") - decrease, 0, 100)

					player:SetCharacterData("Stamina", newStamina)

					if (newStamina > 1) then
						player:ProgressAttribute(ATB_ENDURANCE, 0.025, true)
					end
				end)
			else
				timer.UnPause(timerName)
			end
		else
			timer.Pause(timerName)
		end
	end

	local function StopRunning(player, shouldRegen)
		local steamID = player:SteamID()
		local timerName = "Stam::Regen::"..steamID

		if (regenScale == 0) then
			regenScale = config.GetVal("stam_regen_scale")
		end

		running[player] = false

		timer.Pause("Stam::Run::"..steamID)

		if (shouldRegen) then
			if (!timer.Exists(timerName)) then
				timer.Create(timerName, 0.5, 0, function()
					local attribute = cw.attributes:Fraction(player, ATB_ENDURANCE, 1, 0.25)
					local regeneration = regenScale + attribute

					if (player:Crouching()) then
						regeneration = regeneration * 2
					end

					player:SetCharacterData(
						"Stamina", math.Clamp(
							player:GetCharacterData("Stamina") + regeneration, 0, 100 - player:GetCharacterData("Fatigue", 0)
						)
					)
				end)
			else
				timer.UnPause(timerName)
			end
		else
			timer.Pause(timerName)
		end
	end

	-- Called at an interval while a player is connected.
	function cwStamina:PlayerThink(player, curTime, infoTable)
		if (!cw.player:IsNoClipping(player)) then
			local isJumping = infoTable.isJumping
			local isRunning = infoTable.isRunning
			local isRunTimerActive = IsRunning(player)

			if (isJumping) then
				player:SetCharacterData(
					"Stamina", math.Clamp(player:GetCharacterData("Stamina") - 2.5, 0, 100)
				)

				player:ProgressAttribute(ATB_ENDURANCE, 0.02, true)
			else
				if (!isRunTimerActive and (isRunning and player:IsOnGround())) then
					StartRunning(player, plugin.Call("PlayerShouldStaminaDrain", player))
				elseif (isRunTimerActive) and !(isRunning) then
					StopRunning(player, plugin.Call("PlayerShouldStaminaRegenerate", player))
				end
			end
		end

		if (run_speed == 0) then
			run_speed = config.GetVal("run_speed")
		end

		local newRunSpeed = infoTable.runSpeed * 2
		local diffRunSpeed = newRunSpeed - infoTable.walkSpeed

		infoTable.runSpeed = math.Clamp(newRunSpeed - (diffRunSpeed - ((diffRunSpeed / 100) * player:GetCharacterData("Stamina"))), infoTable.walkSpeed, run_speed)
	end

	function cwStamina:PlayerDisconnected(player)
		local steamID = player:SteamID()

		timer.Remove("Stam::Run::"..steamID)
		timer.Remove("Stam::Regen::"..steamID)

		running[player] = false
	end
end
