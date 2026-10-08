--- Defines the `cw.blueprints` library of the Craft plugin, which creates, registers and looks up the blueprints
-- players craft at crafting stations.
--
-- A blueprint made with `cw.blueprints:New` inherits the base blueprint's defaults and accessors; its `craftplace` is
-- the class of the station that lists it, `recipe` the materials it consumes, `required` the tools it needs, `reqatt`
-- and `updatt` the attributes it requires and progresses, and `finish` the items it produces. The files in the
-- plugin's `system` folder each register one blueprint, and `cw.blueprints:FindByID` and `cw.blueprints:GetAll` are
-- how the craft menu and the `Craft::CraftItem` netstream find them.

library.New('blueprints', cw)

local stored = cw.blueprints.stored or {}
cw.blueprints.stored = stored

local CLASS_TABLE = { __index = CLASS_TABLE }
CLASS_TABLE.name = 'Base Blueprint'
CLASS_TABLE.skin = 0
CLASS_TABLE.model = 'models/error.mdl'
CLASS_TABLE.category = 'Other'
CLASS_TABLE.description = 'Description.'
CLASS_TABLE.craftplace = 'cw_crafttable'
CLASS_TABLE.reqatt = {}
CLASS_TABLE.updatt = {}
CLASS_TABLE.required = {}
CLASS_TABLE.recipe = {}
CLASS_TABLE.finish = {}
CLASS_TABLE.requirements = {}

--- Returns the attributes a player needs to craft the blueprint.
-- @return [List The `reqatt` list of `{ attributeID, minimum }` pairs]
function CLASS_TABLE:GetRequiredAttributes()
  return self.reqatt
end

--- Returns the attributes crafting the blueprint progresses.
-- @return [List The `updatt` list of `{ attributeID, amount }` pairs]
function CLASS_TABLE:GetUpdateAttributes()
  return self.updatt
end

--- Returns the tools needed to craft the blueprint, which are not consumed.
-- @return [List The `required` list of `{ itemID, amount }` pairs]
function CLASS_TABLE:GetRequiredItems()
  return self.required
end

--- Returns the materials crafting the blueprint consumes.
-- @return [List The `recipe` list of `{ itemID, amount }` pairs]
function CLASS_TABLE:GetMaterials()
  return self.recipe
end

--- Returns the items crafting the blueprint produces.
-- @return [List The `finish` list of `{ itemID, amount }` pairs]
function CLASS_TABLE:GetResult()
  return self.finish
end

--- Returns a field of the blueprint, or a fallback when the field is `nil`.
--
-- ```
-- local name = blueprint('name', 'Unknown')
-- ```
--
-- @param varName [String Name of the field]
-- @param failSafe=nil [Any Value returned when the field is `nil`]
-- @return [Any The field's value or `failSafe`]
function CLASS_TABLE:__call(varName, failSafe)
  return (self[varName] != nil and self[varName] or failSafe)
end

--- Registers the blueprint with `cw.blueprints:Register`.
function CLASS_TABLE:Register()
  return cw.blueprints:Register(self)
end

--- Returns every registered blueprint.
-- @return [Map Blueprints keyed by unique ID]
function cw.blueprints:GetAll()
  return stored
end

--- Finds a blueprint by unique ID or by part of its name.
--
-- An exact unique ID match wins; otherwise the blueprint with the shortest name containing
-- `identifier` (case-insensitive) is returned.
--
-- @param identifier [String Unique ID or part of the blueprint's name]
-- @return [Map The blueprint, or `nil` when none matches or `identifier` is empty, `0` or a boolean]
function cw.blueprints:FindByID(identifier)
  if identifier and identifier != 0 and type(identifier) != 'boolean' then
    if stored[identifier] then
      return stored[identifier]
    end

    local lowerName = string.lower(identifier)
    local bpTable = nil

    for k, v in pairs(stored) do
      local Name = v.name

      if string.find(string.lower(Name), lowerName)
      and (!bpTable or string.utf8len(Name) < string.utf8len(bpTable('name'))) then
        bpTable = v
      end
    end

    return bpTable
  end
end

--- Creates a new blueprint object with the base blueprint defaults.
--
-- Fill in its fields (`name`, `uniqueID`, `craftplace`, `recipe`, `finish`...) and call its
-- `Register` method.
--
-- ```
-- local BLUEPRINT = cw.blueprints:New()
-- BLUEPRINT.name = '#Blueprint_Weld_Name'
-- BLUEPRINT.craftplace = 'cw_craft_wep'
-- BLUEPRINT.recipe = { { 'scrap_metal', 2 } }
-- BLUEPRINT.finish = { { 'weld', 1 } }
-- BLUEPRINT:Register()
-- ```
--
-- @return [Map The new blueprint]
function cw.blueprints:New()
  local object = cw.core:NewMetaTable(CLASS_TABLE)
  return object
end

--- Registers a blueprint so it shows up in the craft menu of its `craftplace` station.
--
-- The unique ID defaults to the name with spaces replaced by underscores, and is lowercased with
-- quotes and dots removed. On the server the blueprint's model is added to the client downloads.
--
-- @param blueprint [Map The blueprint, created with `cw.blueprints:New`]
function cw.blueprints:Register(blueprint)
  blueprint.uniqueID =
    string.lower(string.gsub(blueprint.uniqueID or string.gsub(blueprint.name, '%s', '_'), "['%.]", ''))
  stored[blueprint.uniqueID] = blueprint

  if blueprint.model then
    if SERVER then
      cw.core:AddFile(blueprint.model)
    end
  end
end
