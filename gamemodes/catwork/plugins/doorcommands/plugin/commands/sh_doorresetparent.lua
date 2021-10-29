--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("DoorResetParent")
COMMAND.tip = "Reset the player's active parent door."
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "a"

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	cwDoorCmds.infoTable = cwDoorCmds.infoTable or {}

	if (IsValid(player.cwParentDoor)) then
		player.cwParentDoor = nil
		cwDoorCmds.infoTable = {}

		cw.player:Notify(player, "You have cleared your active parent door.")
		netstream.Start(player, "doorParentESP", cwDoorCmds.infoTable)
	else
		cw.player:Notify(player, "You do not have an active parent door.")
	end
end

COMMAND:Register();
