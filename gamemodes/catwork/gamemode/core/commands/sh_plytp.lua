--- Registers the operator command `/PlyTeleport` (aliases `/PlyTP`, `/TP`), which teleports the target player to where
-- the caller is looking.

local COMMAND = cw.command:New('PlyTeleport')
COMMAND.tip = '#Command_Plytp_Description'
COMMAND.text = '#Command_Plytp_Syntax'
COMMAND.access = 'o'
COMMAND.arguments = 1
COMMAND.alias = { 'PlyTP', 'TP' }

--- Teleports the target player to where the caller is looking; the argument is the player name.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])

  if target then
    cw.player:SetSafePosition(target, player:GetEyeTraceNoCursor().HitPos)
    cw.player:NotifyAll(L('Command_Plytp_Teleported', player:Name(), target:Name()))
  else
    cw.player:Notify(player, L('NotValidPlayer', arguments[1]))
  end
end

COMMAND:Register()
