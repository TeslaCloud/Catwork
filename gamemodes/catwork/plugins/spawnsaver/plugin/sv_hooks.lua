--- Server-side hooks of the Spawn Saver plugin that save a character's position when it unloads and restore it on the
-- next spawn.
--
-- The position, eye angles and map are kept in the `SpawnPoint` character data, written on character unload and before
-- a map change, and used once on the same map. Other plugins can veto both with the `ShouldSavePlayerSpawn` hook.

--- Called when a player's character unloads; saves where they were standing to the `SpawnPoint` character data.
--
-- Only saves living players while the `spawn_where_left` config is on and the `ShouldSavePlayerSpawn`
-- hook does not return false.
--
-- @param player [Player The player whose character unloaded]
function cwSpawnSaver:PlayerCharacterUnloaded(player)
  if config.Get('spawn_where_left'):Get() and hook.Run('ShouldSavePlayerSpawn', player) != false
  and player:Alive() then
    local position = player:GetPos()
    local posTable = {
      map = game.GetMap(),
      x = position.x,
      y = position.y,
      z = position.z,
      angles = player:EyeAngles()
    }

    player:SetCharacterData('SpawnPoint', posTable)
  end
end

--- Called before the map changes; saves every player's position as if their character unloaded.
--
-- @param newMap [String The map being changed to]
function cwSpawnSaver:OnMapChange(newMap)
  for k, v in ipairs(_player.GetAll()) do
    self:PlayerCharacterUnloaded(v)
  end
end

--- Called after a player spawns; moves them back to their saved position on the same map and clears it.
--
-- Light spawns are ignored, as are players for whom the `ShouldSavePlayerSpawn` hook returns false.
--
-- @param player [Player The player who spawned]
-- @param bLightSpawn [Boolean Whether this is a light spawn that keeps the player's state]
-- @param bChangeClass [Boolean Whether the spawn comes from a class change]
-- @param bFirstSpawn [Boolean Whether this is the character's first spawn]
function cwSpawnSaver:PostPlayerSpawn(player, bLightSpawn, bChangeClass, bFirstSpawn)
  if !bLightSpawn and hook.Run('ShouldSavePlayerSpawn', player) != false then
    local spawnPos = player:GetCharacterData('SpawnPoint')

    if spawnPos and config.GetVal('spawn_where_left') then
      if spawnPos.map == game.GetMap() then
        player:SetPos(Vector(spawnPos.x, spawnPos.y, spawnPos.z))
        player:SetEyeAngles(spawnPos.angles)
        player:SetCharacterData('SpawnPoint', nil)
      end
    end
  end
end
