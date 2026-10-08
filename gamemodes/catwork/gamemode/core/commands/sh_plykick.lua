--- Registers the operator command `/PlyKick` (alias `/Kick`), which kicks the target player from the server with a
-- reason.

local COMMAND = cw.command:New('PlyKick')
COMMAND.tip = '#Command_Plykick_Description'
COMMAND.text = '#Command_Plykick_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'o'
COMMAND.arguments = 2
COMMAND.alias = { 'Kick' }

--- Kicks the target player from the server; arguments are the player name and the reason.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])
  local reason = table.concat(arguments, ' ', 2)

  if !reason or reason == '' then
    reason = 'N/A'
  end

  if target then
    if !cw.player:IsProtected(arguments[1]) then
      cw.player:NotifyAll(L('Command_Plykick_Kicked', player:Name(), target:Name())..' '..reason)
        target:Kick(reason)
      target.kicked = true
    else
      cw.player:Notify(player, L('Command_PlayerProtected', target:Name()))
    end
  else
    cw.player:Notify(player, L('NotValidPlayer', arguments[1]))
  end
end

COMMAND:Register()
