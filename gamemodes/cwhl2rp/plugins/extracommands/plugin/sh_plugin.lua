--[[
  © 2016 TeslaCloud Studios.
  Feel free to use, edit or share the plugin, but
  do not re-distribute without the permission of it's author.
--]]

if SERVER then
  --- Called just after a player spawns; reapplies the character's custom bodygroups and skin.
  --
  -- The values come from the `CustomBodyGroup` and `CustomSkin` character data set by the
  -- `CharSetBodyGroup` and `CharSetSkin` commands.
  -- @param player [Player The player who spawned]
  -- @param lightSpawn [Boolean Whether this was a light spawn]
  -- @param changeClass [Boolean Whether the player spawned because their class changed]
  -- @param firstSpawn [Boolean Whether this is the character's first spawn]
  function PLUGIN:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
    local bodyGroup = player:GetCharacterData('CustomBodyGroup')
    local skin = player:GetCharacterData('CustomSkin')

    if istable(bodyGroup) then
      for k, v in pairs(bodyGroup) do
        player:SetBodygroup(k, v)
      end
    end

    if skin then
      player:SetSkin(skin)
    end
  end

  --- Called after a player gets up from a ragdoll; reapplies the character's custom bodygroups.
  -- @param player [Player The player who was unragdolled]
  -- @param state [Number The ragdoll state being set, a `RAGDOLL_*` value such as `RAGDOLL_RESET`]
  -- @param ragdollTable [Map The player's ragdoll data]
  function PLUGIN:PlayerUnragdolled(player, state, ragdollTable)
    local bodyGroup = player:GetCharacterData('CustomBodyGroup')

    if istable(bodyGroup) then
      for k, v in pairs(bodyGroup) do
        player:SetBodygroup(k, v)
      end
    end
  end
end
