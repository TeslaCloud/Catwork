--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("DoorSetChild")
COMMAND.tip = "Add a child to the active parent door."
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "a"

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity

	if (IsValid(door) and cw.entity:IsDoor(door)) then
		if (IsValid(player.cwParentDoor)) then
			if (cwDoorCmds.parentData[door] != player.cwParentDoor) then
				if (player.cwParentDoor != door) then
					cwDoorCmds.parentData[door] = player.cwParentDoor
					cwDoorCmds:SaveParentData();		

					cw.entity:SetDoorParent(door, player.cwParentDoor)
					cw.player:Notify(player, "You have added this as a child to the active parent door.")

					cwDoorCmds.infoTable = cwDoorCmds.infoTable or {}
					table.insert(cwDoorCmds.infoTable, door)

					netstream.Start(player, "doorParentESP", cwDoorCmds.infoTable)
				else
					cw.player:Notify(player, "You cannot parent the active parent door to itself!")
				end
			else
				cw.player:Notify(player, "This door is already a child to the active parent door!")
			end
		else
			cw.player:Notify(player, "You have not selected a valid parent door!")
		end
	else
		cw.player:Notify(player, "This is not a valid door!")
	end
end

COMMAND:Register();
