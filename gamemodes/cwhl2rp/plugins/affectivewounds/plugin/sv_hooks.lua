--- Server-side hooks of the Affective wounds plugin that count the hits a player takes to the legs and arms and apply
-- their effects.
--
-- `PlayerTraceAttack` keeps the counts in the `legshotamount` and `armshotamount` net vars. When the leg count reaches
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

--- Called after a player's character has loaded; resets the leg and arm hit counters.
--
-- OTA and MPF characters start below zero by their faction's `affectivewounds_additionalhits*`
-- config value when the plugin affects that faction, so they take extra hits.
-- @param ply [Player The player whose character loaded]
function PLUGIN:PlayerCharacterLoaded(ply)
  if ply:GetFaction() == FACTION_OTA and config.Get('affectivewounds_affectota'):Get() then
    ply:SetNetVar('legshotamount', 0 - config.Get('affectivewounds_additionalhitsota'):Get())
    ply:SetNetVar('armshotamount', 0 - config.Get('affectivewounds_additionalhitsota'):Get())
  elseif ply:GetFaction() == FACTION_MPF and config.Get('affectivewounds_affectmpf'):Get() then
    ply:SetNetVar('legshotamount', 0 - config.Get('affectivewounds_additionalhitsmpf'):Get())
    ply:SetNetVar('armshotamount', 0 - config.Get('affectivewounds_additionalhitsmpf'):Get())
  else
    ply:SetNetVar('legshotamount', 0)
    ply:SetNetVar('armshotamount', 0)
  end
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
  if config.Get('affectivewounds_enabled'):Get() then
    if ply:GetFaction() == FACTION_OTA and !config.Get('affectivewounds_affectota'):Get() then return end
    if ply:GetFaction() == FACTION_MPF and !config.Get('affectivewounds_affectmpf'):Get() then return end

    if !ply:InVehicle() and !cw.player:IsNoClipping(ply) then
      if trace.HitGroup == HITGROUP_LEFTLEG or trace.HitGroup == HITGROUP_RIGHTLEG then
        if !ply:IsRagdolled() then
          if ply:GetNetVar('legshotamount') < config.Get('affectivewounds_legshotlimit'):Get() - 1 then
            ply:SetNetVar('legshotamount', ply:GetNetVar('legshotamount') + 1)
          else
            if ply:GetFaction() == FACTION_MPF then
              ply:SetNetVar('legshotamount', 0 - config.Get('affectivewounds_additionalhitsmpf'):Get())
            elseif ply:GetFaction() == FACTION_OTA then
              ply:SetNetVar('legshotamount', 0 - config.Get('affectivewounds_additionalhitsota'):Get())
            else
              ply:SetNetVar('legshotamount', 0)
            end

            cw.player:SetRagdollState(ply, RAGDOLL_FALLENOVER, 5)
          end
        end
      end

      if trace.HitGroup == HITGROUP_LEFTARM or trace.HitGroup == HITGROUP_RIGHTARM then
        if ply:GetNetVar('armshotamount') < config.Get('affectivewounds_armshotlimit'):Get() - 1 then
          ply:SetNetVar('armshotamount', ply:GetNetVar('armshotamount') + 1)
        else
          if ply:GetFaction() == FACTION_MPF then
            ply:SetNetVar('armshotamount', 0 - config.Get('affectivewounds_additionalhitsmpf'):Get())
          elseif ply:GetFaction() == FACTION_OTA then
            ply:SetNetVar('armshotamount', 0 - config.Get('affectivewounds_additionalhitsota'):Get())
          else
            ply:SetNetVar('armshotamount', 0)
          end

          local activeWep = ply:GetActiveWeapon()
          local wepClass = IsValid(activeWep) and activeWep:GetClass()

          if wepClass and !NoStripWeps[wepClass] then
            if IsValid(activeWep) then
              local dropPos = ply:GetPos() + Vector(0, 0, 35) + ply:GetAngles():Forward() * 4
              local itemTable = item.GetByWeapon(activeWep)
              local entity = cw.entity:CreateItem(ply, itemTable, dropPos)

              if IsValid(entity) then
                ply:TakeItem(itemTable, true)
                ply:SelectWeapon('cw_hands')
                ply:StripWeapon(wepClass)
              end
            end
          end
        end
      end
    end
  end
end
