--[[
	Catwork © 2016 Some good coders
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.

local COMMAND = cw.command:New("OrderShipment")
COMMAND.tip = "#Command_Ordershipment_Description"
COMMAND.text = "#Command_Ordershipment_Syntax"
COMMAND.flags = bit.bor(CMD_DEFAULT, CMD_FALLENOVER)
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	return false
	local itemTable = item.FindByID(arguments[1])

	if (!itemTable or !itemTable:CanBeOrdered()) then
		return false
	end

	itemTable = item.CreateInstance(itemTable.uniqueID)
	hook.Run("PlayerAdjustOrderItemTable", player, itemTable)

	if (!cw.core:HasObjectAccess(player, itemTable)) then
		cw.player:Notify(player, "You not have access to order this item!")
		return false
	end

	if (!hook.Run("PlayerCanOrderShipment", player, itemTable)) then
		return false
	end

	if (player.cwNextOrderTime and CurTime() < player.cwNextOrderTime) then
		return false
	end

	if (itemTable:CanPlayerAfford(player)) then
		local trace = player:GetEyeTraceNoCursor()
		local entity = nil

		if (player:GetShootPos():Distance(trace.HitPos) <= 192) then
			if (itemTable.CanOrder and itemTable:CanOrder(player, v) == false) then
				return false
			end

			if (itemTable.OnCreateShipmentEntity) then
				entity = itemTable:OnCreateShipmentEntity(player, itemTable.batch, trace.HitPos)
			end

			if (!IsValid(entity)) then
				if (itemTable.batch > 1) then
					entity = cw.entity:CreateShipment(player, itemTable.uniqueID, itemTable.batch, trace.HitPos)
				else
					entity = cw.entity:CreateItem(player, itemTable, trace.HitPos)
				end
			end

			if (IsValid(entity)) then
				cw.entity:MakeFlushToGround(entity, trace.HitPos, trace.HitNormal)
			end

			itemTable:DeductFunds(player)

			if (itemTable.batch > 1 and entity.cwInventory) then
				local itemTables = cw.inventory:GetItemsByID(
					entity.cwInventory, itemTable.uniqueID
				)

				for k, v in pairs(itemTables) do
					if (v.OnOrder) then
						v:OnOrder(player, entity)
					end
				end

				hook.Run("PlayerOrderShipment", player, itemTable, entity, itemTables)
			else
				if (entity.GetItemTable) then
					itemTable = entity:GetItemTable()
				end

				hook.Run("PlayerOrderShipment", player, itemTable, entity)

				if (itemTable.OnOrder) then
					itemTable:OnOrder(player, entity)
				end
			end

			player.cwNextOrderTime = CurTime() + (2 * itemTable.batch)
			netstream.Start(player, "OrderTime", player.cwNextOrderTime)
		else
			cw.player:Notify(player, "You cannot order this item that far away!")
		end
	else
		local amount = (itemTable.cost * itemTable.batch) - player:GetCash()
		cw.player:Notify(player, "You need another "..cw.core:FormatCash(amount, nil, true).."!")
	end
end

COMMAND:Register();--]]
