--- Registers the `/SalesmanAdd` superadmin command, which opens the salesman editor to create a salesman where the
-- player is looking, with an optional animation.

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

  -- Forget an edit that was started and never finished, or the new salesman would replace the edited one.
  player.cwSalesmanEdit = nil
  player.cwSalesmanPos = nil
  player.cwSalesmanAng = nil

  if !player.cwSalesmanAnim and type(arguments[1]) == 'string' then
    player.cwSalesmanAnim = tonumber(_G[arguments[1]])
  end

  netstream.Start(player, 'SalesmanAdd', true)
end

COMMAND:Register()
