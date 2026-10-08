--- Registers the `/DoorUnlock` command, which unlocks the door the player is looking at.

local COMMAND = cw.command:New('DoorUnlock')
COMMAND.tip = '#Command_Doorunlock_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'o'

--- Unlocks the door the player is looking at.
function COMMAND:OnRun(player, arguments)
  local door = player:GetEyeTraceNoCursor().Entity

  if IsValid(door) and cw.entity:IsDoor(door) then
    door:EmitSound('doors/door_latch3.wav')
    door:Fire('unlock', '', 0)

    cw.player:Notify(player, L('DoorCmds_Unlocked'))
  else
    cw.player:Notify(player, L('DoorCmds_NotValidDoor'))
  end
end

COMMAND:Register()
