-- This code is taken from NutScript.
-- NutScript and code license are found here:
-- https://github.com/Chessnut/NutScript

if netvars then return end

library.New('netvars', _G)

local entityMeta = FindMetaTable('Entity')
local playerMeta = FindMetaTable('Player')

local stored = {}
local globals = {}

-- Check if there is an attempt to send a function. Can't send those.
local function CheckBadType(name, object)
  local objectType = type(object)

  if objectType == 'function' then
    ErrorNoHalt("Net var '"..name.."' contains a bad object type!\n")

    return true
  elseif objectType == 'table' then
    for k, v in pairs(object) do
      -- Check both the key and the value for tables, and has recursion.
      if CheckBadType(name, k) or CheckBadType(name, v) then
        return true
      end
    end
  end
end

--- Sets a global networked variable and sends it to clients.
--
-- Does nothing if the value is unchanged or contains a function (which prints
-- an error). Players who join later receive it through `Player:SyncVars`.
-- @param key [String Name of the variable]
-- @param value [Any The new value; must not be or contain a function]
-- @param receiver=nil [Player A player or list of players to send the change to; `nil` sends it to everyone]
-- @see netvars.GetNetVar
function netvars.SetNetVar(key, value, receiver)
  if CheckBadType(key, value) then return end
  if netvars.GetNetVar(key) == value then return end
  if globals[key] == value then return end

  globals[key] = value
  netstream.Start(receiver, 'gVar', key, value)
end

--- Returns whether two values are equal, comparing tables by content.
-- @param old [Any The first value]
-- @param new [Any The second value]
-- @return [Boolean Whether the values are equal, String `'table'` when both values are tables]
function netvars.AreEqual(old, new)
  if istable(old) and istable(new) then
    return cw.core:AreTablesEqual(old, new), 'table'
  elseif old == new then
    return true
  end

  return false
end

--- Sends every entity and global networked variable to the player.
-- @warning [Internal] Called from the `PlayerInitialSpawn` hook.
function playerMeta:SyncVars()
  for entity, data in pairs(stored) do
    if IsValid(entity) then
      for k, v in pairs(data) do
        netstream.Start(self, 'nVar', entity:EntIndex(), k, v)
      end
    end
  end

  for k, v in pairs(globals) do
    netstream.Start(self, 'gVar', k, v)
  end
end

--- Sends the entity's current value of a networked variable to clients.
-- @param key [String Name of the variable]
-- @param receiver=nil [Player A player or list of players to send it to; `nil` sends it to everyone]
function entityMeta:SendNetVar(key, receiver)
  netstream.Heavy(receiver, 'nVar', self:EntIndex(), key, stored[self] and stored[self][key])
end

--- Removes all networked variables of the entity on the server and on clients.
--
-- Called automatically when the entity is removed.
-- @param receiver=nil [Player A player or list of players to tell; `nil` tells everyone]
function entityMeta:ClearNetVars(receiver)
  stored[self] = nil
  netstream.Start(receiver, 'nDel', self:EntIndex())
end

--- Sets a networked variable on the entity and sends it to clients.
--
-- Does nothing if a non-table value is unchanged, or if the value contains a
-- function (which prints an error). Tables are always resent.
--
-- ```
-- entity:SetNetVar('Locked', true)
-- ```
--
-- @param key [String Name of the variable]
-- @param value [Any The new value; must not be or contain a function]
-- @param receiver=nil [Player A player or list of players to send the change to; `nil` sends it to everyone]
-- @see Entity:GetNetVar
function entityMeta:SetNetVar(key, value, receiver)
  if CheckBadType(key, value) then return end
  if !istable(value) and value == self:GetNetVar(key) then return end

  stored[self] = stored[self] or {}
  stored[self][key] = value

  self:SendNetVar(key, receiver)
end

--- Returns the value of a networked variable on the entity.
--
-- On the server this also returns local variables set with `Player:SetLocalVar`.
-- @param key [String Name of the variable]
-- @param default=nil [Any Value to return if the variable is not set]
-- @return [Any The value, or `default`]
-- @alias [Player.GetLocalVar]
function entityMeta:GetNetVar(key, default)
  if stored[self] and stored[self][key] != nil then
    return stored[self][key]
  end

  return default
end

--- Sets a networked variable on the player that is only sent to that player.
--
-- Does nothing if the value contains a function (which prints an error). The
-- value is always sent, even if it is unchanged.
-- @param key [String Name of the variable]
-- @param value [Any The new value; must not be or contain a function]
-- @see Player:GetLocalVar
function playerMeta:SetLocalVar(key, value)
  if CheckBadType(key, value) then return end

  stored[self] = stored[self] or {}
  stored[self][key] = value

  netstream.Start(self, 'nLcl', key, value)
end

playerMeta.GetLocalVar = entityMeta.GetNetVar

--- Returns the value of a global networked variable.
-- @param key [String Name of the variable]
-- @param default=nil [Any Value to return if the variable is `nil` or `false`]
-- @return [Any The value, or `default`]
-- @see netvars.SetNetVar
function netvars.GetNetVar(key, default)
  local value = globals[key]

  return value != nil and value or default
end

hook.Add('EntityRemoved', 'nCleanUp', function(entity)
  entity:ClearNetVars()
end)

hook.Add('PlayerInitialSpawn', 'nSync', function(client)
  client:SyncVars()
end)
