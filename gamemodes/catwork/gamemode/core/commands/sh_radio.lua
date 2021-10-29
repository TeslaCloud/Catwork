--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("Radio")
COMMAND.tip = "#Commands_RDesc"
COMMAND.text = "#Command_Radio_Syntax"
COMMAND.flags = bit.bor(CMD_DEFAULT, CMD_DEATHCODE, CMD_FALLENOVER)
COMMAND.arguments = 1
COMMAND.alias = {"R", "Rs"}
COMMAND.cooldown = 2

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	cw.player:SayRadio(player, table.concat(arguments, " "), true)
end

COMMAND:Register();
