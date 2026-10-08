--- Registers the operator command `/Announce`, which shows a notification with the given text to every player.

local COMMAND = cw.command:New('Announce')

COMMAND.tip = '#Command_Announce_Description'
COMMAND.text = '#Command_Announce_Syntax'
COMMAND.arguments = 1
COMMAND.access = 'o'

--- Shows a notification with the given text to every player; the arguments are the announcement text.
function COMMAND:OnRun(player, arguments)
  local text = table.concat(arguments, ' ')

  cw.player:NotifyAll(text)
end

COMMAND:Register()
