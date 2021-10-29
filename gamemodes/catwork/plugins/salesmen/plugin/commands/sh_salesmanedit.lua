--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("SalesmanEdit")
COMMAND.tip = "Edit a salesman at your target position."
COMMAND.text = "[number Animation]"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "s"
COMMAND.optionalArguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = player:GetEyeTraceNoCursor().Entity

	if (IsValid(target)) then
		if (target:GetClass() == "cw_salesman") then
			local salesmanTable = cwSalesmen:GetTableFromEntity(target)

			player.cwSalesmanSetup = true
			player.cwSalesmanAnim = tonumber(arguments[1])
			player.cwSalesmanPos = target:GetPos()
			player.cwSalesmanAng = target:GetAngles()
			player.cwSalesmanHitPos = player:GetEyeTraceNoCursor().HitPos

			if (!player.cwSalesmanAnim and type(arguments[1]) == "string") then
				player.cwSalesmanAnim = tonumber(_G[arguments[1]])
			end

			if (!player.cwSalesmanAnim and salesmanTable.animation) then
				player.cwSalesmanAnim = salesmanTable.animation
			end

			netstream.Start(player, "SalesmanEdit", salesmanTable)

			for k, v in pairs(cwSalesmen.salesmen) do
				if (target == v) then
					target.cwCash = nil
					target:Remove()
					cwSalesmen.salesmen[k] = nil
					cwSalesmen:SaveSalesmen()

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
