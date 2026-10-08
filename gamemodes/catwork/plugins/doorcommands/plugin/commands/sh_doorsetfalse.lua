--- Registers the `/DoorSetFalse` command, which sets whether the door the player is looking at is a false door.

local COMMAND = cw.command:New('DoorSetFalse')
COMMAND.tip = '#Command_Doorsetfalse_Description'
COMMAND.text = '#Command_Doorsetfalse_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'
COMMAND.arguments = 1

--- Makes the door the player is looking at false when the argument is true, or a normal door
-- otherwise, and saves the door data.
function COMMAND:OnRun(player, arguments)
  local door = player:GetEyeTraceNoCursor().Entity

  if IsValid(door) and cw.entity:IsDoor(door) then
    if cw.core:ToBool(arguments[1]) then
      cw.entity:SetDoorFalse(door, true)

      cwDoorCmds.doorData[door] = {
        position = door:GetPos(),
        entity = door,
        text = 'hidden',
        name = 'hidden'
      }

      cwDoorCmds:SaveDoorData()

      cw.player:Notify(player, L('DoorCmds_MadeFalse'))
    else
      cw.entity:SetDoorFalse(door, false)

      cwDoorCmds.doorData[door] = nil
      cwDoorCmds:SaveDoorData()

      cw.player:Notify(player, L('DoorCmds_MadeNotFalse'))
    end
  else
    cw.player:Notify(player, L('DoorCmds_NotValidDoor'))
  end
end

COMMAND:Register()
