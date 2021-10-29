--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("Static")
COMMAND.tip = "Add a static entity at your target position."
COMMAND.access = "o"
COMMAND.alias = {"StaticAdd", "StaticPropAdd"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	plugin.Call("PlayerMakeStatic", player, true)
end

COMMAND:Register();
