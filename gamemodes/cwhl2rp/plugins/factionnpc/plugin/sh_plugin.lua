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
    local class = npc:GetClass()

    if class == 'npc_turret_floor' and npc:HasSpawnFlags(SF_FLOOR_TURRET_CITIZEN) then
      return false
    end

    return self.stored[class] == true
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
    local class = npc:GetClass()

    if class == 'npc_turret_floor' and npc:HasSpawnFlags(SF_FLOOR_TURRET_CITIZEN) then
      return true
    end

    return self.stored[class] == false
  end

  return false
end

--- Returns how an NPC of one side feels about a player, based on the player's faction.
-- @param bCombineNPC [Boolean Whether the NPC belongs to the Combine rather than the rebels]
-- @param ply [Player The player]
-- @return [Number `D_LI` or `D_HT`]
local function GetDisposition(bCombineNPC, ply)
  local faction = ply:GetFaction()

  if faction == FACTION_NECRO or faction == FACTION_ANTLI then
    return D_HT
  end

  local bCombinePlayer = (Schema:PlayerIsCombine(ply) or faction == FACTION_ADMIN) and true or false

  return bCombineNPC == bCombinePlayer and D_LI or D_HT
end

--- Sets how every NPC on the map feels about a player, based on the player's faction.
--
-- Combine NPCs like Combine and admin faction players and hate everyone else; rebel NPCs
-- hate Combine and admin faction players and like everyone else. Both hate the necro and
-- antlion factions. Does nothing for an invalid entity or a non-player.
-- @param ply [Player The player the relationships are set towards]
-- @see factionnpc:UpdateNPCRelation
function factionnpc:UpdateNPCRelations(ply)
  if !IsValid(ply) or !ply:IsPlayer() then return end

  for k, v in ipairs(ents.FindByClass('npc_*')) do
    if v:IsNPC() then
      if self:IsNPCCombine(v) then
        v:AddEntityRelationship(ply, GetDisposition(true, ply))
      elseif self:IsNPCRebel(v) then
        v:AddEntityRelationship(ply, GetDisposition(false, ply))
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
  if !IsValid(npc) or !npc:IsNPC() then return end

  local bCombineNPC = self:IsNPCCombine(npc)

  if !bCombineNPC and !self:IsNPCRebel(npc) then return end

  for k, ply in ipairs(_player.GetAll()) do
    npc:AddEntityRelationship(ply, GetDisposition(bCombineNPC, ply))
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
