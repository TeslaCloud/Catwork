--- Registers the superadmin command `/CfgListVars`, which prints the config variables to the caller's console,
-- optionally filtered by a search string.

local COMMAND = cw.command:New('CfgListVars')
COMMAND.tip = '#Command_Cfglistvars_Description'
COMMAND.text = '#Command_Cfglistvars_Syntax'
COMMAND.access = 's'

--- Prints the config variables to the caller's console; the optional argument is a search filter.
function COMMAND:OnRun(player, arguments)
  local searchData = arguments[1] or ''
    cable.send(player, 'CfgListVars', searchData)
  cw.player:Notify(player, L(player, 'ConfigVariablesPrinted'))
end

COMMAND:Register()
