--- Registers `/CharSetCustomClass`, an operator command that sets a character's `customclass` character data to a
-- custom class name.

local COMMAND = cw.command:New('CharSetCustomClass')
COMMAND.tip = '#Command_Charsetcustomclass_Description'
COMMAND.text = '#Command_Charsetcustomclass_Syntax'
COMMAND.access = 'o'
COMMAND.arguments = 2

--- Sets the custom class of the character named in the first argument to the second argument.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])

  if target then
    target:SetCharacterData('customclass', arguments[2])

    cw.player:NotifyAll(L('CustomClass_Set', player:Name(), target:Name())..' '..arguments[2]..'.')
  else
    cw.player:Notify(player, L('NotValidCharacter', arguments[1]))
  end
end

COMMAND:Register()
