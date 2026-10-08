--- Registers the `/Event` command (alias `/E`), which prints an event message in every player's chat and requires the
-- `z` flag.

local COMMAND = cw.command:New('Event')
COMMAND.tip = '#Command_Event_Description'
COMMAND.text = '#Command_Event_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'z'
COMMAND.arguments = 1
COMMAND.alias = { 'E' }

--- Prints an event message in every player's chat; the arguments are the event text.
function COMMAND:OnRun(player, arguments)
  local text = table.concat(arguments, ' ')

  if string.Left(text, 6) == 'event ' then
    text = string.gsub(text, 'event ', '', 1)
  end

  chatbox.AddText(nil, '** '..text, { filter = 'events', textColor = Color('#FFAB00'), icon = false })
end

COMMAND:Register()
