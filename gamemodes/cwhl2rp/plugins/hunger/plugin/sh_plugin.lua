--[[
  © 2016 TeslaCloud Studios.
  Please do not use anywhere else.
--]]

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
