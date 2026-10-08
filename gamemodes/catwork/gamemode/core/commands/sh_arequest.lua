--- Registers the `/ARequest` command (alias `/AR`), which sends the caller's help request to all online staff and tells
-- staff callers to use `/A` instead.

local COMMAND = cw.command:New('ARequest')
COMMAND.tip = '#Command_Arequest_Description'
COMMAND.text = '#Command_Arequest_Syntax'
COMMAND.arguments = 1
COMMAND.alias = { 'AR' }
COMMAND.cooldown = 2

--- Sends a help request to all online staff; the arguments are the request text.
--
-- Staff members are told to use `/A` instead.
function COMMAND:OnRun(player, arguments)
  if !cw.player:IsAdmin(player) then
    cw.player:NotifyAdmins('o', L('Command_Arequest_From', player:Name())..' '..table.concat(arguments, ' '), nil)
  else
    cw.player:Notify(player, L('UseA'))
  end
end

COMMAND:Register()
