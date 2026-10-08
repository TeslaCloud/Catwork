--- Registers the operator command `/EventLocal` (aliases `/LocalEvent`, `/EL`), which prints an event message in the
-- chat of players near the caller.

local COMMAND = cw.command:New('EventLocal')
COMMAND.tip = '#Command_Eventlocal_Description'
COMMAND.text = '#Command_Eventlocal_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'o'
COMMAND.arguments = 1
COMMAND.alias = { 'LocalEvent', 'EL' }

--- Prints an event message in the chat of players near the caller; the arguments are the event text.
function COMMAND:OnRun(player, arguments)
  local text = table.concat(arguments, ' ')

  if string.Left(text, 11) == 'eventlocal ' then
    text = string.gsub(text, 'eventlocal ', '', 1)
  end

  chatbox.AddText(nil, '* '..text, {
    filter = 'player_events',
    textColor = Color('#FFAB00'),
    icon = false,
    position = player:GetPos()
  })
end

COMMAND:Register()
