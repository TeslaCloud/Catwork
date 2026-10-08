--- Registers the operator command `/PlyUnban` (alias `/Unban`), which lifts the ban stored in `cw.bans` for a Steam ID
-- or IP address.

local COMMAND = cw.command:New('PlyUnban')
COMMAND.tip = '#Command_Plyunban_Description'
COMMAND.text = '#Command_Plyunban_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'o'
COMMAND.arguments = 1
COMMAND.alias = { 'Unban' }

--- Lifts a ban; the argument is the banned Steam ID or IP address as stored in `cw.bans`.
function COMMAND:OnRun(player, arguments)
  local identifier = string.upper(arguments[1])

  if cw.bans.stored[identifier] then
    cw.player:NotifyAll(L('Command_Plyunban_Unbanned', player:Name(), cw.bans.stored[identifier].steamName))
    cw.bans:Remove(identifier)
  else
    cw.player:Notify(player, L('Command_Plyunban_NotFound', identifier))
  end
end

COMMAND:Register()
