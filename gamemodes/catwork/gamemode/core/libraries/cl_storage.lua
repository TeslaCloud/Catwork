--- Client-side part of the `cw.storage` library: accessors for the storage the local player has open.
--
-- They return its name, entity, inventory, cash and weight and space limits, and `cw.storage:CanGiveTo` and
-- `cw.storage:CanTakeFrom` check whether an item's storage permissions allow moving it.

library.New('storage', cw)

--- Returns whether the storage window is open and visible.
-- @return [Boolean `true` if it is open, `nil` otherwise]
function cw.storage:IsStorageOpen()
  local panel = self:GetPanel()

  if IsValid(panel) and panel:IsVisible() then
    return true
  end
end

--- Returns whether the local player may put an item into the open storage.
--
-- Checks the item's `allowStorage`, `allowGive` and the player or entity variants
-- (`allowPlayerStorage`, `allowPlayerGive`, `allowEntityStorage`, `allowEntityGive`)
-- depending on whether the storage belongs to a player. Shipments accept every item.
-- @param itemTable [Item The item to give]
-- @return [Boolean `true` if the item may be given, `nil` otherwise]
-- @see cw.storage:CanTakeFrom
function cw.storage:CanGiveTo(itemTable)
  local entity = cw.storage:GetEntity()
  local isPlayer = (entity and entity:IsPlayer())

  if itemTable then
    local bAllowPlayerStorage = (!isPlayer or itemTable.allowPlayerStorage != false)
    local bAllowEntityStorage = (isPlayer or itemTable.allowEntityStorage != false)
    local bAllowPlayerGive = (!isPlayer or itemTable.allowPlayerGive != false)
    local bAllowEntityGive = (isPlayer or itemTable.allowEntityGive != false)
    local bAllowStorage = (itemTable.allowStorage != false)
    local bIsShipment = (entity and entity:GetClass() == 'cw_shipment')
    local bAllowGive = (itemTable.allowGive != false)

    if bIsShipment or (bAllowPlayerStorage and bAllowPlayerGive
    and bAllowEntityStorage and bAllowStorage and bAllowGive
    and bAllowEntityGive) then
      return true
    end
  end
end

--- Returns whether the local player may take an item out of the open storage.
--
-- Checks the item's `allowStorage`, `allowTake` and the player or entity variants
-- (`allowPlayerStorage`, `allowPlayerTake`, `allowEntityStorage`, `allowEntityTake`)
-- depending on whether the storage belongs to a player. Every item can be taken from shipments.
-- @param itemTable [Item The item to take]
-- @return [Boolean `true` if the item may be taken, `nil` otherwise]
-- @see cw.storage:CanGiveTo
function cw.storage:CanTakeFrom(itemTable)
  local entity = cw.storage:GetEntity()
  local isPlayer = (entity and entity:IsPlayer())

  if itemTable then
    local bAllowPlayerStorage = (!isPlayer or itemTable.allowPlayerStorage != false)
    local bAllowEntityStorage = (isPlayer or itemTable.allowEntityStorage != false)
    local bAllowPlayerTake = (!isPlayer or itemTable.allowPlayerTake != false)
    local bAllowEntityTake = (isPlayer or itemTable.allowEntityTake != false)
    local bAllowStorage = (itemTable.allowStorage != false)
    local bIsShipment = (entity and entity:GetClass() == 'cw_shipment')
    local bAllowTake = (itemTable.allowTake != false)

    if bIsShipment or (bAllowPlayerStorage and bAllowPlayerTake
    and bAllowEntityStorage and bAllowStorage and bAllowTake
    and bAllowEntityTake) then
      return true
    end
  end
end

--- Returns whether cash adds no weight to the open storage.
-- @return [Boolean The `noCashWeight` option the storage was opened with]
function cw.storage:GetNoCashWeight()
  return self.noCashWeight
end

--- Returns whether cash takes no space in the open storage.
-- @return [Boolean The `noCashSpace` option the storage was opened with]
function cw.storage:GetNoCashSpace()
  return self.noCashSpace
end

--- Returns whether the open storage hides the local player's inventory side.
-- @return [Boolean The `isOneSided` option the storage was opened with]
function cw.storage:GetIsOneSided()
  return self.isOneSided
end

--- Returns the inventory of the open storage.
-- @return [Inventory The storage inventory, or `nil` if no storage is open]
function cw.storage:GetInventory()
  return self.inventory
end

--- Returns the cash in the open storage.
-- @return [Number The cash, or `0` when the `cash_enabled` config is off]
function cw.storage:GetCash()
  if config.GetVal('cash_enabled') then
    return self.cash
  else
    return 0
  end
end

--- Returns the storage window.
-- @return [Panel The panel, or `nil` if it has not been created]
function cw.storage:GetPanel()
  return self.panel
end

--- Returns the maximum weight of the open storage.
-- @return [Number Weight limit, or `nil` if no storage is open]
function cw.storage:GetWeight()
  return self.weight
end

--- Returns the maximum space of the open storage.
-- @return [Number Space limit, or `nil` if no storage is open]
function cw.storage:GetSpace()
  return self.space
end

--- Returns the entity the open storage belongs to.
-- @return [Entity The storage entity, which may be a player, or `nil` if no storage is open]
function cw.storage:GetEntity()
  return self.entity
end

--- Returns the name of the open storage.
-- @return [String The name shown in the storage window]
function cw.storage:GetName()
  return self.name
end
