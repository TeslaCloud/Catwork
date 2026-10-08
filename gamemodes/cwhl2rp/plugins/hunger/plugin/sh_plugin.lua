--- Main file of the Hunger plugin, which makes players need food, water and sleep; includes the plugin's server and
-- client files and defines the shared `PlayerHasNeeds` hook.
--
-- `PlayerHasNeeds` gives needs to everyone but the Combine, except that Civil Protection (`FACTION_MPF`) have them
-- too.

util.Include('sv_plugin.lua')
util.Include('sv_hooks.lua')
util.Include('cl_plugin.lua')
util.Include('cl_hooks.lua')

--- Called to check whether a player gets hungry, thirsty and tired.
--
-- Everyone but the Combine has needs; Civil Protection have them too.
--
-- @param player [Player The player to check]
-- @return [Boolean Whether the player has needs]
function PLUGIN:PlayerHasNeeds(player)
  return !player:IsCombine() or player:GetFaction() == FACTION_MPF
end
