--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New('PKModeOn')
COMMAND.tip = '#Command_Pkmodeon_Description'
COMMAND.text = '#Command_Pkmodeon_Syntax'
COMMAND.access = 'o'
COMMAND.arguments = 1

--- Turns on PK mode for the number of minutes given as the first argument.
function COMMAND:OnRun(player, arguments)
  local minutes = tonumber(arguments[1])

  if minutes and minutes > 0 then
    netvars.SetNetVar('PKMode', 1)
    timer.Create('pk_mode', minutes * 60, 1, function()
      netvars.SetNetVar('PKMode', 0)

      cw.player:NotifyAll(L('PKMode_AutoOff'))
    end)

    cw.player:NotifyAll(L('PKMode_On', player:Name(), minutes))
  else
    cw.player:Notify(player, L('PKMode_InvalidMinutes'))
  end
end

COMMAND:Register()
