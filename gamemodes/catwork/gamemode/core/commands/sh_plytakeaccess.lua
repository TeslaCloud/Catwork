--- Registers the superadmin command `/PlyTakeAccess` (alias `/TakeAccess`), which removes the target player's
-- permission to use a command.

local COMMAND = cw.command:New('PlyTakeAccess')
COMMAND.tip = '#Command_Plytakeaccess_Description'
COMMAND.text = '#Command_Plytakeaccess_Syntax'
COMMAND.access = 's'
COMMAND.arguments = 2
COMMAND.alias = { 'TakeAccess' }

--- Removes a command permission from the target player; arguments are the player name and the command.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])
  local permission = string.lower(arguments[2])

  if IsValid(target) then
    if isstring(permission) and permission != '' then
      local commandTable = cw.command:FindByAlias(permission)

      if commandTable then
        target:TakePermission(commandTable.uniqueID)

        cw.player:Notify(player, L('Command_Plytakeaccess_Removed', target:Name(), commandTable.name))
        cw.player:Notify(target, L('Command_Plytakeaccess_RemovedTarget', player:Name(), commandTable.name))
      else
        cw.player:Notify(player, L('Command_NotValidCommandOrAlias', arguments[2]))
      end
    else
      cw.player:Notify(player, L('Command_MustEnterPermission'))
    end
  else
    cw.player:Notify(player, L(player, 'NotValidCharacter', arguments[1]))
  end
end

COMMAND:Register()
