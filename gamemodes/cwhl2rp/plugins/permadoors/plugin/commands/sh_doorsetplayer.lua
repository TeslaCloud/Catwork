--- Registers the `/DoorSetPlayer` command of the Permanent Doors plugin, which gives the door the player is looking at
-- to the target character as a permanent door with the given name.

local COMMAND = cw.command:New('DoorSetPlayer')
COMMAND.tip = '#Command_Doorsetplayer_Description'
COMMAND.text = '#Command_Doorsetplayer_Syntax'
COMMAND.access = 'D'
COMMAND.arguments = 2

--- Gives the door the player is looking at to the target character as a permanent door with the given name.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])
  local doorName = arguments[2]
  local door = player:GetEyeTraceNoCursor().Entity

  if IsValid(door) and cw.entity:IsDoor(door) then
    if IsValid(target) then
      cwPermaDoors:SetPermaDoor(target, door, doorName)

      cw.player:Notify(player, L('PermaDoors_Assigned', target:Name()))
    else
      cw.player:Notify(player, L('NotValidPlayer', tostring(arguments[1])))
    end
  else
    cw.player:Notify(player, L('PermaDoors_NotValidDoor'))
  end
end

COMMAND:Register()
