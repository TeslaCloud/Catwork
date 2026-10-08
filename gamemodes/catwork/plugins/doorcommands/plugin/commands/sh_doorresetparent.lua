--- Registers the `/DoorResetParent` command, which clears the player's active parent door and the parenting outlines.

local COMMAND = cw.command:New('DoorResetParent')
COMMAND.tip = '#Command_Doorresetparent_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'

--- Clears the player's active door parent and the parenting outlines.
function COMMAND:OnRun(player, arguments)
  cwDoorCmds.infoTable = cwDoorCmds.infoTable or {}

  if IsValid(player.cwParentDoor) then
    player.cwParentDoor = nil
    cwDoorCmds.infoTable = {}

    cw.player:Notify(player, L('DoorCmds_ParentCleared'))
    netstream.Start(player, 'doorParentESP', cwDoorCmds.infoTable)
  else
    cw.player:Notify(player, L('DoorCmds_NoActiveParent'))
  end
end

COMMAND:Register()
