--- Defines the `cw.currency` library, a registry of named currency objects that each carry a world model and a default
-- amount.
--
-- `cw.currency:Add` creates a currency and `cw.currency:Get` returns one, creating it if needed. A currency object can
-- be called like a function to query its data.

library.New('currency', cw)

local stored = cw.currency.stored or {}
cw.currency.stored = stored

--[[ Set the __index meta function of the class. --]]
local CLASS_TABLE = {}
CLASS_TABLE.__index = CLASS_TABLE

--- Makes the currency object callable as a shorthand for `CLASS_TABLE:Query`.
--
-- ```
-- local model = currency('model', 'models/props_c17/briefcase001a.mdl')
-- ```
--
-- @param parameter [String Data key to read]
-- @param failSafe=nil [Any Value returned when the key is not set]
-- @return [Any The stored value, or `failSafe`]
function CLASS_TABLE:__call(parameter, failSafe)
  return self:Query(parameter, failSafe)
end

--- Creates a new currency object with empty data.
--
-- Use `cw.currency:Add` to create and store a currency.
--
-- @param name [String Display name of the currency]
-- @return [Map The new currency object]
function CLASS_TABLE:Create(name)
  local object = cw.core:NewMetaTable(CLASS_TABLE)
    object.name = name
    object.data = {}
  return object
end

--- Returns a value from the currency's data.
--
-- @param key [String Data key to read]
-- @param failSafe=nil [Any Value returned when the key is not set]
-- @return [Any The stored value, or `failSafe`]
function CLASS_TABLE:Query(key, failSafe)
  if self.data and self.data[key] != nil then
    return self.data[key]
  else
    return failSafe
  end
end

--- Sets a value in the currency's data.
--
-- @param key [String Data key to set]
-- @param value [Any New value]
function CLASS_TABLE:SetData(key, value)
  if self.data then
    self.data[key] = value
  end
end

--- Returns the currency's world model.
--
-- @return [String The model path; a briefcase model when none is set]
function CLASS_TABLE:GetModel()
  return self('model', 'models/props_c17/briefcase001a.mdl')
end

--- Sets the currency's world model.
--
-- @param model [String Model path]
function CLASS_TABLE:SetModel(model)
  self:SetData('model', model)
end

--- Returns the currency's default amount.
--
-- @return [Number The default amount, 0 when none is set]
function CLASS_TABLE:GetDefault()
  return self('default', 0)
end

--- Sets the currency's default amount.
--
-- @param amount [Number The default amount]
function CLASS_TABLE:SetDefault(amount)
  self:SetData('default', amount)
end

--- Creates and stores a new currency.
--
-- The key is the name lowercased with whitespace replaced by underscores. Does nothing if a
-- currency with that key already exists.
--
-- @param name [String Display name of the currency]
-- @param model=nil [String World model path]
-- @param defaultValue=nil [Number Default amount]
-- @return [Map The new currency object, or `nil` if the currency already exists]
function cw.currency:Add(name, model, defaultValue)
  local key = string.lower(string.gsub(name, '%s', '_'))

  if !stored[key] then
    local currencyObject = CLASS_TABLE:Create(name)

    if model != nil then
      currencyObject:SetModel(model)
    end

    if defaultValue != nil and defaultValue != 0 then
      currencyObject:SetDefault(defaultValue)
    end

    stored[key] = currencyObject

    return currencyObject
  end
end

--- Returns a currency, creating it if it does not exist yet.
--
-- Returns an empty table while the `cash_enabled` config is off.
--
-- @param name [String Display name or key of the currency]
-- @return [Map The currency object]
function cw.currency:Get(name)
  if config.Get('cash_enabled'):Get() then
    local key = string.lower(string.gsub(name, '%s', '_'))

    if !stored[key] then
      return self:Add(name)
    else
      return stored[key]
    end
  else
    return {}
  end
end

--- Returns every stored currency.
--
-- Returns an empty table while the `cash_enabled` config is off.
--
-- @return [Map<Map> Currency objects keyed by currency key]
function cw.currency:GetAll()
  if config.Get('cash_enabled'):Get() then
    return stored
  else
    return {}
  end
end
