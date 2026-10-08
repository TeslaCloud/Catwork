--- Adds per-player permission methods to the `Player` metatable: `Player:HasPermission` in both realms and
-- `Player:SetPermission`, `Player:GivePermission` and `Player:TakePermission` on the server.
--
-- Permissions are stored in the player's data under `permissions`, keyed by lowercased ID.

local playerMeta = FindMetaTable('Player')

--- Returns the value of one of the player's permissions.
--
-- Permissions live in the player's data under `permissions`. The ID is lowercased before the
-- lookup.
--
-- @param id [String Permission ID]
-- @return [Any The stored value (normally a Boolean), or `nil` when the permission was never set
-- or `id` is not a non-empty string]
-- @see Player:SetPermission
function playerMeta:HasPermission(id)
  id = (isstring(id) and string.lower(id)) or false

  if !id or id == '' then return end

  local permissions = self:GetData('permissions', {})

  return permissions[id]
end

if SERVER then
  --- Sets one of the player's permissions and stores it in the player's data.
  --
  -- The ID is lowercased, as `Player:HasPermission` looks it up. Does nothing when `id` is not a
  -- string.
  --
  -- @param id [String Permission ID]
  -- @param value [Any New value, normally `true` or `false`]
  -- @return [Boolean Whether the value differs from the previous one]
  -- @see Player:HasPermission
  function playerMeta:SetPermission(id, value)
    if !isstring(id) then return end

    id = string.lower(id)

    local permissions = self:GetData('permissions', {})
    local bHasChanged = (permissions[id] != value)

    permissions[id] = value

    self:SetData('permissions', permissions)

    return bHasChanged
  end

  --- Grants a permission to the player by setting it to `true`.
  --
  -- @param id [String Permission ID]
  -- @see Player:SetPermission
  function playerMeta:GivePermission(id)
    self:SetPermission(id, true)
  end

  --- Revokes a permission from the player by setting it to `false`.
  --
  -- @param id [String Permission ID]
  -- @see Player:SetPermission
  function playerMeta:TakePermission(id)
    self:SetPermission(id, false)
  end
end
