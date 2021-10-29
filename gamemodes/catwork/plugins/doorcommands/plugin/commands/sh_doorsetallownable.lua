--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("DoorSetAllOwnable")
COMMAND.tip = "Set all doors ownable."
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
				customName = true,
				position = v:GetPos(),
				entity = v,
				name = table.concat(arguments or {}, " ") or ""
			}
			cw.entity:SetDoorUnownable(data.entity, false)
			cw.entity:SetDoorText(data.entity, false)
			cw.entity:SetDoorName(data.entity, data.name)

			cwDoorCmds.doorData[data.entity] = data
			cwDoorCmds:SaveDoorData()
			good_doors = good_doors + 1
		end
	end

	cw.player:Notify(player, good_doors.." doors have been set ownable.")
	cw.player:Notify(player, "Remember: This is ALL Doors!")
end

COMMAND:Register();
