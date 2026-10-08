--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

--- Called when the spawn saver wants to store where a player left; skipped for characters with a custom spawn.
-- @param player [Player The player whose position would be saved]
-- @return [Boolean `false` when the character has a custom spawn, otherwise `true`]
function cwCustomSpawn:ShouldSavePlayerSpawn(player)
  if player:GetCharacterData('CustomSpawn') then
    return false
  end

  return true
end

--- Called just after a player spawns; moves the player to their character's custom spawn point.
--
-- Only applies on full spawns and when the custom spawn was set on the current map; the saved
-- eye angles are restored too.
-- @param player [Player The player who spawned]
-- @param bLightSpawn [Boolean Whether this was a light spawn that keeps position and loadout]
-- @param bChangeClass [Boolean Whether the player spawned because their class changed]
-- @param bFirstSpawn [Boolean Whether this is the character's first spawn]
function cwCustomSpawn:PostPlayerSpawn(player, bLightSpawn, bChangeClass, bFirstSpawn)
  if !bLightSpawn then
    local spawnPos = player:GetCharacterData('CustomSpawn')

    if spawnPos then
      if spawnPos.map == game.GetMap() then
        player:SetPos(Vector(spawnPos.x, spawnPos.y, spawnPos.z))

        if spawnPos.angles then
          player:SetEyeAngles(spawnPos.angles)
        end
      end
    end
  end
end
