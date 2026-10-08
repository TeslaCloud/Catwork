--- Registers the `/PM` command, which sends a private message to the target player or shows their voicemail when they
-- have one set.

local COMMAND = cw.command:New('PM')
COMMAND.tip = '#Commands_PMDesc'
COMMAND.text = '#Command_Pm_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.arguments = 2
COMMAND.cooldown = 5

--- Sends a private message to the target player; arguments are the player name and the message.
--
-- If the target has a voicemail set, the voicemail is sent to both players instead.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])

  if target then
    local voicemail = target:GetCharacterData('Voicemail')

    if voicemail and voicemail != '' then
      chatbox.AddText({ target, player }, voicemail, {
        sender = player,
        isPlayerMessage = true,
        filter = 'pm',
        textColor = Color('#FFFF00')
      })
    else
      chatbox.AddText({ target, player }, table.concat(arguments, ' ', 2), {
        sender = player,
        isPlayerMessage = true,
        filter = 'pm',
        type = 'pm',
        textColor = Color('#65DBAC'),
        icon = false
      })
    end
  else
    cw.player:Notify(player, L('NotValidPlayer', arguments[1]))
  end
end

COMMAND:Register()
