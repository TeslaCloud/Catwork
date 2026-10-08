--- Registers the superadmin command `/CharCheckAtts` (alias `/CheckAtts`), which lists the target character's attribute
-- values to the caller.

local COMMAND = cw.command:New('CharCheckAtts')
COMMAND.tip = '#Command_Charcheckatts_Description'
COMMAND.text = '#Command_Charcheckatts_Syntax'
COMMAND.access = 's'
COMMAND.arguments = 1
COMMAND.alias = { 'CheckAtts' }

--- Lists the target character's attribute values to the caller; the argument is the character name.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])

  if target then
    cw.player:Notify(player, L('Command_Charcheckatts_Header', target:GetName()))

    for k, v in pairs(cw.attribute:GetAll()) do
      cw.player:Notify(player, v.name..': '..(cw.attributes:Get(target, k, nil, true) or 0))
    end
  else
    cw.player:Notify(player, L(player, 'NotValidCharacter', arguments[1]))
  end
end

COMMAND:Register()
