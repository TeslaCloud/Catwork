--- Registers the superadmin command `/PlyGiveAccess` (alias `/GiveAccess`), which grants the target player permission
-- to use a command given by name or alias.

local COMMAND = cw.command:New('PlyGiveAccess')
COMMAND.tip = '#Command_Plygiveaccess_Description'
COMMAND.text = '#Command_Plygiveaccess_Syntax'
COMMAND.access = 's'
COMMAND.arguments = 2
COMMAND.alias = { 'GiveAccess' }

--- Lets the target player use a command; arguments are the player name and the command name or alias.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])
  local permission = string.lower(arguments[2])

  if IsValid(target) then
    if isstring(permission) and permission != '' then
      local commandTable = cw.command:FindByAlias(permission)

      if commandTable then
        target:GivePermission(commandTable.uniqueID)

        cw.player:Notify(player, L('Command_Plygiveaccess_Granted', target:Name(), commandTable.name))
        cw.player:Notify(target, L('Command_Plygiveaccess_GrantedTarget', player:Name(), commandTable.name))
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
