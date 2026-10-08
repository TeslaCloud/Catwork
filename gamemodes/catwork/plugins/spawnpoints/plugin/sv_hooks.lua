--- Server-side hooks of the Spawn Points plugin that load the saved points and move spawning players to one.
--
-- `PlayerSpawn` picks a random point for the player's class, then for their faction, then from `default`. Admins, and
-- players whose user group becomes operator or higher, are sent the points for the ESP.

--- Called after Catwork has loaded all of its entities; loads the saved spawn points.
function cwSpawnPoints:ClockworkInitPostEntity()
  self:LoadSpawnPoints()
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
    local position = nil
    local rotate = nil
    local randomSpawn = nil
    local faction = player:GetFaction()
    local class = cw.class:FindByID(player:Team())

    if class then
      if self.spawnPoints[class.name] and #self.spawnPoints[class.name] > 0 then
        randomSpawn = math.random(1, #self.spawnPoints[class.name])
        position = self.spawnPoints[class.name][randomSpawn].position
        rotate = self.spawnPoints[class.name][randomSpawn].rotate

        if position then
          player:SetPos(position + Vector(0, 0, 8))
        end

        if rotate then
          player:SetEyeAngles(Angle(0, rotate, 0))
        end
      end
    end

    if !position then
      if self.spawnPoints[faction] and #self.spawnPoints[faction] > 0 then
        randomSpawn = math.random(1, #self.spawnPoints[faction])
        position = self.spawnPoints[faction][randomSpawn].position
        rotate = self.spawnPoints[faction][randomSpawn].rotate

        if position then
          player:SetPos(position + Vector(0, 0, 8))
        end

        if rotate then
          player:SetEyeAngles(Angle(0, rotate, 0))
        end
      elseif self.spawnPoints['default'] then
        if #self.spawnPoints['default'] > 0 then
          randomSpawn = math.random(1, #self.spawnPoints['default'])
          position = self.spawnPoints['default'][randomSpawn].position
          rotate = self.spawnPoints['default'][randomSpawn].rotate

          if position then
            player:SetPos(position + Vector(0, 0, 8))
          end

          if rotate then
            player:SetEyeAngles(Angle(0, rotate, 0))
          end
        end
      end
    end

    if player:IsAdmin() then
      netstream.Start(player, 'SpawnPointESPSync', self:GetSpawnPoints())
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
    netstream.Start(player, 'SpawnPointESPSync', self:GetSpawnPoints())
  end
end
