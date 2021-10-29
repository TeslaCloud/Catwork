--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local PLUGIN = PLUGIN

-- Called when a player switches their flashlight on or off.
function PLUGIN:PlayerSwitchFlashlight(player, on)
	if (on and !self:PlayerHasFlashlight(player)) then
		return false
	end
end

-- Called at an interval while a player is connected.
function PLUGIN:PlayerThink(player, curTime, infoTable)
	if (player:FlashlightIsOn()) then
		if (!self:PlayerHasFlashlight(player)) then
			player:Flashlight(false)
		end
	end
end
