--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

library.New("limb", cw)

cw.limb.bones = {
	["ValveBiped.Bip01_R_UpperArm"] = HITGROUP_RIGHTARM,
	["ValveBiped.Bip01_R_Forearm"] = HITGROUP_RIGHTARM,
	["ValveBiped.Bip01_L_UpperArm"] = HITGROUP_LEFTARM,
	["ValveBiped.Bip01_L_Forearm"] = HITGROUP_LEFTARM,
	["ValveBiped.Bip01_R_Thigh"] = HITGROUP_RIGHTLEG,
	["ValveBiped.Bip01_R_Calf"] = HITGROUP_RIGHTLEG,
	["ValveBiped.Bip01_R_Foot"] = HITGROUP_RIGHTLEG,
	["ValveBiped.Bip01_R_Hand"] = HITGROUP_RIGHTARM,
	["ValveBiped.Bip01_L_Thigh"] = HITGROUP_LEFTLEG,
	["ValveBiped.Bip01_L_Calf"] = HITGROUP_LEFTLEG,
	["ValveBiped.Bip01_L_Foot"] = HITGROUP_LEFTLEG,
	["ValveBiped.Bip01_L_Hand"] = HITGROUP_LEFTARM,
	["ValveBiped.Bip01_Pelvis"] = HITGROUP_STOMACH,
	["ValveBiped.Bip01_Spine2"] = HITGROUP_CHEST,
	["ValveBiped.Bip01_Spine1"] = HITGROUP_CHEST,
	["ValveBiped.Bip01_Head1"] = HITGROUP_HEAD,
	["ValveBiped.Bip01_Neck1"] = HITGROUP_HEAD
}

-- A function to convert a bone to a hit group.
function cw.limb:BoneToHitGroup(bone)
	return self.bones[bone] or HITGROUP_CHEST
end

-- A function to get whether limb damage is active.
function cw.limb:IsActive()
	return config.Get("limb_damage_system"):Get()
end

if (SERVER) then
	function cw.limb:TakeDamage(player, hitGroup, damage)
		local newDamage = math.ceil(damage)
		local limbData = player:GetCharacterData("LimbData")

		if (limbData) then
			limbData[hitGroup] = math.min((limbData[hitGroup] or 0) + newDamage, 100)

			netstream.Start(player, "TakeLimbDamage", {
				hitGroup = hitGroup, damage = newDamage
			})

			hook.Run("PlayerLimbTakeDamage", player, hitGroup, newDamage)
		end
	end

	-- A function to heal a player's body.
	function cw.limb:HealBody(player, amount)
		local limbData = player:GetCharacterData("LimbData")

		if (limbData) then
			for k, v in pairs(limbData) do
				self:HealDamage(player, k, amount)
			end
		end
	end

	-- A function to heal a player's limb damage.
	function cw.limb:HealDamage(player, hitGroup, amount)
		local newAmount = math.ceil(amount)
		local limbData = player:GetCharacterData("LimbData")

		if (limbData and limbData[hitGroup]) then
			limbData[hitGroup] = math.max(limbData[hitGroup] - newAmount, 0)

			if (limbData[hitGroup] == 0) then
				limbData[hitGroup] = nil
			end

			netstream.Start(player, "HealLimbDamage", {
				hitGroup = hitGroup, amount = newAmount
			})

			hook.Run("PlayerLimbDamageHealed", player, hitGroup, newAmount)
		end
	end

	-- A function to reset a player's limb damage.
	function cw.limb:ResetDamage(player)
		player:SetCharacterData("LimbData", {})

		netstream.Start(player, "ResetLimbDamage", true)

		hook.Run("PlayerLimbDamageReset", player)
	end

	-- A function to get whether any of a player's limbs are damaged.
	function cw.limb:IsAnyDamaged(player)
		local limbData = player:GetCharacterData("LimbData")

		if (limbData and table.Count(limbData) > 0) then
			return true
		else
			return false
		end
	end

	-- A function to get a player's limb health.
	function cw.limb:GetHealth(player, hitGroup, asFraction)
		return 100 - self:GetDamage(player, hitGroup, asFraction)
	end

	-- A function to get a player's limb damage.
	function cw.limb:GetDamage(player, hitGroup, asFraction)
		if (!config.Get("limb_damage_system"):Get()) then
			return 0
		end

		local limbData = player:GetCharacterData("LimbData")

		if (type(limbData) == "table") then
			if (limbData and limbData[hitGroup]) then
				if (asFraction) then
					return limbData[hitGroup] / 100
				else
					return limbData[hitGroup]
				end
			end
		end

		return 0
	end
else
	cw.limb.bodyTexture = Material("clockwork/limbs/body.png")
	cw.limb.stored = cw.limb.stored or {}
	cw.limb.hitGroups = {
		[HITGROUP_RIGHTARM] = Material("clockwork/limbs/rarm.png"),
		[HITGROUP_RIGHTLEG] = Material("clockwork/limbs/rleg.png"),
		[HITGROUP_LEFTARM] = Material("clockwork/limbs/larm.png"),
		[HITGROUP_LEFTLEG] = Material("clockwork/limbs/lleg.png"),
		[HITGROUP_STOMACH] = Material("clockwork/limbs/stomach.png"),
		[HITGROUP_CHEST] = Material("clockwork/limbs/chest.png"),
		[HITGROUP_HEAD] = Material("clockwork/limbs/head.png")
	}
	cw.limb.names = {
		[HITGROUP_RIGHTARM] = "Right Arm",
		[HITGROUP_RIGHTLEG] = "Right Leg",
		[HITGROUP_LEFTARM] = "Left Arm",
		[HITGROUP_LEFTLEG] = "Left Leg",
		[HITGROUP_STOMACH] = "Stomach",
		[HITGROUP_CHEST] = "Chest",
		[HITGROUP_HEAD] = "Head"
	}

	-- A function to get a limb's texture.
	function cw.limb:GetTexture(hitGroup)
		if (hitGroup == "body") then
			return self.bodyTexture
		else
			return self.hitGroups[hitGroup]
		end
	end

	-- A function to get a limb's name.
	function cw.limb:GetName(hitGroup)
		return self.names[hitGroup] or "Generic"
	end

	-- A function to get a limb color.
	function cw.limb:GetColor(health)
		if (health > 75) then
			return Color(166, 243, 76, 255)
		elseif (health > 50) then
			return Color(233, 225, 94, 255)
		elseif (health > 25) then
			return Color(233, 173, 94, 255)
		else
			return Color(222, 57, 57, 255)
		end
	end

	-- A function to get the local player's limb health.
	function cw.limb:GetHealth(hitGroup, asFraction)
		return 100 - self:GetDamage(hitGroup, asFraction)
	end

	-- A function to get the local player's limb damage.
	function cw.limb:GetDamage(hitGroup, asFraction)
		if (!config.Get("limb_damage_system"):Get()) then
			return 0
		end

		if (type(self.stored) == "table") then
			if (self.stored[hitGroup]) then
				if (asFraction) then
					return self.stored[hitGroup] / 100
				else
					return self.stored[hitGroup]
				end
			end
		end

		return 0
	end

	-- A function to get whether any of the local player's limbs are damaged.
	function cw.limb:IsAnyDamaged()
		return table.Count(self.stored) > 0
	end

	netstream.Hook("ReceiveLimbDamage", function(data)
		cw.limb.stored = data
		hook.Run("PlayerLimbDamageReceived")
	end)

	netstream.Hook("ResetLimbDamage", function(data)
		cw.limb.stored = {}
		hook.Run("PlayerLimbDamageReset")
	end)

	netstream.Hook("TakeLimbDamage", function(data)
		local hitGroup = data.hitGroup
		local damage = data.damage

		cw.limb.stored[hitGroup] = math.min((cw.limb.stored[hitGroup] or 0) + damage, 100)
		hook.Run("PlayerLimbTakeDamage", hitGroup, damage)
	end)

	netstream.Hook("HealLimbDamage", function(data)
		local hitGroup = data.hitGroup
		local amount = data.amount

		if (cw.limb.stored[hitGroup]) then
			cw.limb.stored[hitGroup] = math.max(cw.limb.stored[hitGroup] - amount, 0)

			if (cw.limb.stored[hitGroup] == 100) then
				cw.limb.stored[hitGroup] = nil
			end

			hook.Run("PlayerLimbDamageHealed", hitGroup, amount)
		end
	end)
end
