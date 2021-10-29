--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("SalesmanRemove")
COMMAND.tip = "Remove a salesman at your target position."
COMMAND.access = "s"

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = player:GetEyeTraceNoCursor().Entity

	if (IsValid(target)) then
		if (target:GetClass() == "cw_salesman") then
			for k, v in pairs(cwSalesmen.salesmen) do
				if (target == v) then
					target:Remove()
					cwSalesmen.salesmen[k] = nil
					cwSalesmen:SaveSalesmen()

					cw.player:Notify(player, "You have removed a salesman.")

					return
				end
			end
		else
			cw.player:Notify(player, "This entity is not a salesman!")
		end
	else
		cw.player:Notify(player, "You must look at a valid entity!")
	end
end

COMMAND:Register();
