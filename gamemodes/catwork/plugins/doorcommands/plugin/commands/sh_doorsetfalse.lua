--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("DoorSetFalse")
COMMAND.tip = "Set whether a door is false."
COMMAND.text = "<bool IsFalse>"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "a"
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity

	if (IsValid(door) and cw.entity:IsDoor(door)) then
		if (cw.core:ToBool(arguments[1])) then
			local data = {
				position = door:GetPos(),
				entity = door
			};		

			cw.entity:SetDoorFalse(door, true)

			cwDoorCmds.doorData[data.entity] = {
				position = door:GetPos(),
				entity = door,
				text = "hidden",
				name = "hidden"
			}

			cwDoorCmds:SaveDoorData()

			cw.player:Notify(player, "You have made this door false.")
		else
			cw.entity:SetDoorFalse(door, false)

			cwDoorCmds.doorData[door] = nil
			cwDoorCmds:SaveDoorData()

			cw.player:Notify(player, "You have no longer made this door false.")
		end
	else
		cw.player:Notify(player, "This is not a valid door!")
	end
end

COMMAND:Register();
