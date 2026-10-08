--[[
  © 2016 TeslaCloud Studios.
  Feel free to use, edit or share the plugin, but
  do not re-distribute without the permission of it's author.
--]]

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
