--[[
  Author: Arbiter
  Clockwork Version: 0.88a.

  Credits:	A small part of this code comes from kurozael's DoorCommands Plugin.
        Heavily based off the works of Cervidae Kosmonaut in Faction Doors.
--]]

--- Registers the operator command `/DoorSetAccess` of the Personal Doors plugin, which gives the target character
-- personal access to the door the player is looking at, makes the door unownable and optionally sets whether it starts
-- locked.

local PLUGIN = PLUGIN

local COMMAND = cw.command:New('DoorSetAccess')
COMMAND.tip = '#Command_Doorsetaccess_Description'
COMMAND.text = '#Command_Doorsetaccess_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'o'
COMMAND.arguments = 1
COMMAND.optionalArguments = 1

--- Gives the target character personal access to the door the player is looking at.
--
-- The door becomes unownable and is saved; the optional second argument sets whether it starts locked, and
-- leaving it out keeps the door's current setting.
function COMMAND:OnRun(player, arguments)
  local owningGuy = _player.Find(arguments[1])

  if !IsValid(owningGuy) then
    return cw.player:Notify(player, L('NotValidPlayer', arguments[1]))
  end

  local owningPerson = owningGuy:Name()
  local door = player:GetEyeTraceNoCursor().Entity
  local lowerName = string.lower(owningPerson)

  if IsValid(door) and cw.entity:IsDoor(door) then
    if !door._OwningPersons or !door._OwningPersons[lowerName] then
      local doorData = PLUGIN.personalDoors[door]
      local owners = doorData and doorData.owners or {}
      local startLocked = doorData and doorData.startLocked or false

      if arguments[2] != nil then
        startLocked = cw.core:ToBool(arguments[2])
      end

      if !door._OwningPersons then
        door._OwningPersons = {}
      end

      door._OwningPersons[lowerName] = true

      if !cw.entity:IsDoorUnownable(door) then
        cw.entity:SetDoorUnownable(door, true)
      end

      table.insert(owners, owningPerson)

      PLUGIN.personalDoors[door] = {
        owners = owners,
        position = door:GetPos(),
        startLocked = startLocked
      }
      PLUGIN:SaveDoorData()

      cw.player:Notify(player, L('PersonalDoors_AccessGranted', owningPerson))
    else
      cw.player:Notify(player, L('PersonalDoors_AlreadyHasAccess'))
    end
  else
    cw.player:Notify(player, L('PersonalDoors_NotValidDoor'))
  end
end

COMMAND:Register()
