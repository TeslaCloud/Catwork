--[[
  © 2016 TeslaCloud Studios.
  Feel free to use, edit or share the plugin, but
  do not re-distribute without the permission of it's author.
--]]

local COMMAND = cw.command:New('PlyResetHealth')
COMMAND.tip = '#Command_Plyresethealth_Description'
COMMAND.text = '#Command_Plyresethealth_Syntax'
COMMAND.access = 'a'
COMMAND.arguments = 1
COMMAND.alias = { 'ResetHP', 'ResetHealth', 'PlyResetHP' }

--- Restores the target player's health to their maximum health.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])

  if IsValid(target) then
    target:SetHealth(target:GetMaxHealth())

    cw.player:Notify(player, L('ExtraCommands_HealthReset', target:Name(), target:GetMaxHealth()))
  else
    cw.player:Notify(player, L('NotValidPlayer', arguments[1]))
  end
end

COMMAND:Register()
