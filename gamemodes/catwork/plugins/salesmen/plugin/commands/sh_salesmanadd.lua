--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New('SalesmanAdd')
COMMAND.tip = '#Command_Salesmanadd_Description'
COMMAND.text = '#Command_Salesmanadd_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'
COMMAND.optionalArguments = 1

--- Opens the salesman editor for a new salesman at the point the player is looking at.
--
-- The optional argument is the animation sequence, as a number or the name of a global constant.
function COMMAND:OnRun(player, arguments)
  player.cwSalesmanSetup = true
  player.cwSalesmanAnim = tonumber(arguments[1])
  player.cwSalesmanHitPos = player:GetEyeTraceNoCursor().HitPos

  if !player.cwSalesmanAnim and type(arguments[1]) == 'string' then
    player.cwSalesmanAnim = tonumber(_G[arguments[1]])
  end

  netstream.Start(player, 'SalesmanAdd', true)
end

COMMAND:Register()
