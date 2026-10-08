--- Registers the `/SalesmanEdit` superadmin command, which opens the editor with the settings of the salesman the
-- player is looking at, so that closing the editor replaces it in place.

local COMMAND = cw.command:New('SalesmanEdit')
COMMAND.tip = '#Command_Salesmanedit_Description'
COMMAND.text = '#Command_Salesmanedit_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'
COMMAND.optionalArguments = 1

--- Opens the editor with the settings of the salesman the player is looking at.
--
-- The salesman stays on the map until the editor is closed and its `SalesmanAdd` message replaces it.
function COMMAND:OnRun(player, arguments)
  local target = player:GetEyeTraceNoCursor().Entity

  if IsValid(target) then
    if target:GetClass() == 'cw_salesman' then
      local salesmanTable = cwSalesmen:GetTableFromEntity(target)

      player.cwSalesmanSetup = true
      player.cwSalesmanEdit = target
      player.cwSalesmanAnim = tonumber(arguments[1])
      player.cwSalesmanPos = target:GetPos()
      player.cwSalesmanAng = target:GetAngles()
      player.cwSalesmanHitPos = player:GetEyeTraceNoCursor().HitPos

      if !player.cwSalesmanAnim and type(arguments[1]) == 'string' then
        player.cwSalesmanAnim = tonumber(_G[arguments[1]])
      end

      if !player.cwSalesmanAnim and salesmanTable.animation then
        player.cwSalesmanAnim = salesmanTable.animation
      end

      cable.send(player, 'SalesmanEdit', salesmanTable)
    else
      cw.player:Notify(player, L('Salesman_NotSalesman'))
    end
  else
    cw.player:Notify(player, L('Salesman_LookAtValidEntity'))
  end
end

COMMAND:Register()
