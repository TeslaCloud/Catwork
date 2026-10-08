--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

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
