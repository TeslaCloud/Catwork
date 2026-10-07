--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New('DoorUnparent')
COMMAND.tip = '#Command_Doorunparent_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
  local door = player:GetEyeTraceNoCursor().Entity

  if IsValid(door) and cw.entity:IsDoor(door) then
    cwDoorCmds.infoTable = cwDoorCmds.infoTable or {}

    if cwDoorCmds.parentData[door] == player.cwParentDoor then
      for k, v in pairs(cwDoorCmds.infoTable) do
        if v == door then
          table.remove(cwDoorCmds.infoTable, k)
        end
      end
    end

    netstream.Start(player, 'doorParentESP', cwDoorCmds.infoTable)

    cwDoorCmds.parentData[door] = nil
    cwDoorCmds:SaveParentData()

    cw.entity:SetDoorParent(door, false)

    cw.player:Notify(player, L('DoorCmds_Unparented'))
  else
    cw.player:Notify(player, L('DoorCmds_NotValidDoor'))
  end
end

COMMAND:Register()
