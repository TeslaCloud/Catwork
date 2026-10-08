--- Registers the operator command `/SetVoicemail`, which sets the automatic reply the caller's character gives to
-- `/PM`, or removes it with `none`.

local COMMAND = cw.command:New('SetVoicemail')
COMMAND.tip = '#Command_Setvoicemail_Description'
COMMAND.text = '#Command_Setvoicemail_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'o'
COMMAND.arguments = 1

--- Sets the caller's voicemail reply for private messages; the argument is the text, or `none` to remove it.
function COMMAND:OnRun(player, arguments)
  if arguments[1] == 'none' then
    player:SetCharacterData('Voicemail', nil)
    cw.player:Notify(player, L('VoicemailRemoved'))
  else
    player:SetCharacterData('Voicemail', arguments[1])
    cw.player:Notify(player, L('VoicemailSet', arguments[1]))
  end
end

COMMAND:Register()
