--- Registers the `/DoorUnparent` command, which removes the parent of the door the player is looking at.

local COMMAND = cw.command:New('DoorUnparent')
COMMAND.tip = '#Command_Doorunparent_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'

--- Removes the parent of the door the player is looking at and saves the parents.
function COMMAND:OnRun(player, arguments)
  local door = player:GetEyeTraceNoCursor().Entity

  if IsValid(door) and cw.entity:IsDoor(door) then
    cwDoorCmds.parentData[door] = nil
    cwDoorCmds:SaveParentData()

    cw.entity:SetDoorParent(door, false)

    cw.player:Notify(player, L('DoorCmds_Unparented'))
    cwDoorCmds:SendParentESP(player)
  else
    cw.player:Notify(player, L('DoorCmds_NotValidDoor'))
  end
end

COMMAND:Register()
