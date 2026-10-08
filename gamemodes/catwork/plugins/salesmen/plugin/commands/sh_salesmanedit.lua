--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New('SalesmanEdit')
COMMAND.tip = '#Command_Salesmanedit_Description'
COMMAND.text = '#Command_Salesmanedit_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'
COMMAND.optionalArguments = 1

--- Removes the salesman the player is looking at and opens the editor with its settings, so closing
-- the editor respawns it in place.
function COMMAND:OnRun(player, arguments)
  local target = player:GetEyeTraceNoCursor().Entity

  if IsValid(target) then
    if target:GetClass() == 'cw_salesman' then
      local salesmanTable = cwSalesmen:GetTableFromEntity(target)

      player.cwSalesmanSetup = true
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

      netstream.Start(player, 'SalesmanEdit', salesmanTable)

      for k, v in pairs(cwSalesmen.salesmen) do
        if target == v then
          target.cwCash = nil
          target:Remove()
          cwSalesmen.salesmen[k] = nil
          cwSalesmen:SaveSalesmen()

          return
        end
      end
    else
      cw.player:Notify(player, L('Salesman_NotSalesman'))
    end
  else
    cw.player:Notify(player, L('Salesman_LookAtValidEntity'))
  end
end

COMMAND:Register()
