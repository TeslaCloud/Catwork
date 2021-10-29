--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("Announce")

COMMAND.tip = "#Command_Announce_Description"
COMMAND.text = "#Command_Announce_Syntax"
COMMAND.arguments = 1
COMMAND.access = "o"

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local text = table.concat(arguments, " ")

 	cw.player:NotifyAll(text)
end

COMMAND:Register();
