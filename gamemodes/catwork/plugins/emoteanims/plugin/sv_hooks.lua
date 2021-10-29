--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- Called just after a player spawns.
function cwEmoteAnims:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	if (!lightSpawn) then
		self:MakePlayerExitStance(player, true)
	end
end

-- Called when a player spawns lightly.
function cwEmoteAnims:PostPlayerLightSpawn(player, weapons, ammo, special)
	self:MakePlayerExitStance(player)
end

-- Called when a player has been ragdolled.
function cwEmoteAnims:PlayerRagdolled(player, state, ragdoll)
	self:MakePlayerExitStance(player, true)
end

-- Called when a player attempts to fire a weapon.
function cwEmoteAnims:PlayerCanFireWeapon(player, bIsRaised, weapon, bIsSecondary)
	if (self:IsPlayerInStance(player)) then
		return false
	end
end

-- Called at an interval while a player is connected.
function cwEmoteAnims:PlayerThink(player, curTime, infoTable)
	local forcedAnimation = player:GetForcedAnimation()
	local isMoving = false
	local uniqueID = player:UniqueID()

	if (player:KeyDown(IN_FORWARD) or player:KeyDown(IN_BACK) or player:KeyDown(IN_MOVELEFT)
	or player:KeyDown(IN_MOVERIGHT)) then
		isMoving = true
	end

	if (forcedAnimation and self.stanceList[forcedAnimation.animation]) then
		local plyPos = player:GetPos()

		local tr = util.TraceLine({
			start = plyPos - Vector(0, 0, 4),
			endpos = plyPos - Vector(0, 0, 24)
		})

		if (player:GetNetVar("StancePos")) then
			if (tr.Entity != NULL) then
				if (player:GetPos():Distance(player:GetNetVar("StancePos")) > 16 or !player:IsOnGround() or isMoving
				or (tr.Entity:GetClass() != "prop_physics" and tr.Entity:GetClass() != "prop_static" and tr.Entity:GetClass() != "worldspawn")) then
					player:SetForcedAnimation(false)
					player.cwPreviousPos = nil
					player:SetNetVar("StancePos", Vector(0, 0, 0))
					player:SetNetVar("StanceAng", nil)
					player:SetNetVar("StanceIdle", false)
				end
			else
				player:SetForcedAnimation(false)
				player.cwPreviousPos = nil
				player:SetNetVar("StancePos", Vector(0, 0, 0))
				player:SetNetVar("StanceAng", nil)
				player:SetNetVar("StanceIdle", false)
			end
		end
	elseif (self:IsPlayerInStance(player)) then
		if (!timer.Exists("ExitStance"..uniqueID)) then
			timer.Create("ExitStance"..uniqueID, 1, 1, function()
				if (IsValid(player)) then
					player:SetNetVar("StancePos", Vector(0, 0, 0))
					player:SetNetVar("StanceAng", nil)
				end
			end)
		end
	end
end

-- Called when the player attempts to be ragdolled.
function cwEmoteAnims:PlayerCanRagdoll(player, state, delay, decay, ragdoll)
	local forcedAnimation = player:GetForcedAnimation()

	if (forcedAnimation and self.stanceList[forcedAnimation.animation]) then
		if (player:Alive()) then
			return false
		end
	end
end

-- Called when a player attempts to NoClip.
function cwEmoteAnims:PlayerNoClip(player)
	local forcedAnimation = player:GetForcedAnimation()

	if (forcedAnimation and self.stanceList[forcedAnimation.animation]) then
		return false
	end
end
