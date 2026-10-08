--- Main file of the Emote Anims plugin, which lets characters perform stance and gesture animations through the `/Anim`
-- commands.
--
-- Aliases the plugin as `cwEmoteAnims` and defines `cwEmoteAnims:IsPlayerInStance`, the `cwEmoteAnims.stanceList` set
-- of animations that count as stances, and the shared `Move` and `EntityFireBullets` hooks that lock an emoting
-- player's angles and block their bullets.

--[[
  You don't have to do this, but I think it's nicer.
  Alternatively, you can simply use the PLUGIN variable.
--]]
PLUGIN:SetGlobalAlias('cwEmoteAnims')

--[[ You don't have to do this either, but I prefer to seperate the functions. --]]
util.Include('sv_plugin.lua')
util.Include('cl_hooks.lua')
util.Include('sv_hooks.lua')

--- Returns whether a player is performing an emote.
--
-- A player is in a stance while the `StancePos` net var holds a position other than `Vector(0, 0, 0)`.
-- @param player [Player The player to check]
-- @return [Boolean Whether the player is in a stance]
function cwEmoteAnims:IsPlayerInStance(player)
  local stancePos = player:GetNetVar('StancePos')

  return stancePos != nil and stancePos != vector_origin
end

--- Called when a player's movement is processed; locks the player's angles to the `StanceAng` net var
-- while emoting and returns `true` to override the movement.
-- @param player [Player The moving player]
-- @param moveData [CMoveData The player's movement data]
-- @return [Boolean `true` while the player is in a stance]
function cwEmoteAnims:Move(player, moveData)
  local stanceAng = player:GetNetVar('StanceAng')

  if stanceAng then
    player:SetAngles(stanceAng)

    return true
  end
end

--- Called when an entity fires bullets; blocks bullets fired by an emoting player or by an entity whose
-- owner is emoting.
-- @param entity [Entity The entity firing, or the weapon whose owner is checked]
-- @param bulletInfo [Map The bullet data]
-- @return [Boolean `false` to block the bullets]
function cwEmoteAnims:EntityFireBullets(entity, bulletInfo)
  if !IsValid(entity) then return false end

  local player = (!entity:IsPlayer() and entity:GetOwner()) or entity

  if IsValid(player) and self:IsPlayerInStance(player) then
    return false
  end
end

cwEmoteAnims.stanceList = {
  ['d1_t03_tenements_look_out_window_idle'] = true,
  ['d2_coast03_postbattle_idle02_entry'] = true,
  ['d2_coast03_postbattle_idle01_entry'] = true,
  ['d2_coast03_postbattle_idle02'] = true,
  ['d2_coast03_postbattle_idle01'] = true,
  ['d1_t03_lookoutwindow'] = true,
  ['idle_to_sit_ground'] = true,
  ['sit_ground_to_idle'] = true,
  ['spreadwallidle'] = true,
  ['apcarrestidle'] = true,
  ['plazathreat2'] = true,
  ['plazathreat1'] = true,
  ['sit_ground'] = true,
  ['lineidle04'] = true,
  ['lineidle02'] = true,
  ['lineidle01'] = true,
  ['plazaidle4'] = true,
  ['plazaidle2'] = true,
  ['plazaidle1'] = true,
  ['spreadwall'] = true,
  ['wave_close'] = true,
  ['idle_baton'] = true,
  ['wave_smg1'] = true,
  ['lean_back'] = true,
  ['cheer1'] = true,
  ['wave'] = true
}
