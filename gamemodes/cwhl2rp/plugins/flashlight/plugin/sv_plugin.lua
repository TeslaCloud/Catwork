--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local PLUGIN = PLUGIN

-- A function to get whether a player has a flashlight.
function PLUGIN:PlayerHasFlashlight(player)
	if (player:IsCombine()) then
		return true
	end

	if (player:HasItemByID("cw_flashlight")) then return true end

	local weapon = player:GetActiveWeapon()

	if (IsValid(weapon)) then
		local itemTable = item.GetByWeapon(weapon)

		if (weapon:GetClass() == "cw_flashlight" or (itemTable and itemTable.hasFlashlight)) then
			return true
		end
	end
end
