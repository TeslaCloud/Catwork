--- Registers the `/DoorSetHidden` command, which sets whether the door the player is looking at is hidden.

local COMMAND = cw.command:New('DoorSetHidden')
COMMAND.tip = '#Command_Doorsethidden_Description'
COMMAND.text = '#Command_Doorsethidden_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'
COMMAND.arguments = 1

--- Hides the door the player is looking at when the argument is true, or unhides it otherwise, and
-- saves the door data.
function COMMAND:OnRun(player, arguments)
  local door = player:GetEyeTraceNoCursor().Entity

  if IsValid(door) and cw.entity:IsDoor(door) then
    if cw.core:ToBool(arguments[1]) then
      local data = {
        position = door:GetPos(),
        entity = door
      }

      cw.entity:SetDoorHidden(door, true)

      cwDoorCmds.doorData[data.entity] = {
        position = door:GetPos(),
        entity = door,
        text = 'hidden',
        name = 'hidden'
      }

      cwDoorCmds:SaveDoorData()

      cw.player:Notify(player, L('DoorCmds_Hidden'))
    else
      cw.entity:SetDoorHidden(door, false)

      cwDoorCmds.doorData[door] = nil
      cwDoorCmds:SaveDoorData()

      cw.player:Notify(player, L('DoorCmds_Unhidden'))
    end
  else
    cw.player:Notify(player, L('DoorCmds_NotValidDoor'))
  end
end

COMMAND:Register()
