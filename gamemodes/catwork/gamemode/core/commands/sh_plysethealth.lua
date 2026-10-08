--- Registers the operator command `/PlySetHealth` (aliases `/PlyHealth`, `/Health`, `/SetHealth`), which sets the
-- target player's health.

local COMMAND = cw.command:New('PlySetHealth')
COMMAND.tip = '#Command_Plysethealth_Description'
COMMAND.text = '#Command_Plysethealth_Syntax'
COMMAND.arguments = 2
COMMAND.access = 'o'
COMMAND.alias = { 'PlyHealth', 'Health', 'SetHealth' }

--- Sets the target player's health; arguments are the player name and the health value.
--
-- The health is rounded down and must be at least 1.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])
  local health = math.floor(tonumber(arguments[2]) or 0)

  if !target then
    cw.player:Notify(player, L('NotValidPlayer', arguments[1]))
    return
  end

  -- The engine keeps health in a 32-bit integer.
  if health >= 1 and health <= 2147483647 then
    target:SetHealth(health)
    cw.player:Notify(player, L('Command_Plysethealth_Set', target:GetName(), health))
    cw.player:Notify(target, L('Command_Plysethealth_SetTarget', health, player:GetName()))
  else
    cw.player:Notify(player, L('NotValidAmount'))
  end
end

COMMAND:Register()
