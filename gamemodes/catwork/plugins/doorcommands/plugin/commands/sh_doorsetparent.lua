--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("DoorSetParent")
COMMAND.tip = "#Command_Doorsetparent_Description"
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

		cw.player:Notify(player, L("DoorCmds_ParentSet"))

		if (cwDoorCmds.infoTable != {}) then
			netstream.Start(player, "doorParentESP", cwDoorCmds.infoTable)
		end
	else
		cw.player:Notify(player, L("DoorCmds_NotValidDoor"))
	end
end

COMMAND:Register()
