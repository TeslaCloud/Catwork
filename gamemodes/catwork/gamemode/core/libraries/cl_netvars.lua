--- Client side of the global `netvars` library, which keeps the networked variables received from the server and reads
-- them back with `Entity:GetNetVar` and `netvars.GetNetVar`.
--
-- Values arrive over the `nVar`, `nLcl`, `nDel` and `gVar` Cable messages and are stored by entity index.
-- `Player:GetLocalVar` is the same function as `Entity:GetNetVar`, so the local player's private variables are read
-- the same way.

if netvars then return end

library.New('netvars', _G)

local entityMeta = FindMetaTable('Entity')
local playerMeta = FindMetaTable('Player')

local stored = {}
local globals = {}

cw.transfer:Receive('nVar', function(index, key, value)
  stored[index] = stored[index] or {}
  stored[index][key] = value
end)

cable.receive('nDel', function(index)
  stored[index] = nil
end)

cw.transfer:Receive('nLcl', function(key, value)
  local index = LocalPlayer():EntIndex()

  stored[index] = stored[index] or {}
  stored[index][key] = value
end)

cw.transfer:Receive('gVar', function(key, value)
  globals[key] = value
end)

--- Returns the value of a global networked variable received from the server.
-- @param key [String Name of the variable]
-- @param default=nil [Any Value to return if the variable is `nil` or `false`]
-- @return [Any The value, or `default`]
function netvars.GetNetVar(key, default)
  local value = globals[key]

  return value != nil and value or default
end

--- Returns the value of a networked variable on the entity, as received from the server.
--
-- For the local player this also returns the variables set with
-- `Player:SetLocalVar`.
-- @param key [String Name of the variable]
-- @param default=nil [Any Value to return if the variable is not set]
-- @return [Any The value, or `default`]
-- @alias [Player.GetNetVar]
-- @alias [Player.GetLocalVar]
function entityMeta:GetNetVar(key, default)
  local vars = stored[self:EntIndex()]

  if vars then
    local value = vars[key]

    if value != nil then
      return value
    end
  end

  return default
end

playerMeta.GetNetVar = entityMeta.GetNetVar
playerMeta.GetLocalVar = entityMeta.GetNetVar
