--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

function PLUGIN:ShouldWeaponMenuOpen(player, oldIndex, newIndex)
	local weapon = player:GetActiveWeapon()

	if (((weapon.IsFAS2Weapon or weapon.IsSXBASEWeapon) and weapon.dt.Status == FAS_STAT_CUSTOMIZE) or (weapon.CW20Weapon and weapon.dt.State == CW_CUSTOMIZE)) then
		return false
	end
end

function PLUGIN:OnWeaponRaised(player, weapon, bIsRaised)
	if (IsValid(weapon)) then
		if (weapon.IsFAS2Weapon or weapon.CW20Weapon or weapon.IsSXBASEWeapon) then
			if (weapon.FireMode == "safe") then
				weapon:SelectFiremode(weapon.FireModes[2])
			else
				weapon:SelectFiremode("safe")
			end
		end
	end
end

function PLUGIN:ShouldWeaponBeRaised(player, weapon)
	if (weapon.IsFAS2Weapon or weapon.CW20Weapon or weapon.IsSXBASEWeapon) then
		return weapon.FireMode != "safe"
	end
end

function PLUGIN:CanWeaponBeToggled(player, weapon)
	if (((weapon.IsFAS2Weapon or weapon.IsSXBASEWeapon) and weapon.dt.Status != FAS_STAT_IDLE) or (weapon.CW20Weapon and weapon.dt.State != CW_IDLE)) then
		return false
	end

	return true
end
