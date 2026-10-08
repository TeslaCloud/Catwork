--- Registers the operator command `/PlyMute` (alias `/Mute`), which blocks the target player from OOC and LOOC chat for
-- a number of minutes.

local COMMAND = cw.command:New('PlyMute')
COMMAND.tip = '#Command_Plymute_Description'
COMMAND.text = '#Command_Plymute_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'o'
COMMAND.arguments = 2
COMMAND.alias = { 'Mute' }

--- Blocks the target player from OOC and LOOC chat; arguments are the player name and the minutes.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])
  local duration = tonumber(arguments[2])

  if !duration or duration != duration then
    cw.player:Notify(player, L('Command_Plyban_InvalidDuration'))
    return
  end

  if target then
    if !cw.player:IsProtected(arguments[1]) then
      local curTime = CurTime()
      local seconds = duration * 60

      target.cwNextTalkOOC = curTime + seconds
      target.cwNextTalkLOOC = curTime + seconds

      cw.player:NotifyAll(L('Command_Plymute_Muted', player:Name(), target:Name(), duration))
    else
      cw.player:Notify(player, L('Command_PlayerProtected', target:Name()))
    end
  else
    cw.player:Notify(player, L('NotValidPlayer', arguments[1]))
  end
end

COMMAND:Register()
