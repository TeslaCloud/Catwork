--- Registers the admin command `/CharSetHunger` (alias `/SetHunger`) of the Hunger plugin, which sets the target
-- character's `Hunger` character data to the given amount, 100 by default.

local PLUGIN = PLUGIN

local COMMAND = cw.command:New('CharSetHunger')
COMMAND.tip = '#Command_Charsethunger_Description'
COMMAND.text = '#Command_Charsethunger_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'
COMMAND.arguments = 2
COMMAND.alias = { 'SetHunger' }

--- Sets a character's hunger to the given amount, 100 by default.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])
  local amount = tonumber(arguments[2])

  if !amount or amount != amount then
    amount = 100
  end

  amount = math.Clamp(amount, 0, 100)

  if target then
    target:SetCharacterData('Hunger', amount)

    if player != target then
      cw.player:Notify(target, L('Hunger_HungerSetBy', player:Name(), amount))
      cw.player:Notify(player, L('Hunger_HungerSet', target:Name(), amount))
    else
      cw.player:Notify(player, L('Hunger_HungerSetOwn', amount))
    end
  else
    cw.player:Notify(player, L('NotValidPlayer', arguments[1]))
  end
end

COMMAND:Register()
