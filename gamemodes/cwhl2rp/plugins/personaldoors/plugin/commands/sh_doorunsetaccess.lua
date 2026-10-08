--[[
  Author: Arbiter
  Clockwork Version: 0.88a.

  Credits:	A small part of this code comes from kurozael's DoorCommands Plugin.
        Heavily based off the works of Cervidae Kosmonaut in Faction Doors.
--]]

--- Registers the operator command `/DoorUnsetAccess` of the Personal Doors plugin, which removes the target character's
-- personal access to the door the player is looking at, or everyone's when no name is given.

local PLUGIN = PLUGIN

local COMMAND = cw.command:New('DoorUnsetAccess')
COMMAND.tip = '#Command_Doorunsetaccess_Description'
COMMAND.text = '#Command_Doorunsetaccess_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'o'
COMMAND.optionalArguments = 1

--- Removes personal access to the door the player is looking at and saves the change.
--
-- With a name, only that character loses access: the name is either the full name of one of the door's owners,
-- who may be offline, or part of the name of a player who is online. Without a name every owner is removed.
function COMMAND:OnRun(player, arguments)
  local door = player:GetEyeTraceNoCursor().Entity
  local doorData = IsValid(door) and cw.entity:IsDoor(door) and PLUGIN.personalDoors[door]

  if !doorData then
    return cw.player:Notify(player, L('PersonalDoors_NotValidDoor'))
  end

  local msg = L('PersonalDoors_AccessRemovedAll')

  if arguments[1] then
    local owningPerson = arguments[1]
    local lowerName = string.lower(owningPerson)

    if !door._OwningPersons or !door._OwningPersons[lowerName] then
      local owningGuy = _player.Find(owningPerson)

      if !IsValid(owningGuy) then
        return cw.player:Notify(player, L('NotValidPlayer', owningPerson))
      end

      owningPerson = owningGuy:Name()
      lowerName = string.lower(owningPerson)
    end

    if door._OwningPersons then
      door._OwningPersons[lowerName] = nil
    end

    for k, v in ipairs(doorData.owners) do
      if string.lower(v) == lowerName then
        table.remove(doorData.owners, k)

        break
      end
    end

    msg = L('PersonalDoors_AccessRemoved', owningPerson)
  else
    door._OwningPersons = nil

    PLUGIN.personalDoors[door] = nil
  end

  PLUGIN:SaveDoorData()

  cw.player:Notify(player, msg)
end

COMMAND:Register()
