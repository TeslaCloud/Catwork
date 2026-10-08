--- Defines the global `item` library and the `CItem` class behind every item definition and item instance.
--
-- `item.IncludeItems` loads item files, each filling in a global `ITEM` that is registered and later merged with its
-- base item by `item.Initialize`. The library creates and finds instances, each with its own item ID and per-instance
-- data that can be networked, and on the server makes players use, drop and destroy items.

library.New('item', _G)

local stored = item.stored or {}
item.stored = stored

local buffer = item.buffer or {}
item.buffer = buffer

local weapons = item.weapons or {}
item.weapons = weapons

local instances = item.instances or {}
item.instances = instances

--- Returns every registered item definition, indexed by unique ID.
-- @return [Map<Item> Item definitions indexed by unique ID]
-- @see item.GetAll
function item.GetStored()
  return stored
end

--- Returns every registered item definition, indexed by its numeric index.
--
-- The index is the short CRC of the unique ID that items are networked by.
-- @return [Map<Item> Item definitions indexed by numeric index]
function item.GetBuffer()
  return buffer
end

--- Returns the weapon item definitions, indexed by weapon class.
--
-- Filled by `item.Initialize` with every item based on `weapon_base`, keyed by its `weaponClass`
-- or, when it has none, its unique ID.
-- @return [Map<Item> Weapon item definitions indexed by weapon class]
function item.GetWeapons()
  return weapons
end

--- Returns every item instance that exists in this realm, indexed by item ID.
-- @return [Map<Item> Item instances indexed by item ID]
function item.GetInstances()
  return instances
end

--[[
  Begin defining the item class base for other item's to inherit from.
--]]

--- The base class of every item definition and item instance.
--
-- Item files are loaded by `item.IncludeItems`, which creates a `CItem` named `ITEM` with
-- `item.New`, runs the file and registers it. An item file sets fields on `ITEM` and defines
-- callbacks:
--
-- ```
-- ITEM.name = 'Ration'
-- ITEM.model = 'models/weapons/w_package.mdl'
-- ITEM.weight = 0.5
-- ITEM.category = 'Consumables'
-- ITEM.description = 'A small, sealed ration package.'
-- ITEM:AddData('Opened', false, true)
--
-- function ITEM:OnUse(player, itemEntity)
--   player:SetHealth(math.min(player:Health() + 10, player:GetMaxHealth()))
-- end
--
-- function ITEM:OnDrop(player, position) end
-- ```
--
-- Common fields: `name`, `PrintName`, `description`, `model`, `skin`, `weight`, `space`, `cost`,
-- `batch` (how many are ordered at once), `business` (whether it can be ordered), `category`,
-- `baseItem` (unique ID of the item to inherit from), `isBaseItem`, `useSound`, `dropSound` and
-- `destroySound` (a sound path, a `List` of paths to pick from, or `false` for silence).
-- Instances additionally have a non-zero `itemID` and per-instance `data`.
--
-- Callbacks used by the item library: `OnSetup`, `OnInstantiated`, `OnUse` (return `false` to
-- cancel, `true` to keep the item), `OnDrop`, `OnCreateDropEntity`, `OnDestroy` (return `false`
-- to cancel), `OnLoaded` and `OnSaved` (return `false` to skip the item), `HasPlayerEquipped`, and
-- on the client `GetClientSideModel`, `GetClientSideSkin`, `GetClientSideName`,
-- `GetClientSideInfo` and `GetClientSideDescription`.
class 'CItem'

CItem.name = 'Item Base'
CItem.skin = 0
CItem.cost = 0
CItem.batch = 5
CItem.model = 'models/error.mdl'
CItem.weight = 1
CItem.space = 1
CItem.itemID = 0
CItem.business = false
CItem.category = 'Other'
CItem.description = '#Item_NoDescription'
CItem.proxies = {}

--- Constructs a new item object; the base class does nothing here.
--
-- `item.New` sets up the per-item tables after construction.
function CItem:CItem()
end

--- Converts the item to a string of the form `ITEM[itemID]`.
-- @return [String The string representation]
function CItem:__tostring()
  return 'ITEM['..self.itemID..']'
end

--- Returns a variable of the item, preferring the instance's data over the definition's fields.
--
-- The lookup order is the item's `data`, then any query proxy added with `CItem:AddQueryProxy`,
-- then the field on the item itself. On the client, `name` is read from `PrintName` when it is
-- set, and string values are translated with `cw.lang:TranslateText`.
--
-- ```
-- local weight = itemTable:GetVar('weight', 1)
-- ```
--
-- @param varName [String Name of the variable]
-- @param failSafe=nil [Any Value returned when the variable is not set]
-- @return [Any The variable's value, or `failSafe`]
function CItem:GetVar(varName, failSafe)
  --[[
    Check data first. We may be overriding this value
    or simply want to return it instead.
  --]]
  if self.data[varName] != nil then
    return self.data[varName]
  end

  local replacement = self.proxies[varName]

  if isstring(replacement) then
    varName = replacement
  elseif isfunction(replacement) then
    return replacement(self)
  end

  if CLIENT then
    if varName:lower() == 'name' then
      if isstring(self.PrintName) then
        varName = 'PrintName'
      end
    end

    local var = self[varName]

    if isstring(var) then
      return cw.lang:TranslateText(var)
    end
  end

  return (self[varName] != nil and self[varName]) or failSafe
end

--- Redirects `CItem:GetVar` lookups of one variable to another variable or a function.
--
-- ```
-- ITEM:AddQueryProxy('weight', function(itemTable)
--   return itemTable:GetData('Rounds') * 0.01
-- end)
-- ```
--
-- @param var [String Name of the variable to redirect]
-- @param replacement [Any Name of the variable to read instead, or a function that receives the item and returns
-- the value]
function CItem:AddQueryProxy(var, replacement)
  self.proxies[var] = replacement
end

--- Sets a field on the item.
--
-- Equivalent to assigning the field directly; provided to pair with `CItem:GetVar`.
-- @param varName [String Name of the field]
-- @param value [Any The new value]
function CItem:Override(varName, value)
  self[varName] = value
end

--- Declares a per-instance data field with a default value.
--
-- Call it in an item file. The default is used when instances are created, values equal to it are
-- left out when the inventory is saved, and networked fields are sent to clients when changed with
-- `CItem:SetData`.
--
-- ```
-- ITEM:AddData('Rounds', -1, true)
-- ```
--
-- @param dataName [String Name of the data field]
-- @param value [Any Default value]
-- @param bNetworked=nil [Boolean Send changes of this field to clients]
function CItem:AddData(dataName, value, bNetworked)
  self.data[dataName] = value
  self.defaultData[dataName] = value
  self.networkData[dataName] = bNetworked
end

--- Removes a data field declared with `CItem:AddData`, including its default and network flag.
-- @param dataName [String Name of the data field]
function CItem:RemoveData(dataName)
  self.data[dataName] = nil
  self.defaultData[dataName] = nil
  self.networkData[dataName] = nil
end

--- Returns whether an item's data equals the data stored on the `item` library table.
--
-- Declared with `.` on the library instead of as a `CItem` method, so it compares against
-- `item.data` rather than another item.
-- @param itemTable [Item The item to compare]
-- @return [Boolean Whether the data tables are equal]
function item.HasSameDataAs(itemTable)
  return cw.core:AreTablesEqual(item.data, itemTable.data)
end

--- Returns whether the item is an instance rather than a definition.
-- @return [Boolean Whether the item has a non-zero `itemID`]
function CItem:IsInstance()
  return (self.itemID != 0)
end

--- Returns whether the item is, or inherits from, the item with a unique ID.
--
-- Follows the `baseItem` chain through every ancestor.
--
-- ```
-- if itemTable:IsBasedFrom('weapon_base') then
--   print(itemTable('name')..' is a weapon.')
-- end
-- ```
--
-- @param uniqueID [String Unique ID of the base item]
-- @return [Boolean Whether the item is based on that item]
function CItem:IsBasedFrom(uniqueID)
  local itemTable = self

  if itemTable.uniqueID == uniqueID then
    return true
  end

  while itemTable and itemTable.baseItem do
    if itemTable.baseItem == uniqueID then
      return true
    end

    itemTable = item.FindByID(itemTable.baseItem)
  end

  return false
end

--- Returns the definition of an item by unique ID, usually one of this item's bases.
-- @param uniqueID [String Unique ID of the item]
-- @return [Item The item definition, or `nil` when not found]
-- @see item.FindByID
function CItem:GetBaseClass(uniqueID)
  return item.FindByID(uniqueID)
end

--- Returns whether the item can be ordered from the business menu.
-- @return [Boolean Whether the item is not a base item and has `business` set]
function CItem:CanBeOrdered()
  return (!self.isBaseItem and self.business)
end

--- Returns a data field of the item, falling back to the item field of the same name.
--
-- Falsy data values (`false`, `nil`) fall through to the item field and then to `default`.
-- @param dataName [String Name of the data field]
-- @param default=nil [Any Value returned when neither the data nor the field is set]
-- @return [Any The value]
-- @see CItem:SetData
function CItem:GetData(dataName, default)
  return self.data[dataName] or self[dataName] or default
end

--- Adds a recipe of ingredients that ordering the item consumes.
--
-- Arguments alternate between an ingredient's unique ID and the amount needed. When an item has
-- recipes, ordering it requires the ingredients of a recipe the player has access to.
--
-- ```
-- ITEM:AddRecipe('scrap_metal', 2, 'cloth', 1)
-- ```
--
-- @param ... [Any Pairs of ingredient unique IDs and amounts]
-- @return [Map The recipe, with an `ingredients` table of amounts indexed by unique ID]
function CItem:AddRecipe(...)
  local arguments = { ... }
  local currentItem = nil
  local recipeTable = { ingredients = {} }

  for k, v in pairs(arguments) do
    if type(v) == 'string' then
      currentItem = v
    elseif type(v) == 'number' then
      if currentItem then
        recipeTable.ingredients[currentItem] = v
      end
    end
  end

  self.recipes[#self.recipes + 1] = recipeTable

  return recipeTable
end

--- Returns whether another item is the same instance as this one.
-- @param itemTable [Item The item to compare; may be `nil`]
-- @return [Boolean Whether both have the same unique ID and item ID]
function CItem:IsTheSameAs(itemTable)
  if itemTable then
    return (itemTable.uniqueID == self.uniqueID
    and itemTable.itemID == self.itemID)
  else
    return false
  end
end

--- Returns whether a data field is sent to clients when it changes.
-- @param key [String Name of the data field]
-- @return [Boolean Whether the field was declared networked with `CItem:AddData`]
function CItem:IsDataNetworked(key)
  return (self.networkData[key] == true)
end

if SERVER then
  --- Returns the first recipe of an item that a player has access to and owns every ingredient of.
  -- @param itemTable [Item The item being ordered]
  -- @param player [Player The player ordering it]
  -- @return [Map The recipe, or `nil` when the player can make none]
  local function FindAffordableRecipe(itemTable, player)
    for k, v in ipairs(itemTable.recipes) do
      if cw.core:HasObjectAccess(player, v) then
        local hasIngredients = true

        for k2, v2 in pairs(v.ingredients) do
          local itemList = player:GetItemsByID(k2)

          if !itemList or table.Count(itemList) < v2 then
            hasIngredients = false
            break
          end
        end

        if hasIngredients then
          return v
        end
      end
    end
  end

  --- Takes the cost of an order from a player.
  --
  -- Takes the ingredients of the first recipe the player has access to and owns enough of, then
  -- takes `cost * batch` cash and logs the order. Call `CItem:CanPlayerAfford` first.
  -- @param player [Player The player ordering the item]
  function CItem:DeductFunds(player)
    local recipe = FindAffordableRecipe(self, player)

    if recipe then
      for k, v in pairs(recipe.ingredients) do
        for i = 1, v do
          player:TakeItemByID(k)
        end
      end
    end

    if self.cost == 0 then
      return
    end

    if self.batch > 1 then
      cw.player:GiveCash(player, -(self.cost * self.batch), self.batch..' '..cw.core:Pluralize(self.PrintName))
      cw.core:PrintLog(
        LOGTYPE_MINOR,
        player:Name()..' has ordered '..self.batch..' '..cw.core:Pluralize(self.PrintName)..'.'
      )
    else
      cw.player:GiveCash(player, -(self.cost * self.batch), self.batch..' '..self.PrintName)
      cw.core:PrintLog(LOGTYPE_MINOR, player:Name()..' has ordered '..self.batch..' '..self.PrintName..'.')
    end
  end

  --- Returns whether a player can afford to order the item.
  --
  -- The player must have `cost * batch` cash and, when the item has recipes, every ingredient of a
  -- recipe they have access to.
  -- @param player [Player The player ordering the item]
  -- @return [Boolean Whether the player can afford the order]
  function CItem:CanPlayerAfford(player)
    if !cw.player:CanAfford(player, self.cost * self.batch) then
      return false
    end

    if #self.recipes > 0 then
      return FindAffordableRecipe(self, player) != nil
    end

    return true
  end
end

--- Registers the item definition.
-- @see item.Register
function CItem:Register()
  return item.Register(self)
end

if SERVER then
  --- Sets a data field of an item instance and networks it when the field is networked.
  --
  -- Only changes fields declared with `CItem:AddData` (whose current value is not `nil`) on
  -- instances. Networked changes are queued and sent to observers one second later with
  -- `item.SendUpdate`.
  -- @param dataName [String Name of the data field]
  -- @param value [Any The new value]
  -- @see CItem:GetData
  function CItem:SetData(dataName, value)
    if self:IsInstance() and self.data[dataName] != nil and self.data[dataName] != value then
      self.data[dataName] = value

      if self:IsDataNetworked(dataName) then
        self.networkQueue[dataName] = value
        self:NetworkData()
      end
    end
  end

  --- Sends the item's queued data changes to its observers after one second.
  --
  -- Does nothing when a send is already scheduled; changes made in the meantime are sent with it.
  function CItem:NetworkData()
    local timerName = 'NetworkItem'..self.itemID

    if timer.Exists(timerName) then
      return
    end

    timer.Create(timerName, 1, 1, function()
      -- A field set to `nil` leaves nothing in the queue to send.
      if next(self.networkQueue) != nil then
        item.SendUpdate(
          self, self.networkQueue
        )
        self.networkQueue = {}
      end
    end)
  end
else
  --- Sends a menu option chosen for the item to the server over the `MenuOption` Cable message.
  -- @param option [String The option chosen]
  -- @param data [Any Extra data for the option]
  -- @param entity [Entity The item entity the option was chosen on, if any]
  function CItem:SubmitOption(option, data, entity)
    cable.send('MenuOption', { option = option, data = data, item = self.itemID, entity = entity })
  end
end

--[[
  End defining the base item class and begin defining
  the item utility functions.
--]]

--- Returns every registered item definition, indexed by unique ID.
-- @return [Map<Item> Item definitions indexed by unique ID]
-- @see item.GetStored
function item.GetAll()
  return stored
end

--- Creates a new, unregistered item definition.
--
-- Item files get one as `ITEM` from `item.IncludeItems`; call it directly to build items in code
-- and register them with `CItem:Register`.
--
-- ```
-- local ITEM = item.New('gold_bar')
-- ITEM.name = 'Gold Bar'
-- ITEM.weight = 2
-- ITEM:Register()
-- ```
--
-- @param uniqueID [String Unique ID of the item]
-- @return [Item The new item definition]
function item.New(uniqueID)
  local object = CItem()
    object.networkQueue = {}
    object.networkData = {}
    object.defaultData = {}
    object.recipes = {}
    object.proxies = {}
    object.isBaseItem = nil
    object.baseItem = nil
    object.uniqueID = uniqueID
    object.data = {}
  return object
end

--- Registers an item definition so it can be found and instantiated.
--
-- The unique ID is lowercased and stripped of `'` and `.`, falling back to the name with spaces
-- replaced by underscores. Sets `index` and `PrintName`, and on the server adds the item's models
-- to the client downloads during the initial load.
-- @param itemTable [Item The item definition]
function item.Register(itemTable)
  itemTable.uniqueID =
    string.lower(string.gsub(itemTable.uniqueID or string.gsub(itemTable.name, '%s', '_'), "['%.]", ''))
  itemTable.index = cw.core:GetShortCRC(itemTable.uniqueID)
  itemTable.PrintName = itemTable.PrintName or itemTable.name or '#Item_UnknownItem'

  stored[itemTable.uniqueID] = itemTable
  buffer[itemTable.index] = itemTable

  if !_G['cwSharedBooted'] then
    if itemTable.model then
      if SERVER then
        cw.core:AddFile(itemTable.model)
      end
    end

    if itemTable.attachmentModel then
      if SERVER then
        cw.core:AddFile(itemTable.attachmentModel)
      end
    end

    if itemTable.replacement then
      if SERVER then
        cw.core:AddFile(itemTable.replacement)
      end
    end
  end
end

--- Restores the `CItem` metatable and methods on an item table, such as one received or copied.
--
-- Does nothing to tables that already have the methods.
-- @param itemTable [Item The item table; anything that is not a table is ignored]
-- @param bShouldMerge=nil [Boolean Return a copy of the registered definition with the table's fields merged into it]
-- @return [Item The item table or the merged copy, or `nil` when `itemTable` is not a table]
function item.Validate(itemTable, bShouldMerge)
  if istable(itemTable) then
    if !isfunction(itemTable.Register) then
      local blankItem = CItem()
      local oldItem = table.Copy(itemTable)

      setmetatable(itemTable, CItem)

      table.SafeMerge(itemTable, blankItem)
      table.SafeMerge(itemTable, oldItem)
    end

    if bShouldMerge then
      local template = item.FindByID(itemTable.uniqueID)

      if template then
        local copy = table.Copy(template)

        table.SafeMerge(copy, itemTable)

        itemTable = copy
      end
    end

    return itemTable
  end
end

--- Creates a new instance of an item with a copy of another instance's data.
-- @param itemTable [Item The instance to copy]
-- @return [Item The new instance]
function item.CreateCopy(itemTable)
  item.Validate(itemTable)

  return item.CreateInstance(
    itemTable.uniqueID, nil, itemTable.data
  )
end

--- Returns whether an item is based on `weapon_base`.
-- @param itemTable [Item The item]
-- @return [Boolean Whether the item is a weapon]
function item.IsWeapon(itemTable)
  item.Validate(itemTable)

  if itemTable and itemTable:IsBasedFrom('weapon_base') then
    return true
  end

  return false
end

--- Returns the item instance a weapon entity was created from.
--
-- The instance is found through the weapon's `ItemID` networked string.
-- @param weapon [Weapon The weapon]
-- @return [Item The item instance, or `nil` when the weapon is invalid or not from an item]
function item.GetByWeapon(weapon)
  if IsValid(weapon) then
    local itemID = tonumber(weapon:GetNWString('ItemID'))

    if itemID and itemID != 0 then
      return item.FindInstance(itemID)
    end
  end
end

--- Creates an instance of an item, or returns the existing instance with that item ID.
--
-- The instance is a copy of the definition stored in `item.GetInstances`. Data and custom fields
-- are merged into it, and its `OnInstantiated` callback is called. Instances only exist in the
-- realm they are created in; give them to players to network them.
--
-- When the item ID already belongs to an instance of another item, the server gives the new
-- instance an ID of its own, so check the returned instance's `itemID`; the client replaces its
-- instance, as the server decides which item an ID stands for.
--
-- ```
-- local itemTable = item.CreateInstance('ration', nil, { Opened = true })
-- ```
--
-- @param uniqueID [Any Unique ID, index or name of the item, as accepted by `item.FindByID`]
-- @param itemID=nil [Number Item ID of the instance; a new one is generated when `nil`]
-- @param data=nil [Map Data fields to merge into the instance's `data`]
-- @param customData=nil [Map Fields to merge into the instance itself]
-- @return [Item The instance, or `nil` when the item does not exist]
function item.CreateInstance(uniqueID, itemID, data, customData)
  local itemTable = item.FindByID(uniqueID)

  item.Validate(itemTable)

  if itemID then itemID = tonumber(itemID) end

  if itemTable then
    if !itemID then
      itemID = item.GenerateID()
    elseif instances[itemID] and instances[itemID].uniqueID != itemTable.uniqueID then
      if SERVER then
        itemID = item.GenerateID()
      else
        instances[itemID] = nil
      end
    end

    if !instances[itemID] then
      -- Instances share their base definition instead of each carrying a copy of it.
      local baseClass = itemTable.baseClass

      itemTable.baseClass = nil
      instances[itemID] = table.Copy(itemTable)
      itemTable.baseClass = baseClass

      instances[itemID].baseClass = baseClass
      instances[itemID].itemID = itemID
    end

    if data then
      table.Merge(instances[itemID].data, data)
    end

    if customData then
      table.Merge(instances[itemID], customData)
    end

    if instances[itemID].OnInstantiated then
      instances[itemID]:OnInstantiated()
    end

    return instances[itemID]
  end
end

--[[ Just to make sure we never ever get the same ID. --]]
item.ITEM_INDEX = item.ITEM_INDEX or 0

--- Generates a new item ID from the current time and an increasing counter.
--
-- IDs of instances that already exist in this realm are skipped.
-- @return [Number The new item ID]
function item.GenerateID()
  local itemID

  repeat
    item.ITEM_INDEX = item.ITEM_INDEX + 1
    itemID = os.time() + item.ITEM_INDEX
  until !instances[itemID]

  return itemID
end

--- Returns the item instance with an item ID.
-- @param itemID [Number The item ID, or a string containing it]
-- @return [Item The instance, or `nil` when it does not exist]
function item.FindInstance(itemID)
  return instances[tonumber(itemID)]
end

--- Returns a minimal table describing an item instance, used to network it.
-- @param itemTable [Item The instance]
-- @param bNetworkData=nil [Boolean Include the values of the networked data fields]
-- @return [Map The definition with `itemID`, `index` and `data`]
function item.GetDefinition(itemTable, bNetworkData)
  item.Validate(itemTable)

  local definition = {
    itemID = itemTable.itemID,
    index = itemTable.index,
    data = {}
  }

  if bNetworkData then
    for k, v in pairs(itemTable.networkData) do
      if v then
        definition.data[k] = itemTable:GetData(k)
      end
    end
  end

  return definition
end

--- Returns a table that identifies an item instance.
-- @param itemTable [Item The instance]
-- @return [Map A table with the item's `uniqueID` and `itemID`]
function item.GetSignature(itemTable)
  item.Validate(itemTable)

  return { uniqueID = itemTable.uniqueID, itemID = itemTable.itemID }
end

--- Finds an item definition by index, unique ID, weapon class or name.
--
-- When there is no exact match, the shortest item whose name contains the identifier (case
-- insensitive, as plain text) is returned, falling back to a match on `PrintName`.
--
-- ```
-- local itemTable = item.FindByID('ration')
-- ```
--
-- @param identifier [Any The index (`Number`), unique ID, weapon class or part of the name (`String`)]
-- @param bShouldValidate=nil [Boolean Return a merged copy of the definition, as `item.Validate` does]
-- @return [Item The item definition, or `nil` when none matches]
function item.FindByID(identifier, bShouldValidate)
  if !isbool(identifier) and identifier and identifier != 0 and identifier != '' then
    if buffer[identifier] then
      return item.Validate(buffer[identifier], bShouldValidate)
    elseif stored[identifier] then
      return item.Validate(stored[identifier], bShouldValidate)
    elseif weapons[identifier] then
      return item.Validate(weapons[identifier], bShouldValidate)
    end

    if !isstring(identifier) then
      return
    end

    local lowerName = string.utf8lower(identifier)
    local itemTable = nil

    for k, v in pairs(stored) do
      local itemName = v.name

      if string.find(string.utf8lower(itemName), lowerName, 1, true)
      and (!itemTable or string.utf8len(itemName) < string.utf8len(itemTable.name)) then
        itemTable = v
      end

      if !itemTable and v.PrintName != itemName then
        if string.find(string.utf8lower(v.PrintName), lowerName, 1, true) then
          itemTable = v
        end
      end
    end

    return item.Validate(itemTable, bShouldValidate)
  end
end

--- Merges an item over a copy of its base item, resolving the base's own bases first.
--
-- Unless temporary, the result is registered in place of the item with `baseClass` set to the base.
-- @param itemTable [Item The item definition]
-- @param baseItem [String Unique ID of the base item]
-- @param bTemporary=nil [Boolean Return the merged table without registering it]
-- @return [Item The merged item, or `nil` when the base does not exist or is the item itself]
function item.Merge(itemTable, baseItem, bTemporary)
  item.Validate(itemTable, false)

  local baseTable = item.FindByID(baseItem)
  local isBaseItem = itemTable.isBaseItem

  if baseTable and baseTable != itemTable then
    local baseTableCopy = table.Copy(baseTable)

    if baseTableCopy.baseItem then
      baseTableCopy = item.Merge(
        baseTableCopy,
        baseTableCopy.baseItem,
        true
      )

      if !baseTableCopy then
        return
      end
    end

    table.Merge(baseTableCopy, itemTable)

    if !bTemporary then
      baseTableCopy.baseClass = baseTable
      baseTableCopy.isBaseItem = isBaseItem
      item.Register(baseTableCopy)
    end

    return baseTableCopy
  end
end

--- Merges every item with its base, sets up weapon items and fires the item initialization hooks.
--
-- Items whose base item does not exist are removed. Calls each item's `OnSetup`, fires
-- `ClockworkItemInitialized` for every item and `ClockworkPostItemsInitialized` once at the end.
-- @warning [Internal] Called by the gamemode once items and plugins have loaded.
function item.Initialize()
  local itemsTable = item.GetAll()

  for k, v in pairs(itemsTable) do
    if v.baseItem and !item.Merge(v, v.baseItem) then
      itemsTable[k] = nil
    end
  end

  for k, v in pairs(itemsTable) do
    if v.OnSetup then v:OnSetup() end

    if item.IsWeapon(v) then
      weapons[(v.weaponClass or v.uniqueID)] = v
    end

    hook.Run('ClockworkItemInitialized', v)
  end

  hook.Run('ClockworkPostItemsInitialized', itemsTable)
end

if SERVER then
  local entities = item.entities or {}
  item.entities = entities

  --- Plays the sound of an item action on a player.
  -- @param player [Player The player to play the sound on]
  -- @param itemSound [Any A sound path, a `List` of paths to pick from, `false` for silence or `nil` for the default]
  -- @param defaultSound [String Sound played when the item has none]
  local function EmitItemSound(player, itemSound, defaultSound)
    if itemSound then
      if istable(itemSound) then
        player:EmitSound(itemSound[math.random(1, #itemSound)])
      else
        player:EmitSound(itemSound)
      end
    elseif itemSound != false then
      player:EmitSound(defaultSound)
    end
  end

  --- Makes a player use an item from their inventory.
  --
  -- Calls the item's `OnUse`: a `nil` return takes the item from the player, `false` cancels the use
  -- and any other value keeps the item. Plays the item's `useSound` and fires `PlayerUseItem`.
  -- @param player [Player The player using the item]
  -- @param itemTable [Item The item instance]
  -- @param bNoSound=nil [Boolean Do not play the use sound]
  -- @return [Boolean `true` when used, `false` when `OnUse` cancelled it, `nil` when the player does not have the item
  -- or it cannot be used]
  function item.Use(player, itemTable, bNoSound)
    local itemEntity = player:GetItemEntity()

    item.Validate(itemTable)

    if itemTable and player:HasItemInstance(itemTable) then
      if itemTable.OnUse then
        if itemEntity and itemEntity.cwItemTable == itemTable then
          player:SetItemEntity(nil)
        end

        local onUse = itemTable:OnUse(player, itemEntity)

        if onUse == nil then
          player:TakeItem(itemTable)
        elseif onUse == false then
          return false
        end

        if !bNoSound then
          EmitItemSound(player, itemTable.useSound, 'weapons/universal/uni_pistol_holster.wav')
        end

        hook.Run('PlayerUseItem', player, itemTable, itemEntity)

        return true
      end
    end
  end

  --- Makes a player drop an item, spawning it as an entity.
  --
  -- Calls the item's `OnDrop` (return `false` to cancel), takes the item and creates the entity with
  -- `OnCreateDropEntity` or `cw.entity:CreateItem`. When no position is given, the item is dropped
  -- where the player is looking, flush to the ground. Plays the `dropSound` and fires
  -- `PlayerDropItem`.
  -- @param player [Player The player dropping the item]
  -- @param itemTable [Item The item instance]
  -- @param position=nil [Vector Where to drop the item]
  -- @param bNoSound=nil [Boolean Do not play the drop sound]
  -- @param bNoTake=nil [Boolean Do not require or take the item from the player's inventory]
  -- @return [Boolean `true` when dropped, `false` when `OnDrop` cancelled it, `nil` when the item cannot be dropped]
  function item.Drop(player, itemTable, position, bNoSound, bNoTake)
    item.Validate(itemTable)

    if itemTable and (bNoTake or player:HasItemInstance(itemTable)) then
      local traceLine = nil
      local entity = nil

      if itemTable.OnDrop then
        if !position then
          traceLine = player:GetEyeTraceNoCursor()
          position = traceLine.HitPos
        end

        if itemTable:OnDrop(player, position) == false then
          return false
        end

        if !bNoTake then
          player:TakeItem(itemTable)
        end

        if itemTable.OnCreateDropEntity then
          entity = itemTable:OnCreateDropEntity(player, position)
        end

        if !IsValid(entity) then
          entity = cw.entity:CreateItem(player, itemTable, position)
        end

        if IsValid(entity) then
          if traceLine and traceLine.HitNormal then
            cw.entity:MakeFlushToGround(entity, position, traceLine.HitNormal)
          end
        end

        if !bNoSound then
          EmitItemSound(
            player, itemTable.dropSound, 'physics/body/body_medium_impact_soft'..math.random(1, 7)..'.wav'
          )
        end

        hook.Run('PlayerDropItem', player, itemTable, position, entity)

        return true
      end
    end
  end

  --- Makes a player destroy an item from their inventory.
  --
  -- Calls the item's `OnDestroy` (return `false` to cancel), takes the item, plays the
  -- `destroySound` and fires `PlayerDestroyItem`.
  -- @param player [Player The player destroying the item]
  -- @param itemTable [Item The item instance]
  -- @param bNoSound=nil [Boolean Do not play the destroy sound]
  -- @return [Boolean `true` when destroyed, `false` when cancelled, `nil` when the item cannot be destroyed]
  function item.Destroy(player, itemTable, bNoSound)
    item.Validate(itemTable)

    if itemTable and player:HasItemInstance(itemTable) and itemTable.OnDestroy then
      if itemTable:OnDestroy(player) == false then
        return false
      end

      player:TakeItem(itemTable)

      if !bNoSound then
        EmitItemSound(
          player, itemTable.destroySound, 'physics/body/body_medium_impact_soft'..math.random(1, 7)..'.wav'
        )
      end

      hook.Run('PlayerDestroyItem', player, itemTable)

      return true
    end
  end

  --- Forgets the item entity of an instance, called when the entity is removed.
  --
  -- Does nothing when the entity has no item, or when the instance has since been spawned as another entity.
  -- @param entity [Entity The item entity]
  function item.RemoveItemEntity(entity)
    local itemTable = entity:GetItemTable()

    if itemTable and entities[itemTable.itemID] == entity then
      entities[itemTable.itemID] = nil
    end
  end

  --- Records the entity an item instance has been spawned as.
  -- @param entity [Entity The item entity]
  -- @param itemTable [Item The item instance]
  function item.AddItemEntity(entity, itemTable)
    item.Validate(itemTable)

    entities[itemTable.itemID] = entity
  end

  --- Returns the entity an item instance has been spawned as.
  -- @param itemTable [Item The item instance]
  -- @return [Entity The item entity, or `nil` when it does not exist]
  function item.FindEntityByInstance(itemTable)
    item.Validate(itemTable)

    local entity = entities[itemTable.itemID]

    if IsValid(entity) then
      return entity
    end
  end

  --- Sends an item instance and its networked data to a player over the `ItemData` Cable message.
  --
  -- The client creates the instance without adding it to an inventory.
  -- @param player [Player The player to send to]
  -- @param itemTable [Item The item instance; nothing is sent when `nil`]
  function item.SendToPlayer(player, itemTable)
    if itemTable then
      cable.send(
        player, 'ItemData', item.GetDefinition(itemTable, true)
      )
    end
  end

  --- Sends changed item data to the item's observers over the `InvNetwork` Cable message.
  --
  -- The observers are collected with the `ItemGetNetworkObservers` hook, which fills `info.observers`;
  -- returning `true` from it or setting `info.sendToAll` sends the update to every player.
  -- @param itemTable [Item The item instance]
  -- @param data [Map The changed data fields]
  -- @return [List<Player> The observers the update was sent to, or `nil` when sent to everyone]
  function item.SendUpdate(itemTable, data)
    item.Validate(itemTable)

    local info = {
      observers = {}, sendToAll = false
    }
    local recipients = nil

    if !hook.Run('ItemGetNetworkObservers', itemTable, info)
    and !info.sendToAll then
      recipients = {}

      -- The hook indexes the observers by player, while cable.send wants a list.
      for k, v in pairs(info.observers) do
        recipients[#recipients + 1] = v
      end
    end

    cable.send(recipients, 'InvNetwork', {
      itemID = itemTable.itemID,
      data = data
    })

    return recipients
  end
else
  --- Returns the model and skin to draw an item's icon with.
  --
  -- Uses `iconModel`/`iconSkin`, then `model`/`skin`, overridden by the item's
  -- `GetClientSideModel`/`GetClientSideSkin`, falling back to an oil drum model.
  -- @param itemTable [Item The item]
  -- @return [String The model path, Number The skin]
  function item.GetIconInfo(itemTable)
    item.Validate(itemTable)

    local model = itemTable.iconModel or itemTable.model
    local skin = itemTable.iconSkin or itemTable.skin

    if itemTable.GetClientSideModel then
      model = itemTable:GetClientSideModel()
    end

    if itemTable.GetClientSideSkin then
      skin = itemTable:GetClientSideSkin()
    end

    if !model then
      model = 'models/props_c17/oildrum001.mdl'
    end

    return model, skin
  end

  --- Builds an item's markup tooltip with its name, weight, space, description and category.
  --
  -- The item's `GetClientSideName`, `GetClientSideInfo` and `GetClientSideDescription` override
  -- the defaults. The callback can change the shown values before the markup is built.
  --
  -- ```
  -- local toolTip = item.GetMarkupToolTip(itemTable, false, function(display)
  --   display.weight = 'Weightless'
  -- end)
  -- ```
  --
  -- @param itemTable [Item The item]
  -- @param bBusinessStyle=nil [Boolean Show the batch size and the price, coloured by whether the player can afford
  -- it]
  -- @param Callback=nil [Function Called with the display info `Map` (`name`, `weight`, `space`, `toolTip` and
  -- `itemTitle`, which replaces the title when set)]
  -- @return [String The markup text]
  function item.GetMarkupToolTip(itemTable, bBusinessStyle, Callback)
    item.Validate(itemTable)

    local informationColor = cw.option:GetColor('information')
    local description = itemTable.description
    local toolTip = itemTable.toolTip
    local weight = tostring(itemTable.weight)..L('#Unit_Kilograms')
    local space = tostring(itemTable.space)..L('#Unit_Litres')
    local name = itemTable.PrintName

    if CLIENT then
      name = cw.lang:TranslateText(name)
      description = cw.lang:TranslateText(description)
    end

    local weightText = itemTable.weightText

    if weightText then
      weight = weightText
    end

    local spaceText = itemTable.spaceText

    if spaceText then
      space = spaceText
    end

    if itemTable.GetClientSideName then
      if itemTable:GetClientSideName() then
        name = itemTable:GetClientSideName()
      end
    end

    if bBusinessStyle and itemTable.batch > 1 then
      name = itemTable.batch..' x '..cw.core:Pluralize(name)
    end

    local toolTipTitle = ''
    local toolTipColor = informationColor
    local markupObject = cw.theme:GetMarkupObject()

    if itemTable.GetClientSideInfo
    and itemTable:GetClientSideInfo() then
      toolTip = itemTable:GetClientSideInfo(markupObject)
    end

    if itemTable.GetClientSideDescription
    and itemTable:GetClientSideDescription() then
      description = itemTable:GetClientSideDescription()
    end

    local displayInfo = {
      itemTitle = nil,
      toolTip = toolTip,
      weight = weight,
      space = space,
      name = name
    }

    if Callback then
      Callback(displayInfo)
    end

    if cw.inventory:UseSpaceSystem() then
      toolTipTitle = displayInfo.name..', '..displayInfo.weight..', '..displayInfo.space
    else
      toolTipTitle = displayInfo.name..', '..displayInfo.weight
    end

    if displayInfo.itemTitle then
      toolTipTitle = displayInfo.itemTitle
    end

    if itemTable.color then
      toolTipColor = itemTable.color
    end

    markupObject:Title(toolTipTitle, toolTipColor)

    if displayInfo.toolTip then
      markupObject:Add(description)
      markupObject:Title(L('#ItemContextMenu_Information'))
      markupObject:Add(displayInfo.toolTip)
    else
      markupObject:Add(description)
    end

    if bBusinessStyle then
      local redColor = Color(255, 50, 50, 255)
      local greenColor = Color(50, 255, 50, 255)

      local totalCost = itemTable.cost * itemTable.batch

      if config.Get('cash_enabled'):Get()
      and totalCost != 0 then
        local costString = cw.core:FormatCash(totalCost)
        local colorToUse = redColor

        if cw.player:GetCash() >= totalCost then
          colorToUse = greenColor
        end

        markupObject:Title(L('#ItemContextMenu_Price'))
        markupObject:Add(costString, colorToUse, 1)
      end
    end

    markupObject:Title(L('#ItemContextMenu_Category'))
    markupObject:Add(L(itemTable.category))

    return markupObject:GetText()
  end

  cable.receive('ItemData', function(data)
    item.CreateInstance(
      data.index, data.itemID, data.data
    )
  end)
end

pipeline.Register('item', function(uniqueID, fileName, pipe)
  ITEM = item.New(uniqueID)

  util.Include(fileName)

  ITEM:Register() ITEM = nil
end)

--- Loads every item file in a directory.
--
-- Each file is run with a new item as `ITEM`, named after the file without its realm prefix, and
-- registered afterwards.
-- @param directory [String Lua path of the directory]
function item.IncludeItems(directory)
  pipeline.IncludeDirectory('item', directory)
end
