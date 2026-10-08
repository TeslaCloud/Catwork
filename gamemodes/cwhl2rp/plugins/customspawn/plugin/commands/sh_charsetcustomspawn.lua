--[[
  © 2016 TeslaCloud Studios.
  Feel free to use, edit or share the plugin, but
  do not re-distribute without the permission of it's author.
--]]

local COMMAND = cw.command:New('CharSetCustomSpawn')
COMMAND.tip = '#Command_Charsetcustomspawn_Description'
COMMAND.text = '#Command_Charsetcustomspawn_Syntax'
COMMAND.access = 'a'
COMMAND.arguments = 1
COMMAND.alias = { 'SetCustomSpawn', 'SetCustomSpawnPoint', 'CustomSpawnSet' }

--- Sets the target character's custom spawn point to the target's current position on this map.
--
-- The saved angles are the eye angles of the player running the command, not the target's.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])

  if IsValid(target) then
    local position = target:GetPos()
    local posTable = {
      map = game.GetMap(),
      x = position.x,
      y = position.y,
      z = position.z,
      angles = player:EyeAngles()
    }

    target:SetCharacterData('CustomSpawn', posTable)

    cw.player:Notify(player, L('CustomSpawn_Set', target:Name()))
  else
    cw.player:Notify(player, L('NotValidPlayer', tostring(arguments[1])))
  end
end

COMMAND:Register()
