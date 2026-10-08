--- Registers the `/SalesmanRemove` superadmin command, which removes the salesman the player is looking at.

local COMMAND = cw.command:New('SalesmanRemove')
COMMAND.tip = '#Command_Salesmanremove_Description'
COMMAND.access = 's'

--- Removes the salesman the player is looking at and saves the salesmen.
function COMMAND:OnRun(player, arguments)
  local target = player:GetEyeTraceNoCursor().Entity

  if IsValid(target) then
    if target:GetClass() == 'cw_salesman' then
      for k, v in pairs(cwSalesmen.salesmen) do
        if target == v then
          target:Remove()
          cwSalesmen.salesmen[k] = nil
          cwSalesmen:SaveSalesmen()

          cw.player:Notify(player, L('Salesman_Removed'))

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
