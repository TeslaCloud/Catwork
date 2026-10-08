--- Registers the operator command `/CharSetName` (alias `/SetName`), which renames the target character.

local COMMAND = cw.command:New('CharSetName')
COMMAND.tip = '#Command_Charsetname_Description'
COMMAND.text = '#Command_Charsetname_Syntax'
COMMAND.access = 'o'
COMMAND.arguments = 2
COMMAND.alias = { 'SetName' }

-- The characters table stores names in a `varchar(150)` column.
local MAX_NAME_LENGTH = 150

--- Renames the target character; arguments are the character name and the new name.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])

  if target then
    local name = table.concat(arguments, ' ', 2)

    if string.Trim(name) == '' then
      cw.player:Notify(player, L('NotEnoughText'))
      return
    end

    if string.utf8len(name) > MAX_NAME_LENGTH then
      cw.player:Notify(player, L('Command_TextTooLong', MAX_NAME_LENGTH))
      return
    end

    cw.player:NotifyAll(L('Command_Charsetname_Set', player:Name(), target:Name(), name))

    cw.player:SetName(target, name)
  else
    cw.player:Notify(player, L(player, 'NotValidCharacter', arguments[1]))
  end
end

COMMAND:Register()
