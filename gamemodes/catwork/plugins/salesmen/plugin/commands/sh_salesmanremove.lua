--- Registers the `/SalesmanRemove` superadmin command, which removes the salesman the player is looking at.

local COMMAND = cw.command:New('SalesmanRemove')
COMMAND.tip = '#Command_Salesmanremove_Description'
COMMAND.access = 's'

--- Removes the salesman the player is looking at and saves the salesmen.
function COMMAND:OnRun(player, arguments)
  local target = player:GetEyeTraceNoCursor().Entity

  if IsValid(target) then
    if target:GetClass() == 'cw_salesman' then
      cwSalesmen:RemoveSalesman(target)
      cwSalesmen:SaveSalesmen()

      cw.player:Notify(player, L('Salesman_Removed'))
    else
      cw.player:Notify(player, L('Salesman_NotSalesman'))
    end
  else
    cw.player:Notify(player, L('Salesman_LookAtValidEntity'))
  end
end

COMMAND:Register()
