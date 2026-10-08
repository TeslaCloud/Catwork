--- Registers the admin command `/CharSetThirst` of the Hunger plugin, which sets the target character's `Thirst`
-- character data to the given amount, 100 by default; its aliases `/SetFatigue`, `/SetSleep` and `/CharSetSleep` are
-- the same as those of `/CharSetFatigue`.

local PLUGIN = PLUGIN

local COMMAND = cw.command:New('CharSetThirst')
COMMAND.tip = '#Command_Charsetthirst_Description'
COMMAND.text = '#Command_Charsetthirst_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'
COMMAND.arguments = 2
COMMAND.alias = { 'SetFatigue', 'SetSleep', 'CharSetSleep' }

--- Sets a character's thirst to the given amount, 100 by default.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])
  local amount = arguments[2]

  if !amount then
    amount = 100
  end

  if target then
    target:SetCharacterData('Thirst', amount)

    if player != target then
      cw.player:Notify(target, L('Hunger_ThirstSetBy', player:Name(), amount))
      cw.player:Notify(player, L('Hunger_ThirstSet', target:Name(), amount))
    else
      cw.player:Notify(player, L('Hunger_ThirstSetOwn', amount))
    end
  else
    cw.player:Notify(player, L('NotValidPlayer', arguments[1]))
  end
end

COMMAND:Register()
