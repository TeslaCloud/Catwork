--- Registers the `/Me` command (alias `/Perform`), which prints a roleplay action of the caller's character in the chat
-- of nearby players.

local COMMAND = cw.command:New('Me')
COMMAND.tip = '#Commands_MeDesc'
COMMAND.text = '#Command_Me_Syntax'
COMMAND.arguments = 1
COMMAND.alias = { 'Perform', 'me' }
COMMAND.cooldown = 2

--- Prints a roleplay action in the chat of nearby players; the arguments are the action text.
function COMMAND:OnRun(player, arguments)
  local text = ''

  for k, v in ipairs(arguments) do
    text = text..v..' '
  end

  if string.Left(text, 3) == 'me ' then
    text = string.gsub(text, 'me ', '', 1)
  end

  if text == '' then
    cw.player:Notify(player, L(player, 'NotEnoughText'))

    return
  end

  chatbox.AddText(nil, text, {
    isPlayerMessage = true,
    sender = player,
    noStyling = true,
    fakeName = true,
    position = player:GetPos(),
    textColor = Color('#89D235'),
    filter = 'player_events',
    icon = false
  })
end

COMMAND:Register()
