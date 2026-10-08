--- Registers the operator command `/CharSetModel` (alias `/SetModel`), which sets and saves the target character's
-- model.

local COMMAND = cw.command:New('CharSetModel')
COMMAND.tip = '#Command_Charsetmodel_Description'
COMMAND.text = '#Command_Charsetmodel_Syntax'
COMMAND.access = 'o'
COMMAND.arguments = 2
COMMAND.alias = { 'SetModel' }

--- Sets and saves the target character's model; arguments are the character name and the model path.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])

  if target then
    local model = table.concat(arguments, ' ', 2)

    target:SetCharacterData('Model', model, true)
    target:SetModel(model)

    cw.player:NotifyAll(L('Command_Charsetmodel_Set', player:Name(), target:Name(), model))
  else
    cw.player:Notify(player, L(player, 'NotValidCharacter', arguments[1]))
  end
end

COMMAND:Register()
