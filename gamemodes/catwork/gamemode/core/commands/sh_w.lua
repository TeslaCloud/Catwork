--- Registers the `/W` command, which whispers an in-character message to players within a third of the `talk_radius`
-- config, at most 80 units.

local COMMAND = cw.command:New('W')
COMMAND.tip = '#Commands_WDesc'
COMMAND.text = '#Command_W_Syntax'
COMMAND.flags = bit.bor(CMD_DEFAULT, CMD_DEATHCODE)
COMMAND.arguments = 1

--- Whispers a message to players close to the caller; the arguments are the message.
function COMMAND:OnRun(player, arguments)
  local talkRadius = math.min(config.GetVal('talk_radius') / 3, 80)
  local text = table.concat(arguments, ' ')

  if string.Left(text, 2) == 'w ' then
    text = string.gsub(text, 'w ', '', 1)
  end

  if text == '' then
    cw.player:Notify(player, L(player, 'NotEnoughText'))

    return
  end

  chatbox.AddText(nil, '"'..text..'"', {
    suffix = ' #Suffix_Whisper ',
    sender = player,
    isPlayerMessage = true,
    filter = 'ic',
    radius = talkRadius,
    textColor = Color(255, 255, 230, 200),
    data = { sizeMultiplier = 0.85 }
  })
end

COMMAND:Register()
