--- Main file of the Extra Commands plugin, which adds several commands for server administration; defines the
-- server-side hooks that reapply a character's custom bodygroups and skin.
--
-- `PostPlayerSpawn` restores the `CustomBodyGroup` and `CustomSkin` character data set by `/CharSetBodyGroup` and
-- `/CharSetSkin`, and `PlayerUnragdolled` restores the bodygroups when the player gets up from a ragdoll.

if SERVER then
  --- Applies the bodygroups saved in a character's `CustomBodyGroup` data to the player.
  -- @param player [Player The player to update]
  local function ApplyCustomBodyGroups(player)
    local bodyGroups = player:GetCharacterData('CustomBodyGroup')

    if !istable(bodyGroups) then return end

    for k, v in pairs(bodyGroups) do
      local bodyGroup, value = tonumber(k), tonumber(v)

      if bodyGroup and value then
        player:SetBodygroup(bodyGroup, value)
      end
    end
  end

  --- Called just after a player spawns; reapplies the character's custom bodygroups and skin.
  --
  -- The values come from the `CustomBodyGroup` and `CustomSkin` character data set by the
  -- `CharSetBodyGroup` and `CharSetSkin` commands.
  -- @param player [Player The player who spawned]
  -- @param lightSpawn [Boolean Whether this was a light spawn]
  -- @param changeClass [Boolean Whether the player spawned because their class changed]
  -- @param firstSpawn [Boolean Whether this is the character's first spawn]
  function PLUGIN:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
    local skin = tonumber(player:GetCharacterData('CustomSkin'))

    ApplyCustomBodyGroups(player)

    if skin then
      player:SetSkin(skin)
    end
  end

  --- Called after a player gets up from a ragdoll; reapplies the character's custom bodygroups.
  -- @param player [Player The player who was unragdolled]
  -- @param state [Number The ragdoll state being set, a `RAGDOLL_*` value such as `RAGDOLL_RESET`]
  -- @param ragdollTable [Map The player's ragdoll data]
  function PLUGIN:PlayerUnragdolled(player, state, ragdollTable)
    ApplyCustomBodyGroups(player)
  end
end
