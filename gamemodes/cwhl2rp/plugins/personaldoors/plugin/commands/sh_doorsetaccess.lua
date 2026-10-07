--[[
	Author: Arbiter
	Clockwork Version: 0.88a.

	Credits:	A small part of this code comes from kurozael's DoorCommands Plugin.
				Heavily based off the works of Cervidae Kosmonaut in Faction Doors.
--]]

local PLUGIN = PLUGIN

local COMMAND = cw.command:New("DoorSetAccess")
COMMAND.tip = "#Command_Doorsetaccess_Description"
COMMAND.text = "#Command_Doorsetaccess_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "o"
COMMAND.arguments = 1
COMMAND.optionalArguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local owningGuy = _player.Find(arguments[1])
	local owningPerson = owningGuy:Name()

	local door = player:GetEyeTraceNoCursor().Entity
	local lowerName = string.lower(owningPerson)

	if (IsValid(door) and cw.entity:IsDoor(door)) then
		if (!door._OwningPersons or !door._OwningPersons[lowerName]) then
			local owners = {}

			if(!door._OwningPersons)then
				door._OwningPersons = {}
			end

			door._OwningPersons[lowerName] = true

			if (!cw.entity:IsDoorUnownable(door))then
				cw.entity:SetDoorUnownable(door, true)
			end

			if(PLUGIN.personalDoors[door])then
				owners = PLUGIN.personalDoors[door]
			end

			table.insert(owners, owningPerson)

			PLUGIN.personalDoors[door] = {
				owners = owners,
				position = door:GetPos(),
				startLocked = cw.core:ToBool(arguments[2])
			}
			PLUGIN:SaveDoorData()

			cw.player:Notify(player, L("PersonalDoors_AccessGranted", owningPerson))
		else
			cw.player:Notify(player, L("PersonalDoors_AlreadyHasAccess"))
		end
	else
		cw.player:Notify(player, L("PersonalDoors_NotValidDoor"))
	end
end

COMMAND:Register()
