--- Main file of the Force Fields plugin, which adds Combine force fields that citizens cannot pass through; exposes the
-- plugin as `cwForceField`, defines the collision rules of `cw_forcefield` and includes the plugin's server and client
-- files.
--
-- The `ShouldCollide` hook lets projectiles, Combine NPCs and vehicles, Combine players and holders of a forcefield
-- card through, and asks the `ShouldForcefieldCollide` hook about everyone else. That hook decides by the field's
-- mode, one of the four listed in `cwForceField.modes`: no one, Civil Workers' Union, everyone or off.

PLUGIN:SetGlobalAlias('cwForceField')

cwForceField.Blocked = {}

cwForceField.modes = {
  '#ForceField_Mode_NoOne',
  '#ForceField_Mode_CWU',
  '#ForceField_Mode_Everyone',
  '#ForceField_Mode_Off'
}

local allowedEnts = {
  prop_combine_ball = true,
  npc_grenade_frag = true,
  rpg_missile				= true,
  grenade_ar2				= true,
  crossbow_bolt = true,
  npc_combine_camera		= true,
  npc_turret_ceiling		= true,
  npc_cscanner = true,
  npc_combinedropship = true,
  npc_combine_s = true,
  npc_combinegunship = true,
  npc_hunter = true,
  npc_helicopter = true,
  npc_manhack = true,
  npc_metropolice = true,
  npc_rollermine = true,
  npc_clawscanner = true,
  npc_stalker				= true,
  npc_strider				= true,
  npc_turret_floor 		= true,
  prop_vehicle_zapc		= true,
  prop_physics = true,
  hunter_flechette = true,
  npc_tripmine = true
}

--- Called to check whether two entities collide; decides who a forcefield blocks.
--
-- Combine projectiles, NPCs and vehicles always pass through forcefields. Players holding
-- use always collide, so they can use the field. Combine players and holders of a forcefield
-- card pass through; for everyone else `ShouldForcefieldCollide` decides by the field's mode.
--
-- @param a [Entity The first entity]
-- @param b [Entity The second entity]
-- @return [Boolean Whether the entities collide, or `nil` for the default]
function cwForceField:ShouldCollide(a, b)
  local player
  local entity

  if a:IsPlayer() then
    player = a
    entity = b
  elseif b:IsPlayer() then
    player = b
    entity = a
  elseif allowedEnts[a:GetClass()] and b:GetClass() == 'cw_forcefield' then
    return false
  elseif allowedEnts[b:GetClass()] and a:GetClass() == 'cw_forcefield' then
    return false
  end

  if IsValid(entity) and entity:GetClass() == 'cw_forcefield' then
    if IsValid(player) then
      -- if the player is pressing "use" key they should always collide so that using works.
      if player:KeyDown(IN_USE) then return true end

      if player:IsCombine() or player:GetNetVar('ShouldForceFieldCollide') == false then
        return false
      end

      return plugin.Call('ShouldForcefieldCollide', player, entity, entity:GetDTInt(0) or 1)
    else
      return true
    end
  end
end

--- Called to check whether a forcefield blocks a player, by the field's mode.
--
-- Mode 1 blocks everyone, mode 2 lets Civil Workers' Union members through, and modes 3
-- (everyone allowed) and 4 (off) block no one. The modes are listed in `cwForceField.modes`.
--
-- @param player [Player The player touching the field]
-- @param field [Entity The `cw_forcefield`]
-- @param mode [Number The field's mode, 1 to 4]
-- @return [Boolean Whether the player collides with the field, or `nil` for the default]
function cwForceField:ShouldForcefieldCollide(player, field, mode)
  if mode == 2 and IsValid(player) then
    if player:GetFaction() == FACTION_CWU then
      return false
    end
  end

  if mode == 3 or mode == 4 then
    return false
  elseif mode == 1 then
    return true
  end
end

util.Include('sv_plugin.lua')
util.Include('cl_hooks.lua')
util.Include('sv_hooks.lua')
