--- Shared part of the `cw.player` library: registration of networked player and character data types, player net vars
-- and faction rank checks.
--
-- `cw.player:AddPlayerData` and `cw.player:AddCharacterData` declare data that is networked when it changes,
-- `player.Find` finds a player by name or Steam ID, and `cw.player:CanPromote` and `cw.player:CanDemote` compare
-- faction ranks. This file creates the library, which `cl_player.lua` and `sv_player.lua` extend.

if cw.player then return end

if !plugin then include('sh_plugin.lua') end
if !config then include('sh_config.lua') end
if !cw.attribute then include('sh_attribute.lua') end
if !cw.faction then include('sh_faction.lua') end
if !cw.class then include('sh_class.lua') end
if !cw.command then include('sh_command.lua') end
if !cw.attribute then include('sh_attribute.lua') end
if !cw.option then include('sh_option.lua') end
if !cw.entity then include('sh_entity.lua') end
if !item then include('sh_item.lua') end
if !cw.inventory then include('sh_inventory.lua') end

library.New('player', cw)

local playerData = cw.player.playerData or {}
local characterData = cw.player.characterData or {}
cw.player.playerData = playerData
cw.player.characterData = characterData

--- Returns every player data type registered with `cw.player:AddPlayerData`.
--
-- @return [Map<Map> Data type definitions keyed by name, each with `default`, `nwType`, `callback`
-- and `playerOnly` keys]
function cw.player:GetPlayerDataTable()
  return playerData
end

--- Returns every character data type registered with `cw.player:AddCharacterData`.
--
-- @return [Map<Map> Data type definitions keyed by name, each with `default`, `nwType`, `callback`
-- and `playerOnly` keys]
function cw.player:GetCharacterDataTable()
  return characterData
end

--- Returns the definition of a registered player data type.
--
-- @param key [String Name of the data type]
-- @return [Map The definition with `default`, `nwType`, `callback` and `playerOnly` keys, or `nil`
-- if it is not registered]
function cw.player:GetPlayerData(key)
  return playerData[key]
end

--- Returns the definition of a registered character data type.
--
-- This is the registration, not a character's value; use `Player:GetCharacterData` for that.
--
-- @param key [String Name of the data type]
-- @return [Map The definition with `default`, `nwType`, `callback` and `playerOnly` keys, or `nil`
-- if it is not registered]
function cw.player:GetCharacterData(key)
  return characterData[key]
end

--- Sets a networked variable on a player.
--
-- Does nothing on the client or for invalid players.
--
-- @param player [Player The player to set the variable on]
-- @param key [String Name of the variable]
-- @param value [Any New value]
-- @alias [cw.player.SetSharedVar]
-- @see cw.player:GetNetVar
function cw.player:SetNetVar(player, key, value)
  if SERVER then
    if IsValid(player) then
      player:SetNetVar(key, value)
    end
  end
end

--- Returns a networked variable of a player.
--
-- @param player [Player The player to read the variable from]
-- @param key [String Name of the variable]
-- @return [Any The value, or `nil` for invalid players or unset variables]
-- @alias [cw.player.GetSharedVar]
-- @see cw.player:SetNetVar
function cw.player:GetNetVar(player, key)
  if IsValid(player) then
    return player:GetNetVar(key)
  end
end

cw.player.GetSharedVar = cw.player.GetNetVar
cw.player.SetSharedVar = cw.player.SetNetVar

--- Finds an initialized player by part of their name or by Steam ID.
--
-- The name is matched as plain text anywhere in the player's name. A player whose whole name or
-- Steam ID matches wins; otherwise the first partial match does. Passing a valid player returns
-- that player.
--
-- @param name [String Part of the player's name or their Steam ID, or a Player]
-- @param bCaseSensitive=nil [Boolean Match the name case-sensitively]
-- @return [Player The player, or `nil` if nobody matches or `name` is empty]
function player.Find(name, bCaseSensitive)
  if name == nil or name == '' then return end
  if !isstring(name) then return (IsValid(name) and name) or nil end

  local searchName = (bCaseSensitive and name) or name:utf8lower()
  local partialMatch

  for k, v in ipairs(_player.GetAll()) do
    if !v:HasInitialized() then continue end

    local plyName = v:Name(true)

    if !bCaseSensitive then
      plyName = plyName:utf8lower()
    end

    if plyName == searchName or v:SteamID() == name then
      return v
    elseif !partialMatch and plyName:find(searchName, 1, true) then
      partialMatch = v
    end
  end

  return partialMatch
end

--- Registers a character data type that is networked when it changes.
--
-- ```
-- cw.player:AddCharacterData('radlevel', NWTYPE_NUMBER, 0, true)
-- ```
--
-- @param name [String Name of the data]
-- @param nwType [Number Type of the value, one of the `NWTYPE_*` enums]
-- @param default [Any Default value]
-- @param playerOnly=nil [Boolean Whether the data is meant to be networked to its player only]
-- @param callback=nil [Function Called as `callback(player, value)` before networking; returns the
-- value to send]
-- @see cw.player:AddPlayerData
function cw.player:AddCharacterData(name, nwType, default, playerOnly, callback)
  characterData[name] = {
    default = default,
    nwType = nwType,
    callback = callback,
    playerOnly = playerOnly
  }
end

--- Registers a player data type that is networked when it changes.
--
-- @param name [String Name of the data]
-- @param nwType [Number Type of the value, one of the `NWTYPE_*` enums]
-- @param default [Any Default value]
-- @param playerOnly=nil [Boolean Whether the data is meant to be networked to its player only]
-- @param callback=nil [Function Called as `callback(player, value)` before networking; returns the
-- value to send]
-- @see cw.player:AddCharacterData
function cw.player:AddPlayerData(name, nwType, default, playerOnly, callback)
  playerData[name] = {
    default = default,
    nwType = nwType,
    callback = callback,
    playerOnly = playerOnly
  }
end

--- Returns a player's rank within their faction.
--
-- Reads the `factionrank` character data, from `character` when one is given.
--
-- @param player [Player The player whose rank is read; ignored when `character` is given]
-- @param character=nil [Character A character table to read the rank from instead]
-- @return [String The rank's name, or nothing if the faction has no ranks, Map The rank table from
-- the faction's `ranks`, or `nil` if the rank does not exist]
function cw.player:GetFactionRank(player, character)
  if character then
    local faction = faction.FindByID(character.faction)

    if faction and istable(faction.ranks) then
      local rank

      for k, v in pairs(faction.ranks) do
        if k == character.data['factionrank'] then
          rank = v
          break
        end
      end

      return character.data['factionrank'], rank
    end
  else
    local faction = faction.FindByID(player:GetFaction())

    if faction and istable(faction.ranks) then
      local rank

      for k, v in pairs(faction.ranks) do
        if k == player:GetCharacterData('factionrank') then
          rank = v
          break
        end
      end

      return player:GetCharacterData('factionrank'), rank
    end
  end
end

--- Returns whether a player's rank allows them to promote a target.
--
-- The player's rank must have a `canPromote` position, which must be less than or equal to the
-- target's rank position, and the target must not already hold the highest rank.
--
-- @param player [Player The player doing the promotion]
-- @param target [Player The player who would be promoted]
-- @return [Boolean Whether the promotion is allowed, or `nil` when the player cannot promote]
-- @see cw.player:CanDemote
function cw.player:CanPromote(player, target)
  local stringRank, rank = self:GetFactionRank(player)

  if rank and rank.canPromote then
    local stringTargetRank, targetRank = self:GetFactionRank(target)
    local highestRank, rankTable = faction.GetHighestRank(player:GetFaction())

    if targetRank and targetRank.position and rankTable and targetRank.position != rankTable.position then
      return (rank.canPromote <= targetRank.position)
    end
  end
end

--- Returns whether a player's rank allows them to demote a target.
--
-- The player's rank must have a `canDemote` position, which must be less than or equal to the
-- target's rank position, and the target must not already hold the lowest rank.
--
-- @param player [Player The player doing the demotion]
-- @param target [Player The player who would be demoted]
-- @return [Boolean Whether the demotion is allowed, or `nil` when the player cannot demote]
-- @see cw.player:CanPromote
function cw.player:CanDemote(player, target)
  local stringRank, rank = self:GetFactionRank(player)

  if rank and rank.canDemote then
    local stringTargetRank, targetRank = self:GetFactionRank(target)
    local lowestRank, rankTable = faction.GetLowestRank(player:GetFaction())

    if targetRank and targetRank.position and rankTable and targetRank.position != rankTable.position then
      return (rank.canDemote <= targetRank.position)
    end
  end
end
