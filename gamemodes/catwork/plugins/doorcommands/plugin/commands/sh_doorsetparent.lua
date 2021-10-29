--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("DoorSetParent")
COMMAND.tip = "Set the active parent door to your target."
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "a"

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity

	if (IsValid(door) and cw.entity:IsDoor(door)) then
		cwDoorCmds.infoTable = cwDoorCmds.infoTable or {}

		player.cwParentDoor = door
		cwDoorCmds.infoTable.Parent = door

		for k, parent in pairs(cwDoorCmds.parentData) do
			if (parent == door) then
				table.insert(cwDoorCmds.infoTable, k)
			end
		end

		cw.player:Notify(player, "You have set the active parent door to this. The parent has been highlighted orange, and its children blue.")

		if (cwDoorCmds.infoTable != {}) then
			netstream.Start(player, "doorParentESP", cwDoorCmds.infoTable)
		end
	else
		cw.player:Notify(player, "This is not a valid door!")
	end
end

COMMAND:Register();
