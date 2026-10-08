--- Registers the `/It` command, which prints a description of the surroundings in the chat of players near the caller.

local COMMAND = cw.command:New('It')
COMMAND.tip = '#Command_It_Description'
COMMAND.text = '#Command_It_Syntax'
COMMAND.arguments = 1
COMMAND.cooldown = 3

--- Prints an environment description in the chat of nearby players; the arguments are the text.
--
-- The text must be at least eight characters long.
function COMMAND:OnRun(player, arguments)
  local text = table.concat(arguments, ' ')

  if string.utf8len(text) < 8 then
    cw.player:Notify(player, L(player, 'NotEnoughText'))

    return
  end

  chatbox.AddText(nil, text, {
    position = player:GetPos(),
    textColor = Color('#3599D2'),
    filter = 'player_events',
    icon = false
  })
end

COMMAND:Register()
