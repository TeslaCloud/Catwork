--[[
  Author: Arbiter
  Clockwork Version: 0.88a.

  Credits:	A small part of this code comes from kurozael's DoorCommands Plugin.
        Heavily based off the works of Cervidae Kosmonaut in Faction Doors.
--]]

local PLUGIN = PLUGIN

local COMMAND = cw.command:New('DoorUnsetAccess')
COMMAND.tip = '#Command_Doorunsetaccess_Description'
COMMAND.text = '#Command_Doorunsetaccess_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'o'
COMMAND.optionalArguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
  local owningGuy = _player.Find(arguments[1])
  local owningPerson = owningGuy:Name()
  local door = player:GetEyeTraceNoCursor().Entity

  if IsValid(door) and cw.entity:IsDoor(door) and PLUGIN.personalDoors[door] then
    local msg = L('PersonalDoors_AccessRemovedAll')

    if owningPerson then
      door._OwningPersons[string.lower(owningPerson)] = nil

      for k, v in pairs(PLUGIN.personalDoors[door].owners)do
        if v == owningPerson then
          table.remove(PLUGIN.personalDoors[door].owners, k)

          break
        end
      end

      msg = L('PersonalDoors_AccessRemoved', owningPerson)
    else
      door._OwningPersons = nil

      PLUGIN.personalDoors = {}
    end

    PLUGIN:SaveDoorData()

    cw.player:Notify(player, msg)
  else
    cw.player:Notify(player, L('PersonalDoors_NotValidDoor'))
  end
end

COMMAND:Register()
