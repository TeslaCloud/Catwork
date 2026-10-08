--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

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
