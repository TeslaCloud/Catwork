--- Server-side functions of the Save Items plugin that save and respawn the `cw_item` and `cw_shipment` entities on the
-- map.
--
-- `cwSaveItems:SaveItems` and `cwSaveItems:LoadItems` keep each item instance with its item ID and data under
-- `plugins/items/<map>` in the schema data, and `cwSaveItems:SaveShipments` and `cwSaveItems:LoadShipments` keep each
-- shipment's item and remaining amount under `plugins/shipments/<map>`.

--- Spawns the shipments saved for the current map.
--
-- Shipments of items that no longer exist are skipped. Shipments that were frozen when saved are frozen
-- again.
function cwSaveItems:LoadShipments()
  local shipments = cw.core:RestoreSchemaData('plugins/shipments/'..game.GetMap())

  for k, v in pairs(shipments) do
    if item.GetStored()[v.item] then
      local entity = cw.entity:CreateShipment(
        { key = v.key, uniqueID = v.uniqueID }, v.item, v.amount, v.position, v.angles
      )

      if IsValid(entity) and !v.isMoveable then
        local physicsObject = entity:GetPhysicsObject()

        if IsValid(physicsObject) then
          physicsObject:EnableMotion(false)
        end
      end
    end
  end
end

--- Saves every `cw_shipment` entity on the map to the schema data.
--
-- Stores the item, the number of items left, position, angles, whether it can move, and the `key` and
-- `uniqueID` properties.
function cwSaveItems:SaveShipments()
  local shipments = {}

  for k, v in pairs(ents.FindByClass('cw_shipment')) do
    local physicsObject = v:GetPhysicsObject()
    local itemTable = v:GetItemTable()
    local bMoveable = nil

    if IsValid(physicsObject) then
      bMoveable = physicsObject:IsMoveable()
    end

    shipments[#shipments + 1] = {
      key = cw.entity:QueryProperty(v, 'key'),
      item = itemTable.uniqueID,
      angles = v:GetAngles(),
      amount = table.Count(v.cwInventory[itemTable.uniqueID]),
      uniqueID = cw.entity:QueryProperty(v, 'uniqueID'),
      position = v:GetPos(),
      isMoveable = bMoveable
    }
  end

  cw.core:SaveSchemaData('plugins/shipments/'..game.GetMap(), shipments)
end

--- Spawns the item entities saved for the current map.
--
-- Recreates each item instance with its saved item ID and data; items that cannot be created are skipped.
-- Items that were frozen when saved are frozen again.
function cwSaveItems:LoadItems()
  local items = cw.core:RestoreSchemaData('plugins/items/'..game.GetMap())

  for k, v in pairs(items) do
    local itemTable = item.CreateInstance(v.item, v.itemID, v.data)

    if itemTable then
      local entity = cw.entity:CreateItem(
        { key = v.key, uniqueID = v.uniqueID }, itemTable, v.position, v.angles
      )

      if IsValid(entity) and !v.isMoveable then
        local physicsObject = entity:GetPhysicsObject()

        if IsValid(physicsObject) then
          physicsObject:EnableMotion(false)
        end
      end
    end
  end
end

--- Saves every `cw_item` entity on the map to the schema data.
--
-- Stores the item, its item ID and data, position, angles, whether it can move, and the `key` and
-- `uniqueID` properties. Entities without an item table are skipped.
function cwSaveItems:SaveItems()
  local items = {}

  for k, v in pairs(ents.FindByClass('cw_item')) do
    local physicsObject = v:GetPhysicsObject()
    local itemTable = v:GetItemTable()
    local bMoveable = false

    if IsValid(physicsObject) then
      bMoveable = physicsObject:IsMoveable()
    end

    if itemTable then
      items[#items + 1] = {
        key = cw.entity:QueryProperty(v, 'key'),
        item = itemTable.uniqueID,
        data = itemTable.data,
        itemID = itemTable.itemID,
        angles = v:GetAngles(),
        uniqueID = cw.entity:QueryProperty(v, 'uniqueID'),
        position = v:GetPos(),
        isMoveable = bMoveable
      }
    end
  end

  cw.core:SaveSchemaData('plugins/items/'..game.GetMap(), items)
end
