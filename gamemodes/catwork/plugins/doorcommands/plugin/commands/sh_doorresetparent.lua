--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

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
