--- Registers the `/Radio` command (aliases `/R`, `/Rs`), which sends the caller's message over the radio through
-- `cw.player:SayRadio`.

local COMMAND = cw.command:New('Radio')
COMMAND.tip = '#Commands_RDesc'
COMMAND.text = '#Command_Radio_Syntax'
COMMAND.flags = bit.bor(CMD_DEFAULT, CMD_DEATHCODE, CMD_FALLENOVER)
COMMAND.arguments = 1
COMMAND.alias = { 'R', 'Rs' }
COMMAND.cooldown = 2

--- Sends a radio message through `cw.player:SayRadio`; the arguments are the message.
function COMMAND:OnRun(player, arguments)
  cw.player:SayRadio(player, table.concat(arguments, ' '), true)
end

COMMAND:Register()
