--- Server-side hooks of the Affective wounds plugin that count the hits a player takes to the legs and arms and apply
-- their effects.
--
-- `PlayerTraceAttack` keeps the counts on the player as `cwLegShots` and `cwArmShots`. When the leg count reaches
-- `affectivewounds_legshotlimit` the player falls over for 5 seconds, and when the arm count reaches
-- `affectivewounds_armshotlimit` the active weapon is dropped as an item unless its class is in the local
-- `NoStripWeps` list. `PlayerCharacterLoaded` resets the counters, starting Overwatch and Civil Protection characters
-- below zero so that they take extra hits.

local PLUGIN = PLUGIN

-- If there's a certain weapon you don't want to be dropped when a player's arm is hit, add said weapon's CLASS NAME
-- here.
local NoStripWeps = {
  ['cw_hands'] = true,
  ['cw_keys'] = true,
  ['weapon_physgun'] = true,
  ['gmod_tool'] = true,
  ['cw_stunstick'] = true
}

--- Returns the hit count a player's limbs start from.
--
-- OTA and MPF characters start below zero by their faction's `affectivewounds_additionalhits*`
-- config value when the plugin affects that faction, so they take extra hits.
-- @param ply [Player The player]
-- @return [Number Zero, or minus the additional hits]
local function StartingHits(ply)
  local faction = ply:GetFaction()

  if faction == FACTION_OTA and config.Get('affectivewounds_affectota'):Get() then
    return -config.Get('affectivewounds_additionalhitsota'):Get()
  elseif faction == FACTION_MPF and config.Get('affectivewounds_affectmpf'):Get() then
    return -config.Get('affectivewounds_additionalhitsmpf'):Get()
  end

  return 0
end

--- Called after a player's character has loaded; resets the leg and arm hit counters.
-- @param ply [Player The player whose character loaded]
function PLUGIN:PlayerCharacterLoaded(ply)
  ply.cwLegShots = StartingHits(ply)
  ply.cwArmShots = ply.cwLegShots
end

--- Called when a player is hit by a traced attack; counts limb hits and applies their effects.
--
-- Once the leg hit count reaches `affectivewounds_legshotlimit` the player falls over for 5
-- seconds; once the arm count reaches `affectivewounds_armshotlimit` the player drops the
-- active weapon as an item, unless it is listed in `NoStripWeps`. Counters then reset.
-- Does nothing when the plugin is disabled, for unaffected factions, in vehicles or in noclip.
-- @param ply [Player The player being hit]
-- @param dmginfo [CTakeDamageInfo The damage being dealt]
-- @param dir [Vector Direction of the attack]
-- @param trace [Map Trace result; `HitGroup` decides which limb was hit]
function PLUGIN:PlayerTraceAttack(ply, dmginfo, dir, trace)
  if !config.Get('affectivewounds_enabled'):Get() or !ply:HasInitialized() then return end

  local faction = ply:GetFaction()

  if faction == FACTION_OTA and !config.Get('affectivewounds_affectota'):Get() then return end
  if faction == FACTION_MPF and !config.Get('affectivewounds_affectmpf'):Get() then return end
  if ply:InVehicle() or cw.player:IsNoClipping(ply) then return end

  local hitGroup = trace.HitGroup

  if hitGroup == HITGROUP_LEFTLEG or hitGroup == HITGROUP_RIGHTLEG then
    if ply:IsRagdolled() then return end

    local hits = (ply.cwLegShots or 0) + 1

    if hits < config.Get('affectivewounds_legshotlimit'):Get() then
      ply.cwLegShots = hits
    else
      ply.cwLegShots = StartingHits(ply)

      cw.player:SetRagdollState(ply, RAGDOLL_FALLENOVER, 5)
    end
  elseif hitGroup == HITGROUP_LEFTARM or hitGroup == HITGROUP_RIGHTARM then
    local hits = (ply.cwArmShots or 0) + 1

    if hits < config.Get('affectivewounds_armshotlimit'):Get() then
      ply.cwArmShots = hits

      return
    end

    ply.cwArmShots = StartingHits(ply)

    local activeWep = ply:GetActiveWeapon()
    local wepClass = IsValid(activeWep) and activeWep:GetClass()

    if wepClass and !NoStripWeps[wepClass] then
      local dropPos = ply:GetPos() + Vector(0, 0, 35) + ply:GetAngles():Forward() * 4
      local itemTable = item.GetByWeapon(activeWep)
      local entity = cw.entity:CreateItem(ply, itemTable, dropPos)

      if IsValid(entity) then
        ply:TakeItem(itemTable)
        ply:SelectWeapon('cw_hands')
        ply:StripWeapon(wepClass)
      end
    end
  end
end
