--- Registers the operator command `/PlyVoiceBan` (aliases `/VoiceBan`, `/PlyBanVoice`), which bans the target player
-- from voice chat.

local COMMAND = cw.command:New('PlyVoiceBan')
COMMAND.tip = '#Command_Plyvoiceban_Description'
COMMAND.text = '#Command_Plyvoiceban_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'o'
COMMAND.arguments = 1
COMMAND.alias = { 'VoiceBan', 'PlyBanVoice' }

--- Bans the target player from voice chat; the argument is the player name.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])

  if IsValid(target) then
    if !target:GetData('VoiceBan') then
      target:SetData('VoiceBan', true)
    else
      cw.player:Notify(player, L('Command_Plyvoiceban_AlreadyBanned', target:Name()))
    end
  else
    cw.player:Notify(player, L('NotValidPlayer', arguments[1]))
  end
end

COMMAND:Register()
