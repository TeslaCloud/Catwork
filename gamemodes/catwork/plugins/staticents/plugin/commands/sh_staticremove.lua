--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("UnStatic")
COMMAND.tip = "Remove static entities at your target position."
COMMAND.access = "a"
COMMAND.alias = {"StaticRemove", "StaticPropRemove"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	plugin.Call("PlayerMakeStatic", player, false)
end

COMMAND:Register();
