--- Registers `/CharTakeCustomClass`, an operator command that clears a character's `customclass` character data.

local COMMAND = cw.command:New('CharTakeCustomClass')
COMMAND.tip = '#Command_Chartakecustomclass_Description'
COMMAND.text = '#Command_Chartakecustomclass_Syntax'
COMMAND.access = 'o'
COMMAND.arguments = 1

--- Removes the custom class of the character named in the first argument.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])

  if target then
    target:SetCharacterData('customclass', nil)

    cw.player:NotifyAll(L('CustomClass_Taken', player:Name(), target:Name()))
  else
    cw.player:Notify(player, L('NotValidCharacter', arguments[1]))
  end
end

COMMAND:Register()
