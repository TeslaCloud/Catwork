--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.isBaseItem = true
ITEM.baseItem = "weapon_base"
ITEM.name = "Grenade Base"
ITEM.isThrowableWeapon = true

-- Called when a player equips the item.
function ITEM:OnEquip(player)
	cw.player:GiveSpawnAmmo(player, "grenade", 1)
end

-- Called when a player attempts to drop the weapon.
function ITEM:CanDropWeapon(player, attacker, bNoMsg)
	if (player:GetAmmoCount("grenade") == 0) then
		player:StripWeapon(self:GetWeaponClass())
		player:TakeItem(self, true)

		return false
	else
		return true
	end
end

-- Called when a player attempts to holster the weapon.
function ITEM:CanHolsterWeapon(player, forceHolster, bNoMsg)
	if (player:GetAmmoCount("grenade") == 0) then
		player:StripWeapon(self:GetWeaponClass())

		return false
	else
		return true
	end
end

function ITEM:OnPlayerUnequipped(player, extraData)
	local weapon = player:GetWeapon(self:GetWeaponClass())
	if (!IsValid(weapon)) then return end

	local itemTable = item.GetByWeapon(weapon)

	if (itemTable:IsTheSameAs(self)) then
		local class = weapon:GetClass()

		if (extraData != "drop") then
			if (hook.Run("PlayerCanHolsterWeapon", player, self, weapon)) then
				if (player:GiveItem(self)) then
					hook.Run("PlayerHolsterWeapon", player, self, weapon)
					cw.player:TakeSpawnAmmo(player, "grenade", 1)
					player:StripWeapon(class)
					player:SelectWeapon("cw_hands")
				end
			end
		elseif (hook.Run("PlayerCanDropWeapon", player, self, weapon)) then
			local trace = player:GetEyeTraceNoCursor()

			if (player:GetShootPos():Distance(trace.HitPos) <= 192) then
				local entity = cw.entity:CreateItem(player, self, trace.HitPos)

				if (IsValid(entity)) then
					cw.entity:MakeFlushToGround(entity, trace.HitPos, trace.HitNormal)
					hook.Run("PlayerDropWeapon", player, self, entity, weapon)

					player:TakeItem(self, true)
					cw.player:TakeSpawnAmmo(player, "grenade", 1)
					player:StripWeapon(class)
					player:SelectWeapon("cw_hands")
				end
			else
				cw.player:Notify(player, "#CantDropFar")
			end
		end
	end
end
