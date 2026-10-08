--- Defines the `cw.attribute` library, the registry of character attribute definitions.
--
-- An attribute is created with `cw.attribute:New`, given a `name`, `maximum`, `description` and so on, and registered;
-- `cw.attribute:FindByID` finds one by index, unique ID or name. The attribute values of players are handled by
-- `cw.attributes`.

library.New('attribute', cw)

local stored = cw.attribute.stored or {}
local buffer = cw.attribute.buffer or {}
cw.attribute.stored = stored
cw.attribute.buffer = buffer

--[[ Set the __index meta function of the class. --]]
local CLASS_TABLE = { __index = CLASS_TABLE }

--- Registers the attribute with `cw.attribute:Register`.
--
-- @return [String The attribute's unique ID]
function CLASS_TABLE:Register()
  return cw.attribute:Register(self)
end

--- Creates a new, unregistered attribute object.
--
-- Set its fields (`name`, `maximum`, `uniqueID`, `description`, `category`, `image`...) and pass
-- it to `cw.attribute:Register`.
--
-- ```
-- local ATTRIBUTE = cw.attribute:New()
--   ATTRIBUTE.name = '#Attribute_Cloth'
--   ATTRIBUTE.maximum = 100
--   ATTRIBUTE.uniqueID = 'cloth'
-- ATB_CLOTH = cw.attribute:Register(ATTRIBUTE)
-- ```
--
-- @param name='Unknown' [String Display name of the attribute]
-- @return [Attribute The new attribute object]
function cw.attribute:New(name)
  local object = cw.core:NewMetaTable(CLASS_TABLE)
    object.name = name or 'Unknown'
  return object
end

--- Returns the registered attributes keyed by their numeric index.
--
-- @return [Map<Attribute> Attributes keyed by the CRC-based index from `cw.core:GetShortCRC`]
function cw.attribute:GetBuffer()
  return buffer
end

--- Returns the registered attributes keyed by unique ID.
--
-- @return [Map<Attribute> Attributes keyed by unique ID]
function cw.attribute:GetAll()
  return stored
end

--- Registers an attribute and returns its unique ID.
--
-- The unique ID defaults to the lowercased name with whitespace replaced by underscores, and the
-- category defaults to `#Attributes`. The index is a short CRC of the name. A progress cache is
-- created for every value from `-maximum` to `maximum`, so `maximum` must be set. On the server
-- the attribute's `image` (if any) is added to the client download list as a PNG material.
--
-- @param attribute [Attribute The attribute object, usually made by `cw.attribute:New`]
-- @return [String The attribute's unique ID]
function cw.attribute:Register(attribute)
  attribute.uniqueID = attribute.uniqueID or string.lower(string.gsub(attribute.name, '%s', '_'))
  attribute.index = cw.core:GetShortCRC(attribute.name)
  attribute.cache = {}

  if !attribute.category then
    attribute.category = '#Attributes'
  end

  for i = -attribute.maximum, attribute.maximum do
    attribute.cache[i] = {}
  end

  stored[attribute.uniqueID] = attribute
  buffer[attribute.index] = attribute

  if SERVER and attribute.image then
    cw.core:AddFile('materials/'..attribute.image..'.png')
  end

  return attribute.uniqueID
end

--- Finds an attribute by index, unique ID or part of its name.
--
-- Exact index and unique ID matches win. Otherwise the attribute with the shortest name that
-- contains `identifier` (case-insensitive, as a Lua pattern) is returned.
--
-- @param identifier [Any Numeric index, unique ID or part of the name]
-- @return [Attribute The attribute, or `nil` if none matches]
function cw.attribute:FindByID(identifier)
  if !identifier then return end

  if buffer[identifier] then
    return buffer[identifier]
  elseif stored[identifier] then
    return stored[identifier]
  end

  local tAttributeTab = nil

  for k, v in pairs(stored) do
    if string.find(string.lower(v.name), string.lower(identifier)) then
      if tAttributeTab then
        if string.utf8len(v.name) < string.utf8len(tAttributeTab.name) then
          tAttributeTab = v
        end
      else
        tAttributeTab = v
      end
    end
  end

  return tAttributeTab
end
