--- Registers `/PKModeOff`, an operator command that turns perma-kill mode off by setting the `PKMode` global net var to
-- 0 and removing the `pk_mode` timer.

local COMMAND = cw.command:New('PKModeOff')
COMMAND.tip = '#Command_Pkmodeoff_Description'
COMMAND.access = 'o'

--- Turns off PK mode by setting the `PKMode` global net var to `0`; takes no arguments.
function COMMAND:OnRun(player, arguments)
  netvars.SetNetVar('PKMode', 0)
  timer.Remove('pk_mode')

  cw.player:NotifyAll(L('PKMode_Off', player:Name()))
end

COMMAND:Register()
