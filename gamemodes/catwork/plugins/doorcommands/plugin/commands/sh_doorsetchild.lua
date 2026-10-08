--- Registers the `/DoorSetChild` command, which parents the door the player is looking at to their active parent door.

local COMMAND = cw.command:New('DoorSetChild')
COMMAND.tip = '#Command_Doorsetchild_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'

--- Parents the door the player is looking at to the player's active parent door and saves the parents.
function COMMAND:OnRun(player, arguments)
  local door = player:GetEyeTraceNoCursor().Entity

  if IsValid(door) and cw.entity:IsDoor(door) then
    if IsValid(player.cwParentDoor) then
      if cwDoorCmds.parentData[door] != player.cwParentDoor then
        if player.cwParentDoor != door then
          cwDoorCmds.parentData[door] = player.cwParentDoor
          cwDoorCmds:SaveParentData()

          cw.entity:SetDoorParent(door, player.cwParentDoor)
          cw.player:Notify(player, L('DoorCmds_ChildAdded'))

          cwDoorCmds.infoTable = cwDoorCmds.infoTable or {}
          table.insert(cwDoorCmds.infoTable, door)

          netstream.Start(player, 'doorParentESP', cwDoorCmds.infoTable)
        else
          cw.player:Notify(player, L('DoorCmds_CannotParentToItself'))
        end
      else
        cw.player:Notify(player, L('DoorCmds_AlreadyChild'))
      end
    else
      cw.player:Notify(player, L('DoorCmds_NoValidParent'))
    end
  else
    cw.player:Notify(player, L('DoorCmds_NotValidDoor'))
  end
end

COMMAND:Register()
