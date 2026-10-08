--- Server-side functions of the Storage plugin that open containers and pick the random items they are filled with.
--
-- `cwStorage:OpenContainer` gives the entity an inventory and cash on first use and opens it with `cw.storage:Open`,
-- and the `ContainerPassword` Cable message opens a container when the entered password matches. `GetRandomItem`,
-- `CategoryExists` and `FillContainer` work on the list from `cwStorage:GetRandomItems`. `SaveStorage` and
-- `LoadStorage` are empty stubs, as persistence is left to the Static Entities plugin.

cwStorage.storage = cwStorage.storage or {}

cable.receive('ContainerPassword', function(player, data)
  if !istable(data) then return end

  local password = data[1]
  local entity = data[2]
  local curTime = CurTime()

  if !isstring(password) or !isentity(entity) or !IsValid(entity) or !cw.entity:IsPhysicsEntity(entity) then return end
  if !player:HasInitialized() or !player:Alive() or player:IsRagdolled() then return end
  if player:GetShootPos():Distance(entity:GetPos()) > 192 then return end
  if player.cwNextContainerPassword and curTime < player.cwNextContainerPassword then return end

  local container = cwStorage.containerList[string.lower(entity:GetModel())]

  if !container then return end

  if entity.cwPassword == password then
    cwStorage:OpenContainer(player, entity, container[1])
  else
    -- Slows down guessing a password by trying one after another.
    player.cwNextContainerPassword = curTime + 1

    cw.player:Notify(player, L('Container_WrongPassword'))
  end
end)

--- Returns the entries random container filling picks from.
--
-- The list holds every item that is not a base item and not marked `isRareItem`, and is built the first time
-- it is needed.
-- @return [List<List> `{ uniqueID, weight }` entries]
function cwStorage:GetRandomItems()
  if !self.randomItems then
    self.randomItems = {}

    for k, v in pairs(item.GetAll()) do
      if !v.isBaseItem and !v.isRareItem then
        self.randomItems[#self.randomItems + 1] = { v.uniqueID, v.weight }
      end
    end
  end

  return self.randomItems
end

--- Returns the random item entries whose item category contains a text.
-- @param category=nil [String Text the item's category must contain, ignoring case; every entry when `nil` or empty]
-- @return [List<List> `{ uniqueID, weight }` entries]
function cwStorage:GetRandomItemsByCategory(category)
  local randomItems = self:GetRandomItems()

  if !category or category == '' then
    return randomItems
  end

  local matching = {}

  category = string.lower(category)

  for k, v in ipairs(randomItems) do
    local itemTable = item.FindByID(v[1])

    if itemTable and itemTable.category and string.find(string.lower(itemTable.category), category, 1, true) then
      matching[#matching + 1] = v
    end
  end

  return matching
end

--- Picks a random entry from `cwStorage:GetRandomItems`, optionally limited to one item category.
-- @param uniqueID=nil [String Text the item's category must contain, ignoring case]
-- @return [List The `{ uniqueID, weight }` entry, or `nil` when no item matches]
function cwStorage:GetRandomItem(uniqueID)
  local randomItems = self:GetRandomItemsByCategory(uniqueID)

  if #randomItems > 0 then
    return randomItems[math.random(1, #randomItems)]
  end
end

--- Returns whether any random item has an item category containing the text.
-- @param uniqueID [String Text to look for in item categories, ignoring case]
-- @return [Boolean Whether a matching item exists; `false` when `uniqueID` is `nil`]
function cwStorage:CategoryExists(uniqueID)
  if !uniqueID then
    return false
  end

  return #self:GetRandomItemsByCategory(uniqueID) > 0
end

--- Adds random items to a container until it weighs at least a share of its capacity.
--
-- The target weight is the container's capacity divided by `6 - scale`. A prop without an inventory is made
-- into storage first.
-- @param entity [Entity The container, a prop whose model is in `cwStorage.containerList`]
-- @param scale [Number How full to make it, from 1 (a fifth of the capacity) to 5 (all of it)]
-- @param category=nil [String Text the items' categories must contain, ignoring case]
-- @return [Boolean `false` when no item of that category exists, which leaves the container as it was]
function cwStorage:FillContainer(entity, scale, category)
  local randomItems = self:GetRandomItemsByCategory(category)

  if #randomItems == 0 then
    return false
  end

  if !entity.cwInventory then
    self.storage[entity] = entity

    entity.cwInventory = {}
  end

  local capacity = self.containerList[string.lower(entity:GetModel())][1]
  local containerWeight = capacity / (6 - math.Clamp(math.Round(scale), 1, 5))
  local weight = cw.inventory:CalculateWeight(entity.cwInventory)
  local attempts = 0

  -- Weightless items never fill the container, so the number of picks is limited as well.
  while weight < containerWeight and attempts < 4096 do
    local randomItem = randomItems[math.random(1, #randomItems)]
    local itemTable = item.CreateInstance(randomItem[1])

    if itemTable then
      cw.inventory:AddInstance(entity.cwInventory, itemTable)

      weight = weight + (randomItem[2] or 0)
    end

    attempts = attempts + 1
  end

  return true
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
    cable.send(player, 'StorageMessage', {
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
