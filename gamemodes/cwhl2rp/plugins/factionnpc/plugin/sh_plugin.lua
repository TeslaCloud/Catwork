--- Main file of the FactionNPC plugin, which makes Half-Life 2 NPCs like or hate players according to the player's
-- faction; exposes the plugin as `factionnpc`.
--
-- `factionnpc.stored` lists the NPC classes that side with the Combine or with the rebels, checked by
-- `factionnpc:IsNPCCombine` and `factionnpc:IsNPCRebel`. `factionnpc:UpdateNPCRelations` and
-- `factionnpc:UpdateNPCRelation` set the relationships, and the `PlayerSpawn` and `PlayerSpawnedNPC` hooks apply them.

local PLUGIN = PLUGIN
PLUGIN:SetGlobalAlias('factionnpc')

factionnpc.stored = {
  ['npc_combine_s'] = true,
  ['npc_helicopter'] = true,
  ['npc_metropolice'] = true,
  ['npc_manhack'] = true,
  ['npc_combinedropship'] = true,
  ['npc_rollermine'] = true,
  ['npc_stalker'] = true,
  ['npc_turret_floor'] = true,
  ['npc_combinegunship'] = true,
  ['npc_cscanner'] = true,
  ['npc_clawscanner'] = true,
  ['npc_strider'] = true,
  ['npc_hunter'] = true,
  ['npc_cremator'] = true,
  ['npc_turret_ceiling'] = true,
  ['npc_turret_ground'] = true,
  ['npc_combine_camera'] = true,
  ['combine_mine'] = true,
  ['npc_citizen'] = false,
  ['npc_vortigaunt'] = false,
  ['npc_alyx'] = false,
  ['npc_barney'] = false,
  ['npc_dog'] = false,
  ['npc_eli'] = false,
  ['npc_monk'] = false
}

--- Returns whether an NPC belongs to the Combine.
--
-- Looks the NPC's class up in `factionnpc.stored`; floor turrets with the citizen spawn flag
-- count as rebels.
-- @param npc [NPC The NPC to check]
-- @return [Boolean `true` for Combine NPC classes, `false` for anything else or an invalid entity]
-- @see factionnpc:IsNPCRebel
function factionnpc:IsNPCCombine(npc)
  if IsValid(npc) then
    if npc:HasSpawnFlags(SF_FLOOR_TURRET_CITIZEN) and npc:GetClass() == 'npc_turret_floor' then
      return false
    end

    for k, v in pairs(self.stored) do
      if k == npc:GetClass() then
        return v
      end
    end
  end

  return false
end

--- Returns whether an NPC is on the rebels' side.
--
-- True for classes marked `false` in `factionnpc.stored` (citizens, vortigaunts, Alyx and other
-- resistance characters) and for floor turrets with the citizen spawn flag.
-- @param npc [NPC The NPC to check]
-- @return [Boolean `true` for rebel NPCs, `false` for anything else or an invalid entity]
-- @see factionnpc:IsNPCCombine
function factionnpc:IsNPCRebel(npc)
  if IsValid(npc) then
    if npc:HasSpawnFlags(SF_FLOOR_TURRET_CITIZEN) and npc:GetClass() == 'npc_turret_floor' then
      return true
    end

    for k, v in pairs(self.stored) do
      if k == npc:GetClass() then
        return (v == false)
      end
    end
  end

  return false
end

--- Sets how every NPC on the map feels about a player, based on the player's faction.
--
-- Combine NPCs like Combine players and hate everyone else; rebel NPCs hate Combine and admin
-- faction players and like everyone else. Both hate the necro and antlion factions.
-- Does nothing for an invalid entity or a non-player.
-- @param ply [Player The player the relationships are set towards]
-- @see factionnpc:UpdateNPCRelation
function factionnpc:UpdateNPCRelations(ply)
  if ply then
    if IsValid(ply) then
      if ply:IsPlayer() then
        for k, v in pairs(ents.GetAll()) do
          if !v:IsNPC() then continue end

          if self:IsNPCCombine(v) then
            if Schema:PlayerIsCombine(ply) then
              v:AddEntityRelationship(ply, 3)
            else
              v:AddEntityRelationship(ply, 1)
            end

            if ply:GetFaction() == FACTION_NECRO or ply:GetFaction() == FACTION_ANTLI then
              v:AddEntityRelationship(ply, 1)
            end
          elseif self:IsNPCRebel(v)  then
            if Schema:PlayerIsCombine(ply) or ply:GetFaction() == FACTION_ADMIN then
              v:AddEntityRelationship(ply, 1)
            else
              v:AddEntityRelationship(ply, 3)
            end

            if ply:GetFaction() == FACTION_NECRO or ply:GetFaction() == FACTION_ANTLI then
              v:AddEntityRelationship(ply, 1)
            end
          end
        end
      end
    end
  end
end

--- Sets how one NPC feels about every player, based on each player's faction.
--
-- Combine NPCs like Combine and admin faction players and hate everyone else; rebel NPCs
-- hate Combine and admin faction players and like everyone else. Both hate the necro and
-- antlion factions. Does nothing for NPCs that are neither Combine nor rebels.
-- @param npc [NPC The NPC whose relationships are set]
-- @see factionnpc:UpdateNPCRelations
function factionnpc:UpdateNPCRelation(npc)
  if !IsValid(npc) then return end
  if !npc:IsNPC() then return end

  if self:IsNPCCombine(npc) then
    for k, ply in pairs(player.GetAll()) do
      if Schema:PlayerIsCombine(ply) or ply:GetFaction() == FACTION_ADMIN then
        npc:AddEntityRelationship(ply, 3)
      else
        npc:AddEntityRelationship(ply, 1)
      end

      if ply:GetFaction() == FACTION_NECRO or ply:GetFaction() == FACTION_ANTLI then
        npc:AddEntityRelationship(ply, 1)
      end
    end
  elseif self:IsNPCRebel(npc) then
    for k, ply in pairs(player.GetAll()) do
      if Schema:PlayerIsCombine(ply) or ply:GetFaction() == FACTION_ADMIN then
        npc:AddEntityRelationship(ply, 1)
      else
        npc:AddEntityRelationship(ply, 3)
      end

      if ply:GetFaction() == FACTION_NECRO or ply:GetFaction() == FACTION_ANTLI then
        npc:AddEntityRelationship(ply, 1)
      end
    end
  end
end

--- Called when a player spawns; updates every NPC's relationship towards them.
-- @param ply [Player The player who spawned]
function factionnpc:PlayerSpawn(ply)
  self:UpdateNPCRelations(ply)
end

--- Called after a player spawns an NPC; sets the new NPC's relationships towards all players.
-- @param ply [Player The player who spawned the NPC]
-- @param npc [NPC The NPC that was spawned]
function factionnpc:PlayerSpawnedNPC(ply, npc)
  self:UpdateNPCRelation(npc)
end
