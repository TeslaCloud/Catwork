--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

ITEM.name = 'Container Base'
ITEM.model = 'models/props_junk/garbage_bag001a.mdl'
ITEM.weight = 2
ITEM.category = 'Storage'
ITEM.isRareItem = true
ITEM.description = '#Item_ContainerBase_Description'
ITEM.isContainer = true
ITEM.storageWeight = 5
ITEM.storageSpace = 10

ITEM:AddData('Inventory', nil)
ITEM:AddData('Cash', 0)

--- Converts the container's inventory into its saveable form before the item data is saved.
function ITEM:OnSaved(newData)
  if newData['Inventory'] != nil then
    newData['Inventory'] = cw.inventory:ToSaveable(newData['Inventory'])
  end
end

--- Converts the saved inventory back into item instances after the item is loaded.
function ITEM:OnLoaded()
  local inventory = (self.data and self.data.Inventory) or self.Inventory

  if inventory != nil then
    self:SetData('Inventory', cw.inventory:ToLoadable(inventory))
  end
end

if SERVER then
  --- Returns the container's inventory, creating an empty one in the item data if it has none.
  --
  -- On the call that creates the inventory the return value is still `nil`.
  -- @return [Inventory The items stored in the container]
  function ITEM:GetInventory()
    local inventory = self:GetData('Inventory')

    if inventory == nil then
      self:SetData('Inventory', {})
    end

    return inventory
  end

  --- Checks whether the container holds an item.
  --
  -- The result of the check is not returned, so the function always returns `nil`.
  -- @param itemTable [Item The item instance, or an item unique ID string to match any instance]
  function ITEM:HasItem(itemTable)
    if isstring(itemTable) then
      cw.inventory:HasItemByID(self:GetInventory(), itemTable)
    else
      cw.inventory:HasItemInstance(self:GetInventory(), itemTable)
    end
  end

  --- Removes an item from the container's inventory.
  -- @param itemTable [Item The item instance, or an item unique ID string to remove by ID]
  function ITEM:RemoveFromInventory(itemTable)
    if isstring(itemTable) then
      cw.inventory:RemoveUniqueID(self:GetInventory(), itemTable)
    else
      cw.inventory:RemoveInstance(self:GetInventory(), itemTable)
    end
  end

  --- Returns the container's contents as a flat list.
  -- @return [List<Item> Every item instance in the container]
  function ITEM:InventoryAsItemsList()
    return cw.inventory:GetAsItemsList(self:GetInventory())
  end

  --- Adds an item instance to the container's inventory.
  -- @param itemTable [Item The item instance to add]
  function ITEM:AddToInventory(itemTable)
    cw.inventory:AddInstance(self:GetInventory(), itemTable)
  end

  --- Returns the cash stored in the container.
  -- @return [Number The stored cash]
  function ITEM:GetCash()
    return (self.data and self.data.Cash) or self.Cash
  end
end

--- Opens the container for the player and keeps the item in their inventory.
-- @return [Boolean Always `false`]
function ITEM:OnUse(player, itemEntity)
  self:OpenFor(player, itemEntity)

  return false
end

--- Opens the container's inventory and cash as storage for a player.
--
-- Uses `storageWeight` and `storageSpace` as the limits and keeps the item's `Cash` data in step with cash put
-- in or taken out. Relies on the server-only `ITEM:GetInventory` and `ITEM:GetCash`, so call it on the server.
-- @param player [Player The player to open the storage for]
-- @param itemEntity=nil [Entity The container's item entity, if it is opened from the world]
function ITEM:OpenFor(player, itemEntity)
  local inventory = self:GetInventory()
  local cash = self:GetCash()
  local name = self.PrintName

  cw.storage:Open(player, {
    name = name,
    weight = self.storageWeight,
    space = self.storageSpace,
    entity = itemEntity or false,
    distance = 192,
    cash = cash,
    inventory = inventory,
    OnGiveCash = function(player, storageTable, cash)
      self:SetData('Cash', self:GetCash() + cash)
    end,
    OnTakeCash = function(player, storageTable, cash)
      self:SetData('Cash', self:GetCash() - cash)
    end
  })
end

--- Called when a player drops the container; does nothing, so dropping is allowed.
function ITEM:OnDrop(player, position) end
