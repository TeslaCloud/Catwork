--- Server-side hooks of the Karma plugin that start characters without `karma` data at 0 and network a character's
-- karma when the player spawns.

--- Called when a character's data is restored; starts characters without karma at 0.
-- @param player [Player The player whose character is loading]
-- @param data [Map The character data; `karma` is set in place]
function cwKarma:PlayerRestoreCharacterData(player, data)
  if !data['karma'] then
    data['karma'] = 0
  end
end

--- Called just after a player spawns; networks the character's karma to clients.
-- @param player [Player The player who spawned]
-- @param lightSpawn [Boolean Whether this was a light spawn]
-- @param changeClass [Boolean Whether the player spawned because their class changed]
-- @param firstSpawn [Boolean Whether this is the character's first spawn]
function cwKarma:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
  player:SetNetVar('karma', player:GetCharacterData('karma', 0))
end
