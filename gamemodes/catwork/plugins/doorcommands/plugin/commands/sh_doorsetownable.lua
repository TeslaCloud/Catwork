--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("DoorSetOwnable")
COMMAND.tip = "Set an ownable door."
COMMAND.text = "<string Name>"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "a"
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity

	if (IsValid(door) and cw.entity:IsDoor(door)) then
		local data = {
			customName = true,
			position = door:GetPos(),
			entity = door,
			name = table.concat(arguments or {}, " ") or ""
		}

		cw.entity:SetDoorUnownable(data.entity, false)
		cw.entity:SetDoorText(data.entity, false)
		cw.entity:SetDoorName(data.entity, data.name)

		cwDoorCmds.doorData[data.entity] = data
		cwDoorCmds:SaveDoorData()

		cw.player:Notify(player, "You have set an ownable door.")
	else
		cw.player:Notify(player, "This is not a valid door!")
	end
end

COMMAND:Register();
