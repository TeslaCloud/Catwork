--- Registers the `/DoorSetUnownable` command, which makes the door the player is looking at unownable with the given
-- name and optional text.

local COMMAND = cw.command:New('DoorSetUnownable')
COMMAND.tip = '#Command_Doorsetunownable_Description'
COMMAND.text = '#Command_Doorsetunownable_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'
COMMAND.arguments = 1
COMMAND.optionalArguments = true

--- Makes the door the player is looking at unownable with the given name and optional text, and saves
-- the door data.
function COMMAND:OnRun(player, arguments)
  local door = player:GetEyeTraceNoCursor().Entity

  if IsValid(door) and cw.entity:IsDoor(door) then
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

    cw.player:Notify(player, L('DoorCmds_SetUnownable'))
  else
    cw.player:Notify(player, L('DoorCmds_NotValidDoor'))
  end
end

COMMAND:Register()
