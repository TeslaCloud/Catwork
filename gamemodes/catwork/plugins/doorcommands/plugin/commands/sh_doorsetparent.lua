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
    cwDoorCmds.infoTable = cwDoorCmds.infoTable or {}

    player.cwParentDoor = door
    cwDoorCmds.infoTable.Parent = door

    for k, parent in pairs(cwDoorCmds.parentData) do
      if parent == door then
        table.insert(cwDoorCmds.infoTable, k)
      end
    end

    cw.player:Notify(player, L('DoorCmds_ParentSet'))

    if cwDoorCmds.infoTable != {} then
      netstream.Start(player, 'doorParentESP', cwDoorCmds.infoTable)
    end
  else
    cw.player:Notify(player, L('DoorCmds_NotValidDoor'))
  end
end

COMMAND:Register()
