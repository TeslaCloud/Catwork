--- Defines the `cw.class` library, the registry of classes, the roles a character can take within a faction.
--
-- A class is created with `cw.class:New` and registered as a team. The library answers queries about a class (its
-- limit, model, flags or any field) and moves players between classes with `cw.class:AssignToDefault` and the
-- server-only `cw.class:Set`.

if cw.class then return end

library.New('class', cw)
local stored = {}
local buffer = {}

--- Returns the registered classes keyed by name.
--
-- @return [Map<Class> Classes keyed by name]
-- @see cw.class:GetAll
function cw.class:GetStored()
  return stored
end

--- Returns the registered classes keyed by team index.
--
-- @return [Map<Class> Classes keyed by their team index]
function cw.class:GetBuffer()
  return buffer
end

--[[ Set the __index meta function of the class. --]]
local CLASS_TABLE = { __index = CLASS_TABLE }

--- Registers the class with `cw.class:Register` under its `name`.
--
-- @return [Number The class's team index]
function CLASS_TABLE:Register()
  return cw.class:Register(self, self.name)
end

--- Creates a new, unregistered class object.
--
-- Set its fields (`color`, `factions`, `maleModel`, `femaleModel`, `limit`, `wages`, `flags`,
-- `isDefault`...) and call `CLASS_TABLE:Register` on it.
--
-- ```
-- local CLASS = cw.class:New('#Class_Citizen')
--   CLASS.color = Color(150, 125, 100, 255)
--   CLASS.factions = { FACTION_CITIZEN }
--   CLASS.isDefault = true
-- CLASS_CITIZEN = CLASS:Register()
-- ```
--
-- @param name='Unknown' [String Name of the class]
-- @return [Class The new class object]
function cw.class:New(name)
  local object = cw.core:NewMetaTable(CLASS_TABLE)
    object.name = name or 'Unknown'
  return object
end

--- Registers a class and sets it up as a team.
--
-- Fills in defaults: each gender model falls back to the other, `flags` to `'b'`, `limit` to 128,
-- `wages` to 0 and `factions` to an empty list. The team index is a short CRC of the name. On the
-- server the class `image` (if any) is added to the client download list during the first boot.
--
-- @param data [Class The class object or table]
-- @param name [String Name of the class, also used as the team name]
-- @return [Number The class's team index]
function cw.class:Register(data, name)
  if !data.maleModel then
    data.maleModel = data.femaleModel
  end

  if !data.femaleModel then
    data.femaleModel = data.maleModel
  end

  data.flags = data.flags or 'b'
  data.limit = data.limit or 128
  data.wages = data.wages or 0
  data.index = cw.core:GetShortCRC(name)
  data.name = name
  data.factions = data.factions or {}

  team.SetUp(data.index, data.name, data.color)

  buffer[data.index] = data
  stored[data.name] = data

  if SERVER and data.image and !_G['cwSharedBooted'] then
    cw.core:AddFile('materials/'..data.image..'.png')
  end

  return data.index
end

--- Returns how many players may be in a class right now.
--
-- A class's `limit` is relative to a full 128-player server, so the real limit scales with the
-- current player count. Classes with the default limit of 128 return `game.MaxPlayers()`.
--
-- @param name [Any Class name or team index]
-- @return [Number The current limit, or 0 if the class is not found]
function cw.class:GetLimit(name)
  local class = self:FindByID(name)

  if class then
    if class.limit != 128 then
      return math.ceil(class.limit / (128 / #_player.GetAll()))
    else
      return game.MaxPlayers()
    end
  else
    return 0
  end
end

--- Returns every registered class keyed by name.
--
-- @return [Map<Class> Classes keyed by name]
function cw.class:GetAll()
  return stored
end

--- Finds a class by team index or exact name.
--
-- @param identifier [Any Team index (Number or numeric String) or class name]
-- @return [Class The class, or `nil` if none matches]
function cw.class:FindByID(identifier)
  if !identifier then return end

  if tonumber(identifier) then
    return buffer[tonumber(identifier)]
  else
    return stored[identifier]
  end
end

--- Moves a player into a suitable class for their faction.
--
-- Picks a random class marked `isDefault` for the player's faction. Without one it uses the first
-- class of the faction, then the first class the player has access to. Calls `cw.class:Set`, which
-- only exists on the server.
--
-- @param player [Player The player to assign]
-- @return [Boolean Whether the class was set, String The reason it was not, or nothing if no
-- suitable class exists]
function cw.class:AssignToDefault(player)
  local defaultClasses = {}
  local faction = player:GetFaction()

  for k, v in pairs(stored) do
    if v.factions and v.isDefault and table.HasValue(v.factions, faction) then
      defaultClasses[#defaultClasses + 1] = v.index
    end
  end

  if #defaultClasses > 0 then
    local class = defaultClasses[math.random(1, #defaultClasses)]

    if class then
      return self:Set(player, class)
    end
  else
    for k, v in pairs(stored) do
      if v.factions and table.HasValue(v.factions, faction) then
        return self:Set(player, v.index)
      end
    end

    for k, v in pairs(stored) do
      if cw.core:HasObjectAccess(player, v) then
        return self:Set(player, v.index)
      end
    end
  end
end

--- Returns the model and skin a player should use in a class.
--
-- Uses the class's model for the player's gender, or the class's `GetModel(player, defaultModel)`
-- callback when it has one. Missing values fall back to the player's default model and skin 1.
--
-- @param name [Any Class name or team index]
-- @param player [Player The player the model is for]
-- @param noSubstitute=nil [Boolean Return `nil` instead of the fallback model and skin]
-- @return [String The model path, Number The skin]
function cw.class:GetAppropriateModel(name, player, noSubstitute)
  local defaultModel
  local class = self:FindByID(name)
  local model
  local skin

  if SERVER then
    defaultModel = player:GetDefaultModel()
  else
    defaultModel = player:GetNetVar('Model')
  end

  if class then
    model, skin = self:GetModelByGender(name, player:GetGender())

    if class.GetModel then
      model, skin = class:GetModel(player, defaultModel)
    end
  end

  if !model and !noSubstitute then
    model = defaultModel
  end

  if !skin and !noSubstitute then
    skin = 1
  end

  return model, skin
end

--- Returns a class's model for a gender.
--
-- Reads the class's `maleModel` or `femaleModel`, which can be a path or a `{ model, skin }`
-- table.
--
-- @param name [Any Class name or team index]
-- @param gender [String Gender name, `GENDER_MALE` or `GENDER_FEMALE`]
-- @return [String The model path, or `nil` if the class has none, Number The skin (0 when the
-- model is a plain path)]
function cw.class:GetModelByGender(name, gender)
  local model = self:Query(name, string.lower(gender)..'Model')

  if type(model) == 'table' then
    return model[1], model[2]
  else
    return model, 0
  end
end

--- Returns whether a class has at least one of the given flags.
--
-- @param name [Any Class name or team index]
-- @param flags [String Flag characters to look for]
-- @return [Boolean `true` if any flag matches, otherwise `nil`]
-- @see cw.class:HasFlags
function cw.class:HasAnyFlags(name, flags)
  local sFlagString = self:Query(name, 'flags')

  if sFlagString then
    for i = 1, #flags do
      local flag = string.utf8sub(flags, i, i)

      if string.find(sFlagString, flag) then
        return true
      end
    end
  end
end

--- Returns whether a class has every one of the given flags.
--
-- @param name [Any Class name or team index]
-- @param flags [String Flag characters that must all be present]
-- @return [Boolean Whether all flags are present, or `nil` if the class is not found]
-- @see cw.class:HasAnyFlags
function cw.class:HasFlags(name, flags)
  local sFlagString = self:Query(name, 'flags')

  if sFlagString then
    for i = 1, #flags do
      local flag = string.utf8sub(flags, i, i)

      if !string.find(sFlagString, flag) then
        return false
      end
    end

    return true
  end
end

--- Returns a field of a class.
--
-- @param name [Any Class name or team index]
-- @param key [String Field to read]
-- @param default=nil [Any Value returned when the class is not found or the field is `nil` or
-- `false`]
-- @return [Any The field's value, or `default`]
function cw.class:Query(name, key, default)
  local class = self:FindByID(name)

  if class then
    return class[key] or default
  else
    return default
  end
end

if SERVER then
  --- Moves a player into a class.
  --
  -- Sets the player's team, updates their model with the `PlayerSetModel` hook and respawns them
  -- (a light spawn that keeps weapons and ammo when they are alive and not ragdolled). Runs the
  -- `PlayerClassSet` hook (via `hook.Run`) with the player, the new and old class and the flags.
  --
  -- @param player [Player The player to move]
  -- @param name [Any Class name or team index]
  -- @param noRespawn=nil [Boolean Do not respawn the player]
  -- @param addDelay=nil [Boolean Start the `change_class_interval` cooldown before the next change]
  -- @param noModelChange=nil [Boolean Keep the player's current model]
  -- @return [Boolean Whether the class was set, String The reason it was not, as a language phrase]
  function cw.class:Set(player, name, noRespawn, addDelay, noModelChange)
    local weapons = cw.player:GetWeapons(player)
    local oldClass = self:FindByID(player:Team())
    local newClass = self:FindByID(name)
    local ammo = cw.player:GetAmmo(player, !player.cwFirstSpawn)

    if newClass then
      player:SetTeam(newClass.index)

      if !noModelChange then
        hook.Run('PlayerSetModel', player)
      end

      if !noRespawn then
        player.cwChangeClass = true

        if !player:Alive() or player.cwFirstSpawn then
          player:Spawn()
        elseif !player:IsRagdolled() then
          cw.player:LightSpawn(player, weapons, ammo)
        end
      end

      if addDelay then
        player.cwNextChangeClass = CurTime() + config.Get('change_class_interval'):Get()
      end

      hook.Run('PlayerClassSet', player, newClass, oldClass, noRespawn, addDelay, noModelChange)

      return true
    else
      return false, L('ClassNotValid')
    end
  end
end
