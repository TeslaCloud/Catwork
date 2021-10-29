--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- A function to load the shipments.
function cwSaveItems:LoadShipments()
	local shipments = cw.core:RestoreSchemaData("plugins/shipments/"..game.GetMap())

	for k, v in pairs(shipments) do
		if (item.GetStored()[v.item]) then
			local entity = cw.entity:CreateShipment(
				{key = v.key, uniqueID = v.uniqueID}, v.item, v.amount, v.position, v.angles
			)

			if (IsValid(entity) and !v.isMoveable) then
				local physicsObject = entity:GetPhysicsObject()

				if (IsValid(physicsObject)) then
					physicsObject:EnableMotion(false)
				end
			end
		end
	end
end

-- A function to save the shipments.
function cwSaveItems:SaveShipments()
	local shipments = {}

	for k, v in pairs(ents.FindByClass("cw_shipment")) do
		local physicsObject = v:GetPhysicsObject()
		local itemTable = v:GetItemTable()
		local bMoveable = nil

		if (IsValid(physicsObject)) then
			bMoveable = physicsObject:IsMoveable()
		end

		shipments[#shipments + 1] = {
			key = cw.entity:QueryProperty(v, "key"),
			item = itemTable.uniqueID,
			angles = v:GetAngles(),
			amount = table.Count(v.cwInventory[itemTable.uniqueID]),
			uniqueID = cw.entity:QueryProperty(v, "uniqueID"),
			position = v:GetPos(),
			isMoveable = bMoveable
		}
	end

	cw.core:SaveSchemaData("plugins/shipments/"..game.GetMap(), shipments)
end

-- A function to load the items.
function cwSaveItems:LoadItems()
	local items = cw.core:RestoreSchemaData("plugins/items/"..game.GetMap())

	for k, v in pairs(items) do
		local itemTable = item.CreateInstance(v.item, v.itemID, v.data)

		if (itemTable) then
			local entity = cw.entity:CreateItem(
				{key = v.key, uniqueID = v.uniqueID}, itemTable, v.position, v.angles
			)

			if (IsValid(entity) and !v.isMoveable) then
				local physicsObject = entity:GetPhysicsObject()

				if (IsValid(physicsObject)) then
					physicsObject:EnableMotion(false)
				end
			end
		end
	end
end

-- A function to save the items.
function cwSaveItems:SaveItems()
	local items = {}

	for k, v in pairs(ents.FindByClass("cw_item")) do
		local physicsObject = v:GetPhysicsObject()
		local itemTable = v:GetItemTable()
		local bMoveable = false

		if (IsValid(physicsObject)) then
			bMoveable = physicsObject:IsMoveable()
		end

		if (itemTable) then
			items[#items + 1] = {
				key = cw.entity:QueryProperty(v, "key"),
				item = itemTable.uniqueID,
				data = itemTable.data,
				itemID = itemTable.itemID,
				angles = v:GetAngles(),
				uniqueID = cw.entity:QueryProperty(v, "uniqueID"),
				position = v:GetPos(),
				isMoveable = bMoveable
			}
		end
	end

	cw.core:SaveSchemaData("plugins/items/"..game.GetMap(), items)
end
