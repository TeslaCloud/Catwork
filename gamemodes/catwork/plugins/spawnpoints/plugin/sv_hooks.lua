--- Server-side hooks of the Spawn Points plugin that load the saved points and move spawning players to one.
--
-- `PlayerSpawn` picks a random point for the player's class, then for their faction, then from `default`. Admins, and
-- players whose user group becomes operator or higher, are sent the points for the ESP.

--- Called after Catwork has loaded all of its entities; loads the saved spawn points.
function cwSpawnPoints:ClockworkInitPostEntity()
  self:LoadSpawnPoints()
end

-- Moves a player to a random point of a list; returns whether the list had a usable point.
local function MoveToRandomPoint(player, spawnPoints)
  local spawnPoint = spawnPoints and #spawnPoints > 0 and spawnPoints[math.random(1, #spawnPoints)]

  if !spawnPoint or !spawnPoint.position then
    return false
  end

  player:SetPos(spawnPoint.position + Vector(0, 0, 8))

  if spawnPoint.rotate then
    player:SetEyeAngles(Angle(0, spawnPoint.rotate, 0))
  end

  return true
end

--- Called when a player spawns; moves them to a random spawn point for their class, faction or the default.
--
-- Class spawn points take priority over faction ones; the default set is used only when the faction has
-- none. The player is placed 8 units above the point and turned to its `rotate` yaw. Admins also receive
-- the spawn point ESP data.
--
-- @param player [Player The player who spawned]
function cwSpawnPoints:PlayerSpawn(player)
  if player:HasInitialized() then
    local factionPoints = self.spawnPoints[player:GetFaction()]
    local class = cw.class:FindByID(player:Team())

    if !class or !MoveToRandomPoint(player, self.spawnPoints[class.name]) then
      if factionPoints and #factionPoints > 0 then
        MoveToRandomPoint(player, factionPoints)
      else
        MoveToRandomPoint(player, self.spawnPoints['default'])
      end
    end

    if player:IsAdmin() then
      cable.send(player, 'SpawnPointESPSync', self:GetSpawnPoints())
    end
  end
end

local groupCheck = {
  owner = true,
  superadmin = true,
  admin = true,
  operator = true
}

--- Called when a player's user group is set; sends the spawn point ESP data to operators and above.
--
-- @param player [Player The player whose group was set]
-- @param usergroup [String The new user group]
function cwSpawnPoints:OnPlayerUserGroupSet(player, usergroup)
  if groupCheck[string.lower(usergroup)] then
    cable.send(player, 'SpawnPointESPSync', self:GetSpawnPoints())
  end
end
