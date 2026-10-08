COMMAND = cw.command:New('KarmaGet')
COMMAND.tip = '#Command_Karmaget_Description'
COMMAND.text = '#Command_Karmaget_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'o'
COMMAND.arguments = 1
COMMAND.alias = { 'CharGetKarma', 'GetKarma' }

--- Tells the player the target character's karma level and value.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])

  if target then
    cw.player:Notify(player, target:GetKarmaLevel()..' ('..target:GetCharacterData('karma', 0)..')')
  else
    cw.player:Notify(player, L('NotValidPlayer', arguments[1]))
  end
end

COMMAND:Register()
