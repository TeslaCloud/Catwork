--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("DoorSetUnownable")
COMMAND.tip = "Set an unownable door."
COMMAND.text = "<string Name> [string Text]"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "a"
COMMAND.arguments = 1
COMMAND.optionalArguments = true

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity

	if (IsValid(door) and cw.entity:IsDoor(door)) then
		local data = {
			position = door:GetPos(),
			entity = door,
			text = arguments[2],
			name = arguments[1]
		}

		cw.entity:SetDoorName(data.entity, data.name)
		cw.entity:SetDoorText(data.entity, data.text)
		cw.entity:SetDoorUnownable(data.entity, true)

		cwDoorCmds.doorData[data.entity] = data
		cwDoorCmds:SaveDoorData()

		cw.player:Notify(player, "You have set an unownable door.")
	else
		cw.player:Notify(player, "This is not a valid door!")
	end
end

COMMAND:Register();
