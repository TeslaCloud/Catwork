--- Registers the operator command `/PlySetHealth` (aliases `/PlyHealth`, `/Health`, `/SetHealth`), which sets the
-- target player's health.

local COMMAND = cw.command:New('PlySetHealth')
COMMAND.tip = '#Command_Plysethealth_Description'
COMMAND.text = '#Command_Plysethealth_Syntax'
COMMAND.arguments = 2
COMMAND.access = 'o'
COMMAND.alias = { 'PlyHealth', 'Health', 'SetHealth' }

--- Sets the target player's health; arguments are the player name and the health value.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])
  local health = tonumber(arguments[2])

  if isnumber(health) then
    target:SetHealth(health)
    cw.player:Notify(player, L('Command_Plysethealth_Set', target:GetName(), health))
    cw.player:Notify(target, L('Command_Plysethealth_SetTarget', health, player:GetName()))
  end
end

COMMAND:Register()
