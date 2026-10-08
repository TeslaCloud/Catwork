--- Registers the `/DoorSetParent` command, which makes the door the player is looking at their active parent door for
-- `/DoorSetChild`.

local COMMAND = cw.command:New('DoorSetParent')
COMMAND.tip = '#Command_Doorsetparent_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'

--- Makes the door the player is looking at the active parent for `DoorSetChild` and outlines it and
-- its existing children.
function COMMAND:OnRun(player, arguments)
  local door = player:GetEyeTraceNoCursor().Entity

  if IsValid(door) and cw.entity:IsDoor(door) then
    player.cwParentDoor = door

    cw.player:Notify(player, L('DoorCmds_ParentSet'))
    cwDoorCmds:SendParentESP(player)
  else
    cw.player:Notify(player, L('DoorCmds_NotValidDoor'))
  end
end

COMMAND:Register()
