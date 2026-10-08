--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New('PlyVoiceUnban')
COMMAND.tip = '#Command_Plyvoiceunban_Description'
COMMAND.text = '#Command_Plyvoiceunban_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'o'
COMMAND.arguments = 1
COMMAND.alias = { 'VoiceUnban', 'PlyUnbanVoice' }

--- Lifts the target player's voice chat ban; the argument is the player name.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])

  if IsValid(target) then
    if target:GetData('VoiceBan') then
      target:SetData('VoiceBan', false)
    else
      cw.player:Notify(player, L('Command_Plyvoiceunban_NotBanned', target:Name()))
    end
  end
end

COMMAND:Register()
