--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

library.New 'faction'

local stored = faction.stored or {}
faction.stored = stored

local buffer = faction.buffer or {}
faction.buffer = buffer

--- Returns the registered factions keyed by name.
--
-- @return [Map<Faction> Factions keyed by name]
-- @see faction.GetAll
function faction.GetStored()
  return stored
end

--- Returns the registered factions keyed by numeric index.
--
-- @return [Map<Faction> Factions keyed by the CRC-based index from `cw.core:GetShortCRC`]
function faction.GetBuffer()
  return buffer
end

FACTION_CITIZENS_FEMALE = {
  'models/humans/group01/female_01.mdl',
  'models/humans/group01/female_02.mdl',
  'models/humans/group01/female_03.mdl',
  'models/humans/group01/female_04.mdl',
  'models/humans/group01/female_06.mdl',
  'models/humans/group01/female_07.mdl'
}

FACTION_CITIZENS_MALE = {
  'models/humans/group01/male_01.mdl',
  'models/humans/group01/male_02.mdl',
  'models/humans/group01/male_03.mdl',
  'models/humans/group01/male_04.mdl',
  'models/humans/group01/male_05.mdl',
  'models/humans/group01/male_06.mdl',
  'models/humans/group01/male_07.mdl',
  'models/humans/group01/male_08.mdl',
  'models/humans/group01/male_09.mdl'
}

--[[ Set the __index meta function of the class. --]]
local CLASS_TABLE = { __index = CLASS_TABLE }

--- Registers the faction with `faction.Register` under its `name`.
--
-- @return [String The faction's name]
function CLASS_TABLE:Register()
  return faction.Register(self, self.name)
end

--- Creates a new, unregistered faction object.
--
-- Set its fields (`models`, `whitelist`, `material`, `limit`, `maximum`, `singleGender`,
-- `ranks`...) and callbacks, then call `CLASS_TABLE:Register` on it.
--
-- ```
-- local FACTION = faction.New('#Faction_MPF')
--
-- FACTION.whitelist = true
-- FACTION.material = 'halfliferp/factions/mpf'
--
-- FACTION_MPF = FACTION:Register()
-- ```
--
-- @param name='Unknown' [String Name of the faction, can be a language phrase]
-- @return [Faction The new faction object]
function faction.New(name)
  local object = cw.core:NewMetaTable(CLASS_TABLE)
    object.name = name or 'Unknown'
  return object
end

--- Registers a faction.
--
-- Missing `models.male` and `models.female` lists default to the Half-Life 2 citizen models,
-- `limit` defaults to 128 and the index is a short CRC of `name`. On the server, during the first
-- boot, the faction's models and its `material` PNG are added to the client download list.
--
-- @param data [Faction The faction object or table]
-- @param name [String Name of the faction, used when `data.name` is not set]
-- @return [String The faction's name]
function faction.Register(data, name)
  if data.models then
    data.models.female = data.models.female or FACTION_CITIZENS_FEMALE
    data.models.male = data.models.male or FACTION_CITIZENS_MALE
  else
    data.models = {
      female = FACTION_CITIZENS_FEMALE,
      male = FACTION_CITIZENS_MALE
    }
  end

  data.limit = data.limit or 128
  data.index = cw.core:GetShortCRC(name)
  data.name = data.name or name

  buffer[data.index] = data
  stored[data.name] = data

  if SERVER and !_G['cwSharedBooted'] then
    if data.models then
      for k, v in pairs(data.models.female) do
        cw.core:AddFile(v)
      end

      for k, v in pairs(data.models.male) do
        cw.core:AddFile(v)
      end
    end

    if data.material then
      cw.core:AddFile('materials/'..data.material..'.png')
    end
  end

  return data.name
end

--- Returns how many players may be in a faction right now.
--
-- A faction's `limit` is relative to a full 128-player server, so the real limit scales with the
-- current player count. Factions with the default limit of 128 return `game.MaxPlayers()`.
--
-- @param name [Any Faction name, index or part of the name]
-- @return [Number The current limit, or 0 if the faction is not found]
function faction.GetLimit(name)
  local faction = faction.FindByID(name)

  if faction then
    if faction.limit != 128 then
      return math.ceil(faction.limit / (128 / #_player.GetAll()))
    else
      return game.MaxPlayers()
    end
  else
    return 0
  end
end

--- Returns whether a gender may be chosen for a faction.
--
-- Factions with a `singleGender` only accept that gender.
--
-- @param faction [Any Faction name, index or part of the name]
-- @param gender [String `GENDER_MALE` or `GENDER_FEMALE`]
-- @return [Boolean `true` if the gender is valid, otherwise `nil`]
function faction.IsGenderValid(faction, gender)
  local factionTable = _faction.FindByID(faction)

  if factionTable and (gender == GENDER_MALE or gender == GENDER_FEMALE) then
    if !factionTable.singleGender or gender == factionTable.singleGender then
      return true
    end
  end
end

--- Returns whether a model is one of a faction's models for a gender.
--
-- @param faction [Any Faction name, index or part of the name]
-- @param gender [String `GENDER_MALE` or `GENDER_FEMALE`]
-- @param model [String Model path]
-- @return [Boolean `true` if the model is valid, otherwise `nil`]
function faction.IsModelValid(faction, gender, model)
  if gender and model then
    local factionTable = _faction.FindByID(faction)

    if factionTable
    and table.HasValue(factionTable.models[string.lower(gender)], model) then
      return true
    end
  end
end

--- Finds a faction by index, exact name or part of its name.
--
-- Partial matches are case-insensitive Lua patterns; the faction with the shortest matching name
-- wins.
--
-- @param identifier [Any Faction index (Number or numeric String), name or part of the name]
-- @return [Faction The faction, or `nil` if none matches]
function faction.FindByID(identifier)
  if !identifier then return end

  if tonumber(identifier) then
    return buffer[tonumber(identifier)]
  elseif stored[identifier] then
    return stored[identifier]
  else
    local shortest = nil
    local shortestLength = math.huge
    local lowerIdentifier = string.lower(identifier)

    for k, v in pairs(faction.GetAll())do
      if string.find(string.lower(k), lowerIdentifier)
        and string.utf8len(k) < shortestLength then
        shortestLength = string.utf8len(k)
        shortest = v
      end
    end

    return shortest
  end
end

--- Returns every registered faction keyed by name.
--
-- @return [Map<Faction> Factions keyed by name]
function faction.GetAll()
  return stored
end

--- Returns every initialized player in a faction.
--
-- @param faction [String Faction name, as returned by `Player:GetFaction`]
-- @return [List<Player> The players in the faction]
function faction.GetPlayers(faction)
  local players = {}

  for k, v in ipairs(_player.GetAll()) do
    if v:HasInitialized() then
      if v:GetFaction() == faction then
        players[#players + 1] = v
      end
    end
  end

  return players
end

--- Returns the faction's highest rank, the one with the lowest `position`.
--
-- Errors if the faction cannot be found.
--
-- @param factionID [Any Faction name, index or part of the name]
-- @return [String The rank's name, or `nil` if the faction has no ranks, Map The rank table]
-- @see faction.GetLowestRank
function faction.GetHighestRank(factionID)
  local faction = _faction.FindByID(factionID)

  if istable(faction.ranks) then
    local lowestPos
    local highestRank
    local rankTable

    for k, v in pairs(faction.ranks) do
      if !lowestPos then
        lowestPos = v.position
        rankTable = v
        highestRank = k
      else
        if v.position then
          if math.min(lowestPos, v.position) == v.position then
            highestRank = k
            rankTable = v
            lowestPos = v.position
          end
        end
      end
    end

    return highestRank, rankTable
  end
end

--- Returns the faction's lowest rank, the one with the highest `position`.
--
-- Errors if the faction cannot be found.
--
-- @param factionID [Any Faction name, index or part of the name]
-- @return [String The rank's name, or `nil` if the faction has no ranks, Map The rank table]
-- @see faction.GetHighestRank
function faction.GetLowestRank(factionID)
  local faction = _faction.FindByID(factionID)

  if istable(faction.ranks) then
    local highestPos
    local lowestRank
    local rankTable

    for k, v in pairs(faction.ranks) do
      if !highestPos then
        highestPos = v.position
        lowestRank = k
        rankTable = v
      else
        if v.position then
          if math.max(highestPos, v.position) == v.position then
            lowestRank = k
            rankTable = v
            highestPos = v.position
          end
        end
      end
    end

    return lowestRank, rankTable
  end
end

--- Returns the rank one step above a rank, the one whose `position` is one lower.
--
-- Reads `ranks` from the `faction` library table instead of the faction found by `factionID`, so
-- it currently always returns nothing.
--
-- @param factionID [Any Faction name, index or part of the name]
-- @param rank [Map The current rank table]
-- @return [String The higher rank's name, Map The higher rank table]
-- @see faction.GetLowerRank
function faction.GetHigherRank(factionID, rank)
  local highestRank, rankTable = faction.GetHighestRank(factionID)

  factionID = faction.FindByID(factionID)

  if istable(faction.ranks) and istable(rank) and rank.position and rank.position != rankTable.position then
    for k, v in pairs(faction.ranks) do
      if v.position == (rank.position - 1) then
        return k, v
      end
    end
  end
end

--- Returns the rank one step below a rank, the one whose `position` is one higher.
--
-- @param factionID [Any Faction name, index or part of the name]
-- @param rank [Map The current rank table]
-- @return [String The lower rank's name, or `nil` if `rank` is already the lowest, Map The lower
-- rank table]
-- @see faction.GetHigherRank
function faction.GetLowerRank(factionID, rank)
  local lowestRank, rankTable = faction.GetLowestRank(factionID)

  factionID = faction.FindByID(factionID)

  if istable(factionID.ranks) and istable(rank) and rank.position and rank.position != rankTable.position then
    for k, v in pairs(factionID.ranks) do
      if v.position == (rank.position + 1) then
        return k, v
      end
    end
  end
end

--- Returns the faction's default rank, the first rank with `default` set.
--
-- Errors if the faction cannot be found.
--
-- @param factionID [Any Faction name, index or part of the name]
-- @return [String The rank's name, or `nil` if there is no default rank, Map The rank table]
function faction.GetDefaultRank(factionID)
  local faction = faction.FindByID(factionID)

  if istable(faction.ranks) then
    local lowestPos
    local highestRank

    for k, v in pairs(faction.ranks) do
      if v.default then
        return k, v
      end
    end
  end
end

if SERVER then
  --- Returns whether a player already has the maximum number of characters in a faction.
  --
  -- Only factions with a `maximum` field limit characters.
  --
  -- @param player [Player The player whose characters are counted]
  -- @param factionID [Any Faction name, index or part of the name]
  -- @return [Boolean `true` if the maximum is reached, otherwise `nil`]
  function faction.HasReachedMaximum(player, factionID)
    local factionTable = faction.FindByID(factionID)
    local characters = player:GetCharacters()

    if factionTable and factionTable.maximum then
      local totalCharacters = 0

      for k, v in pairs(characters) do
        if v.faction == factionTable.name then
          totalCharacters = totalCharacters + 1
        end
      end

      if totalCharacters >= factionTable.maximum then
        return true
      end
    end
  end
else
  --- Returns whether the local player already has the maximum number of characters in a faction.
  --
  -- Client version of the server's `faction.HasReachedMaximum`, counting the characters in
  -- `cw.character:GetAll`.
  --
  -- @param factionID [Any Faction name, index or part of the name]
  -- @return [Boolean `true` if the maximum is reached, otherwise `nil`]
  function faction.HasReachedMaximum(factionID)
    local factionTable = faction.FindByID(factionID)
    local characters = cw.character:GetAll()

    if factionTable and factionTable.maximum then
      local totalCharacters = 0

      for k, v in pairs(characters) do
        if v.faction == factionTable.name then
          totalCharacters = totalCharacters + 1
        end
      end

      if totalCharacters >= factionTable.maximum then
        return true
      end
    end
  end
end

_faction = faction
