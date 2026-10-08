--- Defines the `cw.inventory` library, functions that work on inventory tables of item instances.
--
-- They add, remove, find and count instances, total up weight and space, and convert an inventory to and from its
-- saved form, without networking anything themselves. The client part holds the local player's inventory, kept up to
-- date by the `InvGive`, `InvTake`, `InvUpdate` and related messages, and the server part sends inventory updates to a
-- player.

library.New('inventory', cw)

--- Adds an item instance to an inventory table.
--
-- Only changes the table; it does not network anything or touch a player. Use `Player:GiveItem`
-- to give a player an item. For quantities above one, new instances of the same item are created
-- and added as well.
--
-- ```
-- cw.inventory:AddInstance(inventory, item.CreateInstance('ration'), 2)
-- ```
--
-- @param inventory [Inventory The inventory table]
-- @param itemTable [Item The item instance]
-- @param quantity=1 [Number How many of the item to add]
-- @return [Item The instance added, or `false` when `itemTable` is `nil` or not an instance]
function cw.inventory:AddInstance(inventory, itemTable, quantity)
  quantity = quantity or 1

  if itemTable == nil then
    return false
  end

  if !itemTable:IsInstance() then
    debug.Trace()
    return false
  end

  if !inventory[itemTable.uniqueID] then
    inventory[itemTable.uniqueID] = {}
  end

  inventory[itemTable.uniqueID][itemTable.itemID] = itemTable

  if quantity > 1 then
    self:AddInstance(inventory, item.CreateInstance(itemTable.uniqueID), quantity - 1)
  end

  return itemTable
end

--- Returns the total space taken by the items in an inventory.
-- @param inventory [Inventory The inventory table]
-- @return [Number The sum of the items' `space`]
function cw.inventory:CalculateSpace(inventory)
  local space = 0

  for k, v in pairs(inventory) do
    for k2, v2 in pairs(v) do
      if v2.space then
        space = space + v2.space
      end
    end
  end

  return space
end

--- Returns the total weight of the items in an inventory.
-- @param inventory [Inventory The inventory table]
-- @return [Number The sum of the items' `weight`]
function cw.inventory:CalculateWeight(inventory)
  local weight = 0

  for k, v in pairs(inventory) do
    for k2, v2 in pairs(v) do
      if v2.weight then
        weight = weight + v2.weight
      end
    end
  end

  return weight
end

--- Returns a copy of an inventory table.
--
-- The tables of each unique ID are copied, but the item instances in them are shared.
-- @param inventory [Inventory The inventory table]
-- @return [Inventory The copy]
function cw.inventory:CreateDuplicate(inventory)
  local duplicate = {}

    for k, v in pairs(inventory) do
      duplicate[k] = {}

      for k2, v2 in pairs(v) do
        duplicate[k][k2] = v2
      end
    end

  return duplicate
end

--- Finds an item instance in an inventory.
--
-- ```
-- local itemTable = cw.inventory:FindItemByID(player:GetInventory(), 'ration')
-- ```
--
-- @param inventory [Inventory The inventory table]
-- @param uniqueID [String Unique ID, index or name of the item, as accepted by `item.FindByID`]
-- @param itemID=nil [Number Item ID of the instance; any instance of the item when `nil`]
-- @return [Item The instance, or `nil` when the inventory has none]
function cw.inventory:FindItemByID(inventory, uniqueID, itemID)
  local itemTable = item.FindByID(uniqueID)

  if !inventory then
    debug.Trace()
    return
  end

  if itemID then
    itemID = tonumber(itemID)
  end

  if !itemTable or !inventory[itemTable.uniqueID] then
    return
  end

  local itemsList = inventory[itemTable.uniqueID]

  if itemID then
    if itemsList then
      return itemsList[itemID]
    end
  else
    local firstValue = table.GetFirstValue(itemsList)

    if firstValue then
      return itemsList[firstValue.itemID]
    end
  end
end

--- Finds the first instance of an item in an inventory whose name matches, case insensitive.
--
-- Both the instance's `name` and `PrintName` are compared.
-- @param inventory [Inventory The inventory table]
-- @param uniqueID [String Unique ID, index or name of the item, as accepted by `item.FindByID`]
-- @param name [String The name to match]
-- @return [Item The instance, or `nil` when none matches]
function cw.inventory:FindItemByName(inventory, uniqueID, name)
  local itemTable = item.FindByID(uniqueID)

  if !itemTable or !inventory[itemTable.uniqueID] then
    return
  end

  for k, v in pairs(inventory[itemTable.uniqueID]) do
    if string.utf8lower(v.name) == string.utf8lower(name)
    or string.utf8lower(v.PrintName) == string.utf8lower(name) then
      return v
    end
  end
end

--- Returns the instances of an item in an inventory, indexed by item ID.
-- @param inventory [Inventory The inventory table]
-- @param uniqueID [String Unique ID, index or name of the item, as accepted by `item.FindByID`]
-- @return [Map<Item> The instances indexed by item ID; `nil` when the inventory has none, an empty table when the
-- item does not exist]
function cw.inventory:GetItemsByID(inventory, uniqueID)
  local itemTable = item.FindByID(uniqueID)

  if itemTable then
    return inventory[itemTable.uniqueID]
  else
    return {}
  end
end

--- Finds every instance of an item in an inventory whose name matches, case insensitive.
--
-- Both the instance's `name` and `PrintName` are compared.
-- @param inventory [Inventory The inventory table]
-- @param uniqueID [String Unique ID, index or name of the item, as accepted by `item.FindByID`]
-- @param name [String The name to match]
-- @return [List<Item> The matching instances, or `nil` when the inventory has none of the item]
function cw.inventory:FindItemsByName(inventory, uniqueID, name)
  local itemTable = item.FindByID(uniqueID)
  local itemsList = {}

  if !itemTable or !inventory[itemTable.uniqueID] then
    return
  end

  for k, v in pairs(inventory[itemTable.uniqueID]) do
    if string.utf8lower(v.name) == string.utf8lower(name)
    or string.utf8lower(v.PrintName) == string.utf8lower(name) then
      itemsList[#itemsList + 1] = v
    end
  end

  return itemsList
end

--- Returns every item instance in an inventory as a flat list.
-- @param inventory [Inventory The inventory table]
-- @return [List<Item> The instances]
function cw.inventory:GetAsItemsList(inventory)
  local itemsList = {}

    for k, v in pairs(inventory) do
      table.Add(itemsList, v)
    end

  return itemsList
end

--- Returns how many instances of an item an inventory has.
-- @param inventory [Inventory The inventory table]
-- @param uniqueID [String Unique ID, index or name of the item, as accepted by `item.FindByID`]
-- @return [Number The number of instances; `0` when the item does not exist]
function cw.inventory:GetItemCountByID(inventory, uniqueID)
  local itemTable = item.FindByID(uniqueID)

  if itemTable and inventory[itemTable.uniqueID] then
    return table.Count(inventory[itemTable.uniqueID])
  else
    return 0
  end
end

--- Returns whether an inventory has at least one instance of an item.
--
-- The `uniqueID` is looked up in the inventory as given, so it should be the item's exact unique ID.
-- @param inventory [Inventory The inventory table]
-- @param uniqueID [String Unique ID of the item]
-- @return [Boolean Whether the inventory has the item; `nil` when it never had any]
function cw.inventory:HasItemByID(inventory, uniqueID)
  local itemsList = inventory[uniqueID]

  return (itemsList and next(itemsList) != nil)
end

--- Returns whether an inventory has at least an amount of instances of an item.
-- @param inventory [Inventory The inventory table]
-- @param uniqueID [String Unique ID, index or name of the item, as accepted by `item.FindByID`]
-- @param amount [Number The amount needed]
-- @return [Boolean Whether the inventory has at least `amount` of the item]
function cw.inventory:HasItemCountByID(inventory, uniqueID, amount)
  local amountInInventory = self:GetItemCountByID(inventory, uniqueID)

  if amountInInventory >= amount then
    return true
  else
    return false
  end
end

--- Returns whether an inventory contains a specific item instance.
-- @param inventory [Inventory The inventory table]
-- @param itemTable [Item The item instance]
-- @return [Boolean Whether the instance is in the inventory]
function cw.inventory:HasItemInstance(inventory, itemTable)
  local uniqueID = itemTable.uniqueID
  return (inventory[uniqueID] and inventory[uniqueID][itemTable.itemID] != nil)
end

--- Returns whether an inventory has no items.
-- @param inventory [Inventory The inventory table; `nil` counts as empty]
-- @return [Boolean Whether the inventory is empty]
function cw.inventory:IsEmpty(inventory)
  if !inventory then return true end

  for k, v in pairs(inventory) do
    if next(v) != nil then
      return false
    end
  end

  return true
end

--- Removes an item instance from an inventory table.
--
-- Only changes the table; use `Player:TakeItem` to take an item from a player.
-- @param inventory [Inventory The inventory table]
-- @param itemTable [Item The item instance]
-- @return [Item The removed instance; `false` when `itemTable` is not an instance, `nil` when the inventory has none
-- of the item]
function cw.inventory:RemoveInstance(inventory, itemTable)
  if !itemTable:IsInstance() then
    debug.Trace()
    return false
  end

  if inventory[itemTable.uniqueID] then
    inventory[itemTable.uniqueID][itemTable.itemID] = nil
    return item.FindInstance(itemTable.itemID)
  end
end

--- Removes an instance of an item from an inventory table.
-- @param inventory [Inventory The inventory table]
-- @param uniqueID [String Unique ID, index or name of the item, as accepted by `item.FindByID`]
-- @param itemID=nil [Number Item ID of the instance to remove; the first instance when `nil`]
-- @return [Item The removed instance when no `itemID` was given; nothing otherwise]
function cw.inventory:RemoveUniqueID(inventory, uniqueID, itemID)
  local itemTable = item.FindByID(uniqueID)
  if itemID then itemID = tonumber(itemID) end

  if itemTable and inventory[itemTable.uniqueID] then
    if !itemID then
      local firstValue = table.GetFirstValue(inventory[itemTable.uniqueID])

      if firstValue then
        inventory[itemTable.uniqueID][firstValue.itemID] = nil
        return item.FindInstance(firstValue.itemID)
      end
    else
      inventory[itemTable.uniqueID][itemID] = nil
    end
  end
end

--- Converts a saved inventory back into an inventory of item instances.
--
-- Creates an instance for every saved entry and keeps it unless its `OnLoaded` returns `false`.
-- Entries saved under a key that is not the item's current unique ID are dropped. An entry whose item ID is
-- already taken by an instance of another item is loaded under a new item ID.
-- @param inventory [Map Saved data of each item ID, indexed by unique ID, as made by `cw.inventory:ToSaveable`]
-- @return [Inventory The inventory of instances]
function cw.inventory:ToLoadable(inventory)
  local newTable = {}

  for k, v in pairs(inventory) do
    local itemTable = item.FindByID(k)

    if itemTable then
      local uniqueID = itemTable.uniqueID

      if uniqueID != k then
        continue
      end

      if !newTable[uniqueID] then
        newTable[uniqueID] = {}
      end

      for k2, v2 in pairs(v) do
        local instance = item.CreateInstance(
          k, tonumber(k2), v2
        )

        if instance and (!instance.OnLoaded or instance:OnLoaded() != false) then
          newTable[uniqueID][instance.itemID] = instance
        end
      end
    end
  end

  return newTable
end

--- Converts an inventory into a table that can be saved.
--
-- For each instance only the data fields that differ from the item's defaults are kept, indexed by
-- the item ID as a string. An instance is skipped when its `OnSaved(newData)` returns `false`.
-- @param inventory [Inventory The inventory table]
-- @return [Map The saved data of each item ID, indexed by unique ID]
-- @see cw.inventory:ToLoadable
function cw.inventory:ToSaveable(inventory)
  local newTable = {}

  for k, v in pairs(inventory) do
    local itemTable = item.FindByID(k)

    if itemTable then
      local defaultData = itemTable.defaultData
      local uniqueID = itemTable.uniqueID

      if !newTable[uniqueID] then
        newTable[uniqueID] = {}
      end

      for k2, v2 in pairs(v) do
        if type(v2) == 'table'
        and (v2.IsInstance and v2:IsInstance()) then
          local newData = {}
          local itemID = tostring(k2)

          for k3, v3 in pairs(v2.data) do
            if defaultData[k3] != v3 then
              newData[k3] = v3
            end
          end

          if !v2.OnSaved
          or v2:OnSaved(newData) != false then
            newTable[uniqueID][itemID] = newData
          end
        end
      end
    end
  end

  return newTable
end

--- Returns whether inventory space is limited as well as weight.
-- @return [Boolean The value of the `enable_space_system` config]
function cw.inventory:UseSpaceSystem()
  return config.Get('enable_space_system'):Get()
end

if CLIENT then
  cw.inventory.client = cw.inventory.client or {}

  --- Returns the local player's inventory.
  -- @return [Inventory The local player's inventory]
  function cw.inventory:GetClient()
    return self.client
  end

  --- Returns the inventory menu panel.
  -- @return [Panel The inventory panel, or `nil` when it has not been created]
  function cw.inventory:GetPanel()
    return self.panel
  end

  --- Returns whether the local player has an item equipped.
  -- @param itemTable [Item The item instance]
  -- @return [Boolean Whether the item's `HasPlayerEquipped` returns `true` for the local player]
  function cw.inventory:HasEquipped(itemTable)
    if itemTable.HasPlayerEquipped then
      return (itemTable:HasPlayerEquipped(cw.client) == true)
    end

    return false
  end

  --- Rebuilds the inventory panel on the next frame.
  --
  -- Does nothing unless the inventory panel is the active menu panel or `bForceRebuild` is set.
  -- @param bForceRebuild=nil [Boolean Rebuild even when the panel is not active]
  function cw.inventory:Rebuild(bForceRebuild)
    if cw.menu:IsPanelActive(self:GetPanel()) or bForceRebuild then
      cw.core:OnNextFrame('RebuildInv', function()
        if IsValid(self:GetPanel()) then
          self:GetPanel():Rebuild()
        end
      end)
    end
  end

  netstream.Hook('InvClear', function(data)
    cw.inventory.client = {}
    cw.inventory:Rebuild()
  end)

  netstream.Hook('InvGive', function(data)
    local itemTable = item.CreateInstance(
      data.index, data.itemID, data.data
    )

    if !itemTable then return end

    cw.inventory:AddInstance(
      cw.inventory.client, itemTable
    )

    cw.inventory:Rebuild()
    hook.Run('PlayerItemGiven', itemTable)
  end)

  netstream.Hook('InvNetwork', function(data)
    local itemTable = item.FindInstance(data.itemID)

    if itemTable then
      local bHasEquipped = cw.inventory:HasEquipped(itemTable)

      table.Merge(itemTable.data, data.data)
      hook.Run('ItemNetworkDataUpdated', itemTable, data.data)

      if bHasEquipped != cw.inventory:HasEquipped(itemTable) then
        cw.inventory:Rebuild(
          cw.menu:GetOpen()
        )
      end
    end
  end)

  netstream.Hook('InvRebuild', function(data)
    cw.inventory:Rebuild()
  end)

  netstream.Hook('InvTake', function(data)
    local itemTable = cw.inventory:FindItemByID(
      cw.inventory.client, data[1], data[2]
    )

    if itemTable then
      cw.inventory:RemoveInstance(
        cw.inventory.client, itemTable
      )

      cw.inventory:Rebuild()
      hook.Run('PlayerItemTaken', itemTable)
    end
  end)

  netstream.Hook('InvUpdate', function(data)
    for k, v in pairs(data) do
      local itemTable = item.CreateInstance(
        v.index, v.itemID, v.data
      )

      cw.inventory:AddInstance(
        cw.inventory.client, itemTable
      )
    end

    cw.inventory:Rebuild()
  end)
else
  --- Sends an item instance in a player's inventory to that player over the `InvUpdate` netstream message.
  -- @param player [Player The player to send to]
  -- @param itemTable [Item The item instance; nothing is sent when `nil`]
  function cw.inventory:SendUpdateByInstance(player, itemTable)
    if itemTable then
      netstream.Start(
        player, 'InvUpdate', { item.GetDefinition(itemTable, true) }
      )
    end
  end

  --- Sends every item in a player's inventory to that player.
  -- @param player [Player The player to send to]
  -- @see cw.inventory:SendUpdateByID
  function cw.inventory:SendUpdateAll(player)
    local inventory = player:GetInventory()

    for k, v in pairs(inventory) do
      self:SendUpdateByID(player, k)
    end
  end

  --- Sends every instance of an item in a player's inventory to that player over the `InvUpdate`
  -- netstream message.
  -- @param player [Player The player to send to]
  -- @param uniqueID [String Unique ID, index or name of the item, as accepted by `item.FindByID`]
  function cw.inventory:SendUpdateByID(player, uniqueID)
    local itemTables = self:GetItemsByID(player:GetInventory(), uniqueID)

    if itemTables then
      local definitions = {}

      for k, v in pairs(itemTables) do
        definitions[#definitions + 1] = item.GetDefinition(v, true)
      end

      netstream.Start(player, 'InvUpdate', definitions)
    end
  end

  --- Tells a player's client to rebuild its inventory panel on the next frame.
  --
  -- Repeated calls in the same frame send a single `InvRebuild` message.
  -- @param player [Player The player]
  function cw.inventory:Rebuild(player)
    cw.core:OnNextFrame('RebuildInv'..player:UniqueID(), function()
      if IsValid(player) then
        netstream.Start(player, 'InvRebuild')
      end
    end)
  end
end
