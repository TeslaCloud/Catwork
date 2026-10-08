--- Registers the admin command `/CharResetCustomSpawn` of the Custom Spawn plugin, which removes the target character's
-- custom spawn point.

local COMMAND = cw.command:New('CharResetCustomSpawn')
COMMAND.tip = '#Command_Charresetcustomspawn_Description'
COMMAND.text = '#Command_Charresetcustomspawn_Syntax'
COMMAND.access = 'a'
COMMAND.arguments = 1
COMMAND.alias = { 'ResetCustomSpawn', 'RemoveCustomSpawn', 'CustomSpawnRemove', 'CustomSpawnReset' }

--- Removes the target character's custom spawn point.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])

  if IsValid(target) then
    target:SetCharacterData('CustomSpawn', nil)

    cw.player:Notify(player, L('CustomSpawn_Removed', target:Name()))
  else
    cw.player:Notify(player, L('NotValidPlayer', tostring(arguments[1])))
  end
end

COMMAND:Register()
