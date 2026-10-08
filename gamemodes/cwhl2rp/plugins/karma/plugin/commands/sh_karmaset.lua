COMMAND = cw.command:New('KarmaSet')
COMMAND.tip = '#Command_Karmaset_Description'
COMMAND.text = '#Command_Karmaset_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'o'
COMMAND.arguments = 2
COMMAND.alias = { 'CharSetKarma', 'SetKarma' }

--- Sets the target character's karma to a value from -100 to 100.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])
  local karma = tonumber(arguments[2])

  if target then
    if karma and karma <= 100 and karma >= -100 then
      target:SetKarma(karma)
      cw.player:Notify(player, L('Karma_SetTo', target:Name(), karma))
    else
      cw.player:Notify(player, L('Karma_InvalidLevel'))
    end
  else
    cw.player:Notify(player, L('NotValidPlayer', arguments[1]))
  end
end

COMMAND:Register()
