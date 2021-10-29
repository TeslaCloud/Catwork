--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("PKModeOff")
COMMAND.tip = "#Command_Pkmodeoff_Description"
COMMAND.access = "o"

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	netvars.SetNetVar("PKMode", 0)
	timer.Remove("pk_mode")

	cw.player:NotifyAll(player:Name().." has turned off perma-kill mode, you are safe now.")
end

COMMAND:Register();
