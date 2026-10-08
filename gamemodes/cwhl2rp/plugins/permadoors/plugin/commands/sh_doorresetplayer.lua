--- Registers the `/DoorResetPlayer` command of the Permanent Doors plugin, which makes the door the player is looking
-- at vacant under the given name.

local COMMAND = cw.command:New('DoorResetPlayer')
COMMAND.tip = '#Command_Doorresetplayer_Description'
COMMAND.text = '#Command_Doorresetplayer_Syntax'
COMMAND.access = 'D'
COMMAND.arguments = 1
COMMAND.alias = { 'DoorRemovePlayer' }

--- Makes the door the player is looking at vacant, with the given name, using `cwPermaDoors:ResetPermaDoor`.
function COMMAND:OnRun(player, arguments)
  local door = player:GetEyeTraceNoCursor().Entity
  local doorName = arguments[1]

  if IsValid(door) and cw.entity:IsDoor(door) then
    cwPermaDoors:ResetPermaDoor(door, doorName)

    cw.player:Notify(player, L('PermaDoors_OwnerRemoved'))
  else
    cw.player:Notify(player, L('PermaDoors_NotValidDoor'))
  end
end

COMMAND:Register()
