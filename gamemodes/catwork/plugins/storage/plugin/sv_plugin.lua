--- Server-side functions of the Storage plugin that open containers and pick the random items they are filled with.
--
-- `cwStorage:OpenContainer` gives the entity an inventory and cash on first use and opens it with `cw.storage:Open`,
-- and the `ContainerPassword` netstream opens a container when the entered password matches. `GetRandomItem` and
-- `CategoryExists` read `cwStorage.randomItems`. `SaveStorage` and `LoadStorage` are empty stubs, as persistence is
-- left to the Static Entities plugin.

cwStorage.storage = cwStorage.storage or {}

netstream.Hook('ContainerPassword', function(player, data)
  local password = data[1]
  local entity = data[2]

  if IsValid(entity) and cw.entity:IsPhysicsEntity(entity) then
    local model = string.lower(entity:GetModel())

    if cwStorage.containerList[model] then
      local containerWeight = cwStorage.containerList[model][1]

      if entity.cwPassword == password then
        cwStorage:OpenContainer(player, entity, containerWeight)
      else
        cw.player:Notify(player, L('Container_WrongPassword'))
      end
    end
  end
end)

--- Picks a random entry from `cwStorage.randomItems`, optionally limited to one item category.
--
-- Entries are `{ uniqueID, weight }` lists. The function keeps drawing until an entry matches, so check
-- the category with `cwStorage:CategoryExists` first.
-- @param uniqueID=nil [String Text the item's category must contain, ignoring case]
-- @return [List The `{ uniqueID, weight }` entry, or `nil` when the list is empty]
function cwStorage:GetRandomItem(uniqueID)
  if uniqueID then
    uniqueID = string.lower(uniqueID)
  end

  if #self.randomItems <= 0 then
    return
  end

  local randomItem = self.randomItems[
    math.random(1, #self.randomItems)
  ]

  if randomItem then
    local itemTable = item.FindByID(randomItem[1])

    if !uniqueID or string.find(string.lower(itemTable.category), uniqueID) then
      return randomItem
    end
  end

  return self:GetRandomItem(uniqueID, runs)
end

--- Returns whether any entry of `cwStorage.randomItems` has an item category containing the text.
-- @param uniqueID [String Text to look for in item categories, ignoring case]
-- @return [Boolean Whether a matching item exists; `false` when `uniqueID` is `nil`]
function cwStorage:CategoryExists(uniqueID)
  if uniqueID then
    local uniqueID = string.lower(uniqueID)

    for i = 1, #self.randomItems do
      local itemTable = item.FindByID(self.randomItems[i][1])

      if string.find(string.lower(itemTable.category), uniqueID) then
        return true
      end
    end

    return false
  else
    return false
  end
end

--- Does nothing; containers are saved by the Static Entities plugin.
-- @deprecation [Saving and loading are handled by the Static Entities plugin.]
function cwStorage:SaveStorage() end
--- Does nothing; containers are loaded by the Static Entities plugin.
-- @deprecation [Saving and loading are handled by the Static Entities plugin.]
function cwStorage:LoadStorage() end

--- Opens a container's storage for a player.
--
-- Creates the container's inventory and cash the first time, names the storage after the entity's
-- custom name or its type, sends the container's message to the player and opens it with
-- `cw.storage:Open` within a range of 192 units. Cash moved in or out is stored on the entity.
-- @param player [Player The player opening the container]
-- @param entity [Entity The container]
-- @param weight=8 [Number The container's weight capacity]
function cwStorage:OpenContainer(player, entity, weight)
  local inventory
  local cash = 0
  local model = string.lower(entity:GetModel())
  local name = ''

  if !entity.cwInventory then
    self.storage[entity] = entity

    entity.cwInventory = {}
  end

  if !entity.cwCash then
    entity.cwCash = 0
  end

  if self.containerList[model] then
    name = self.containerList[model][2]
  else
    name = '#Container_Name'
  end

  inventory = entity.cwInventory
  cash = entity.cwCash

  if !weight then
    weight = 8
  end

  if entity:GetNWString('Name') != '' then
    name = entity:GetNWString('Name')
  end

  if entity.cwMessage then
    netstream.Start(player, 'StorageMessage', {
      entity = entity, message = entity.cwMessage
    })
  end

  cw.storage:Open(player, {
    name = name,
    weight = weight,
    entity = entity,
    distance = 192,
    cash = cash,
    inventory = inventory,
    OnGiveCash = function(player, storageTable, cash)
      storageTable.entity.cwCash = storageTable.cash
    end,
    OnTakeCash = function(player, storageTable, cash)
      storageTable.entity.cwCash = storageTable.cash
    end
  })
end
