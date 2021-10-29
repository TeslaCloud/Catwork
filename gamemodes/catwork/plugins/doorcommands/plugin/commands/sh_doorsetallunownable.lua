--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("DoorSetAllUnownable")
COMMAND.tip = "Set all doors unownable."
COMMAND.text = "<string Name>"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "a"
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	good_doors = 0
	for k,v in pairs(ents.GetAll()) do
		if(IsValid(v) and cw.entity:IsDoor(v)) then
			local data = {
				position = v:GetPos(),
				entity = v,
				text = arguments[2],
				name = arguments[1]
			}

			cw.entity:SetDoorName(data.entity, data.name)
			cw.entity:SetDoorText(data.entity, data.text)
			cw.entity:SetDoorUnownable(data.entity, true)

			cwDoorCmds.doorData[data.entity] = data
			cwDoorCmds:SaveDoorData()
			good_doors = good_doors + 1
		end
	end

	cw.player:Notify(player, good_doors.." doors have been set unownable.")
	cw.player:Notify(player, "Remember: This is ALL Doors!")
end

COMMAND:Register();
