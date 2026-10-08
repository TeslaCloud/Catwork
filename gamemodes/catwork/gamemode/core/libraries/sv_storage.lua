--- Server-side part of the `cw.storage` library, which opens an inventory and cash as a storage menu for a player and
-- moves items in and out of it.
--
-- `cw.storage:Open` takes a storage table with the name, inventory, cash, weight and space limits, entity and
-- callbacks. `cw.storage:GiveTo` and `cw.storage:TakeFrom` do the transfers after checking permissions and capacity,
-- and changes are synced to everyone viewing the same inventory.

library.New('storage', cw)

--- Returns the entity whose storage the player has open.
-- @param player [Player The player]
-- @return [Entity The storage entity, or `nil` if no storage is open or the entity is no longer valid]
function cw.storage:GetEntity(player)
  if player:GetStorageTable() then
    local entity = self:Query(player, 'entity')

    if entity and IsValid(entity) then
      return entity
    end
  end
end

--- Returns the storage table of the storage the player has open.
-- @param player [Player The player]
-- @return [Map The storage table passed to `cw.storage:Open`, or `nil` if no storage is open]
function cw.storage:GetTable(player)
  return player.cwStorageTab
end

--- Returns whether the player's open storage contains an item instance.
-- @param player [Player The player]
-- @param itemTable [Item The item instance to look for]
-- @return [Boolean Whether the storage contains the item]
function cw.storage:HasItem(player, itemTable)
  local inventory = self:Query(player, 'inventory')

  if inventory then
    return cw.inventory:HasItemInstance(
      inventory, itemTable
    )
  end

  return false
end

--- Returns a value from the storage table of the player's open storage.
-- @param player [Player The player]
-- @param key [String Key in the storage table, such as `'inventory'`, `'entity'` or `'cash'`]
-- @param default=nil [Any Value to return if no storage is open or the value is `nil` or `false`]
-- @return [Any The value, or `default`]
function cw.storage:Query(player, key, default)
  local storageTable = player:GetStorageTable()

  if storageTable then
    return storageTable[key] or default
  else
    return default
  end
end

--- Closes the player's open storage.
--
-- Calls the storage's `OnClose(player, storageTable, entity)` callback first.
-- @param player [Player The player]
-- @param bServer=false [Boolean Only close it on the server, without telling the client to close the menu]
-- @see cw.storage:Open
function cw.storage:Close(player, bServer)
  local storageTable = player:GetStorageTable()
  local OnClose = self:Query(player, 'OnClose')
  local entity = self:Query(player, 'entity')

  if storageTable and OnClose then
    OnClose(player, storageTable, entity)
  end

  if !bServer then
    netstream.Start(player, 'StorageClose', true)
  end

  player.cwStorageTab = nil
end

--- Returns the total weight of the cash and items in the player's open storage.
--
-- Items count their `storageWeight` if they have one, otherwise their
-- `weight`. Cash counts unless the storage was opened with `noCashWeight`.
-- @param player [Player The player]
-- @return [Number The weight, or `0` if no storage is open]
function cw.storage:GetWeight(player)
  if player:GetStorageTable() then
    local cash = self:Query(player, 'cash')
    local weight = (cash * config.Get('cash_weight'):Get())
    local inventory = self:Query(player, 'inventory')

    if self:Query(player, 'noCashWeight') then
      weight = 0
    end

    for k, v in pairs(cw.inventory:GetAsItemsList(inventory)) do
      weight = weight + (math.max((v.storageWeight or v.weight), 0))
    end

    return weight
  else
    return 0
  end
end

--- Returns the total space taken by the cash and items in the player's open storage.
--
-- Items count their `storageSpace` if they have one, otherwise their `space`.
-- Cash counts unless the storage was opened with `noCashSpace`.
-- @param player [Player The player]
-- @return [Number The space, or `0` if no storage is open]
function cw.storage:GetSpace(player)
  if player:GetStorageTable() then
    local cash = self:Query(player, 'cash')
    local space = (cash * config.Get('cash_space'):Get())
    local inventory = self:Query(player, 'inventory')

    if self:Query(player, 'noCashSpace') then
      space = 0
    end

    for k, v in pairs(cw.inventory:GetAsItemsList(inventory)) do
      space = space + (math.max((v.storageSpace or v.space), 0))
    end

    return space
  else
    return 0
  end
end

--- Opens a storage menu for the player.
--
-- Any storage the player already has open is closed through its `OnClose`
-- callback first. Missing fields of `data` get defaults, then the table
-- becomes the player's storage table and its contents are sent to the client.
--
-- `data` may contain: `name` (defaults to `'#Storage_Default'`), `inventory`
-- (the storage's inventory, defaults to an empty one), `entity` (defaults to
-- the player), `weight` and `space` (default to the `default_inv_weight` and
-- `default_inv_space` configs), `cash` (removed when cash is disabled),
-- `isOneSided`, `noCashWeight`, `noCashSpace`, and the callbacks
-- `OnClose(player, storageTable, entity)`, `CanGiveItem` and `CanTakeItem`
-- (`(player, storageTable, itemTable)`, return `false` to block) and
-- `OnGiveItem` and `OnTakeItem` (same arguments, return `true` to close the
-- storage). Other keys, such as `distance`, `OnGiveCash` and `OnTakeCash`, are
-- kept in the table for other code to read.
--
-- ```
-- cw.storage:Open(player, {
--   name = 'Locker',
--   weight = 20,
--   space = 50,
--   entity = entity,
--   inventory = entity.cwInventory,
--   cash = entity.cwCash,
--   OnClose = function(player, storageTable, entity)
--     if IsValid(entity) then
--       entity.cwCash = storageTable.cash
--     end
--   end
-- })
-- ```
--
-- @param player [Player The player to open the storage for]
-- @param data [Map The storage table; it is modified and kept]
-- @see cw.storage:Close
function cw.storage:Open(player, data)
  local storageTable = player:GetStorageTable()
  local OnClose = self:Query(player, 'OnClose')

  if storageTable and OnClose then
    OnClose(player, storageTable, storageTable.entity)
  end

  if !config.Get('cash_enabled'):Get() then
    data.cash = nil
  end

  if data.noCashWeight == nil then
    data.noCashWeight = false
  end

  if data.noCashSpace == nil then
    data.noCashSpace = false
  end

  if data.isOneSided == nil then
    data.isOneSided = false
  end

  data.inventory = data.inventory or {}
  data.entity = data.entity == nil and player or data.entity
  data.weight = data.weight or config.Get('default_inv_weight'):Get()
  data.space = data.space or config.Get('default_inv_space'):Get()
  data.cash = data.cash or 0
  data.name = data.name or '#Storage_Default'

  player.cwStorageTab = data

  netstream.Start(player, 'StorageStart', {
    noCashWeight =
      data.noCashWeight, noCashSpace = data.noCashSpace, isOneSided = data.isOneSided, entity = data.entity,
    name = data.name
  })

  self:UpdateCash(player, data.cash)
  self:UpdateWeight(player, data.weight)
  self:UpdateSpace(player, data.space)

  for k, v in pairs(data.inventory) do
    self:UpdateByID(player, k)
  end
end

--- Sets the cash of the player's open storage for everyone viewing the same inventory.
--
-- Does nothing when cash is disabled.
-- @param player [Player A player who has the storage open]
-- @param cash [Number The new amount of cash]
function cw.storage:UpdateCash(player, cash)
  if config.Get('cash_enabled'):Get() then
    local storageTable = player:GetStorageTable()

    if storageTable then
      local inventory = self:Query(player, 'inventory')

      for k, v in ipairs(_player.GetAll()) do
        if v:HasInitialized() and v:GetStorageTable() then
          if self:Query(v, 'inventory') == inventory then
            v.cwStorageTab.cash = cash

            netstream.Start(v, 'StorageCash', cash)
          end
        end
      end
    end
  end
end

--- Sets the maximum weight of the player's open storage for everyone viewing the same inventory.
-- @param player [Player A player who has the storage open]
-- @param weight [Number The new maximum weight]
function cw.storage:UpdateWeight(player, weight)
  if player:GetStorageTable() then
    local inventory = self:Query(player, 'inventory')

    for k, v in ipairs(_player.GetAll()) do
      if v:HasInitialized() and v:GetStorageTable() then
        if self:Query(v, 'inventory') == inventory then
          v.cwStorageTab.weight = weight

          netstream.Start(v, 'StorageWeight', weight)
        end
      end
    end
  end
end

--- Sets the maximum space of the player's open storage for everyone viewing the same inventory.
-- @param player [Player A player who has the storage open]
-- @param space [Number The new maximum space]
function cw.storage:UpdateSpace(player, space)
  if player:GetStorageTable() then
    local inventory = self:Query(player, 'inventory')

    for k, v in ipairs(_player.GetAll()) do
      if v:HasInitialized() and v:GetStorageTable() then
        if self:Query(v, 'inventory') == inventory then
          v.cwStorageTab.space = space

          netstream.Start(v, 'StorageSpace', space)
        end
      end
    end
  end
end

--- Returns whether an item may be put into the player's open storage.
--
-- Checks the item's `allowStorage`, `allowGive`, `allowPlayerStorage`,
-- `allowPlayerGive`, `allowEntityStorage` and `allowEntityGive` fields
-- against whether the storage belongs to a player. Shipments accept every
-- item.
-- @param player [Player The player who has the storage open]
-- @param itemTable [Item The item instance]
-- @return [Boolean `true` if the item is allowed, otherwise `nil`]
-- @see cw.storage:GiveTo
function cw.storage:CanGiveTo(player, itemTable)
  local entity = self:Query(player, 'entity')
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

--- Returns whether an item may be taken out of the player's open storage.
--
-- Checks the item's `allowStorage`, `allowTake`, `allowPlayerStorage`,
-- `allowPlayerTake`, `allowEntityStorage` and `allowEntityTake` fields
-- against whether the storage belongs to a player. Items in shipments can
-- always be taken.
-- @param player [Player The player who has the storage open]
-- @param itemTable [Item The item instance]
-- @return [Boolean `true` if the item is allowed, otherwise `nil`]
-- @see cw.storage:TakeFrom
function cw.storage:CanTakeFrom(player, itemTable)
  local entity = self:Query(player, 'entity')
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

--- Sends the player's cash to everyone who has the player's inventory open as storage.
--
-- Only sets their storage cash when cash is enabled.
-- @param player [Player The player whose cash changed]
function cw.storage:SyncCash(player)
  local recipients = {}
  local inventory = player:GetInventory()
  local cash = player:GetCash()

  if config.Get('cash_enabled'):Get() then
    for k, v in ipairs(_player.GetAll()) do
      if v:HasInitialized() and self:Query(v, 'inventory') == inventory then
        local storageTable = v:GetStorageTable()
          recipients[#recipients + 1] = v
        storageTable.cash = cash
      end
    end
  end

  netstream.Start(recipients, 'StorageCash', cash)
end

--- Sends an item change in the player's inventory to everyone who has it open as storage.
--
-- The item is added to their storage menus if the player still has it, and
-- removed otherwise.
-- @param player [Player The player whose inventory changed]
-- @param itemTable [Item The item instance that was given or taken]
function cw.storage:SyncItem(player, itemTable)
  local inventory = player:GetInventory()

  if itemTable then
    local definition = item.GetDefinition(itemTable, true)
      definition.index = nil
    local players = {}

    for k, v in ipairs(_player.GetAll()) do
      if v:HasInitialized() and self:Query(v, 'inventory') == inventory then
        players[#players + 1] = v
      end
    end

    if player:HasItemInstance(itemTable) then
      netstream.Start(players, 'StorageGive', { index = itemTable.index, itemList = { definition } })
    else
      netstream.Start(players, 'StorageTake', item.GetSignature(itemTable))
    end
  end
end

--- Moves an item from the player's inventory into their open storage.
--
-- Fails if the storage does not allow the item (`cw.storage:CanGiveTo`), the
-- player does not have it, the `PlayerCanGiveToStorage` hook does not return
-- `true`, a non-player storage would exceed its weight or space, or the
-- item's `CanGiveStorage` or the storage's `CanGiveItem` returns `false`.
-- Fires `PlayerGiveToStorage` before and `PostPlayerGiveToStorage` after the
-- move, and updates everyone viewing the same inventory. The storage closes if
-- `OnGiveItem` or the item's `OnStorageGive` returns `true`.
-- @param player [Player The player who has the storage open]
-- @param itemTable [Item The item instance to give]
-- @return [Boolean Whether the item was moved]
-- @see cw.storage:TakeFrom
function cw.storage:GiveTo(player, itemTable)
  local storageTable = player:GetStorageTable()
  if !storageTable then return false end

  local inventory = self:Query(player, 'inventory')

  if !self:CanGiveTo(player, itemTable) then
    return false
  end

  if !player:HasItemInstance(itemTable)
  or !hook.Run('PlayerCanGiveToStorage', player, storageTable, itemTable) then
    return false
  end

  if !storageTable.entity or !storageTable.entity:IsPlayer() then
    local weight = itemTable.storageWeight or itemTable.weight
    local space = itemTable.storageSpace or itemTable.space

    if (self:GetWeight(player) + math.max(weight, 0) > storageTable.weight)
    or (self:GetSpace(player) + math.max(space, 0) > storageTable.space) then
      return false
    end
  end

  local bCanGiveStorage = !itemTable.CanGiveStorage or itemTable:CanGiveStorage(player, storageTable)
  if bCanGiveStorage == false then return false end

  bCanGiveStorage = !storageTable.CanGiveItem or storageTable.CanGiveItem(player, storageTable, itemTable)
  if bCanGiveStorage == false then return false end

  if storageTable.entity and storageTable.entity:IsPlayer() and !storageTable.entity:GiveItem(itemTable) then
    return false
  end

  hook.Run('PlayerGiveToStorage', player, storageTable, itemTable)
  cw.inventory:AddInstance(inventory, itemTable)

  local definition = item.GetDefinition(itemTable, true)
    definition.index = nil
  local players = {}

  for k, v in ipairs(_player.GetAll()) do
    if v:HasInitialized() and self:Query(v, 'inventory') == inventory then
      players[#players + 1] = v
    end
  end

  netstream.Start(
    players, 'StorageGive', { index = itemTable.index, itemList = { definition } }
  )

  player:TakeItem(itemTable)

  if storageTable.OnGiveItem and storageTable.OnGiveItem(player, storageTable, itemTable) then
    self:Close(player)
  end

  if itemTable.OnStorageGive and itemTable:OnStorageGive(player, storageTable) then
    self:Close(player)
  end

  if storageTable.entity and storageTable.entity:IsPlayer() then
    self:UpdateWeight(player, storageTable.entity:GetMaxWeight())
    self:UpdateSpace(player, storageTable.entity:GetMaxSpace())
  end

  hook.Run('PostPlayerGiveToStorage', player, storageTable, itemTable)

  return true
end

--- Moves an item from the player's open storage into their inventory.
--
-- Fails if the storage does not allow it (`cw.storage:CanTakeFrom`), the
-- `PlayerCanTakeFromStorage` hook does not return `true`, the storage does not
-- contain the item, or the item's `CanTakeStorage` or the storage's
-- `CanTakeItem` returns `false`. If the player cannot carry the item, they are
-- notified of the reason. Fires `PlayerTakeFromStorage` and
-- `PostPlayerTakeFromStorage`, and updates everyone viewing the same
-- inventory. The storage closes if `OnTakeItem` or the item's `OnStorageTake`
-- returns `true`.
-- @param player [Player The player who has the storage open]
-- @param itemTable [Item The item instance to take]
-- @return [Boolean `true` if the item was moved, `false` if a check failed, `nil` if the player could not carry
-- it]
-- @see cw.storage:GiveTo
function cw.storage:TakeFrom(player, itemTable)
  local storageTable = player:GetStorageTable()
  if !storageTable then return false end

  local inventory = self:Query(player, 'inventory')
  local players = {}

  if !self:CanTakeFrom(player, itemTable)
  or !hook.Run('PlayerCanTakeFromStorage', player, storageTable, itemTable) then
    return false
  end

  if !cw.inventory:HasItemInstance(inventory, itemTable) then
    return false
  end

  local bCanTakeStorage = !itemTable.CanTakeStorage or itemTable:CanTakeStorage(player, storageTable)
  if bCanTakeStorage == false then return false end

  bCanTakeStorage = !storageTable.CanTakeItem or storageTable.CanTakeItem(player, storageTable, itemTable)
  if bCanTakeStorage == false then return false end

  local bSuccess, fault = player:GiveItem(itemTable)

  if bSuccess then
    hook.Run('PlayerTakeFromStorage', player, storageTable, itemTable)

    if !storageTable.entity or !storageTable.entity:IsPlayer() then
      cw.inventory:RemoveInstance(inventory, itemTable)
    else
      storageTable.entity:TakeItem(itemTable)
    end

    for k, v in ipairs(_player.GetAll()) do
      if v:HasInitialized() and self:Query(v, 'inventory') == inventory then
        players[#players + 1] = v
      end
    end

    netstream.Start(
      players, 'StorageTake', item.GetSignature(itemTable)
    )

    if storageTable.OnTakeItem and storageTable.OnTakeItem(player, storageTable, itemTable) then
      self:Close(player)
    end

    if itemTable.OnStorageTake and itemTable:OnStorageTake(player, itemTable) then
      self:Close(player)
    end

    if storageTable.entity and storageTable.entity:IsPlayer() then
      self:UpdateWeight(player, storageTable.entity:GetMaxWeight())
      self:UpdateSpace(player, storageTable.entity:GetMaxSpace())
    end

    hook.Run('PostPlayerTakeFromStorage', player, storageTable, itemTable)

    return true
  else
    cw.player:Notify(player, fault)
  end
end

--- Sends every instance of an item type in the player's open storage to their client.
--
-- Does nothing if no storage is open or the storage has no items of that type.
-- @param player [Player The player who has the storage open]
-- @param uniqueID [String Unique ID of the item type]
function cw.storage:UpdateByID(player, uniqueID)
  if !player:GetStorageTable() then return end

  local inventory = self:Query(player, 'inventory')
  local itemTable = item.FindByID(uniqueID, true)

  if itemTable and inventory[uniqueID] then
    local itemList = {}

    for k, v in pairs(inventory[uniqueID]) do
      local definition = item.GetDefinition(v, true)

      itemList[#itemList + 1] = {
        itemID = definition.itemID,
        data = definition.data
      }
    end

    netstream.Start(player, 'StorageGive', { index = itemTable.index, itemList = itemList })
  end
end
