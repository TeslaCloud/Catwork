--- Server-side hooks of the Friendly Combine plugin that set the relationship between Combine NPCs and each player.
--
-- Players are named `f_combine` or `f_human` and the listed NPC classes (metrocops, soldiers, scanners, turrets,
-- striders and so on) are told to like the first and hate the second. MPF, OTA, the admin faction, holders of a
-- `combine_security_card` and ragdolled players count as friendly; the relationship is refreshed when a character
-- loads, an NPC is spawned, a player is ragdolled or gets up, and a card is given or taken. `PlayerTakeDamage` also
-- scales the damage these NPCs deal.

local stored = {
  ['npc_metropolice'] = true,
  ['npc_combine_s'] = true,
  ['npc_manhack'] = true,
  ['npc_scanner'] = true,
  ['combine_mine'] = true,
  ['npc_combinegunship'] = true,
  ['npc_combinedropship'] = true,
  ['npc_strider'] = true,
  ['npc_rollermine'] = true,
  ['npc_cscanner'] = true,
  ['npc_turret_ceiling'] = true,
  ['npc_clawscanner'] = true,
  ['npc_turret_floor'] = true
}

local function ApplyNPCRelations(player, bHostile)
  player:SetName(bHostile and 'f_human' or 'f_combine')

  -- The relationships go by name and only reach the entities carrying it right now, so they are set again.
  for k, v in ipairs(ents.FindByClass('npc_*')) do
    if v:IsNPC() and stored[v:GetClass():lower()] then
      v:Fire('setrelationship', 'f_combine d_li 99', 0)
      v:Fire('setrelationship', 'f_human d_ht 98', 0)
    end
  end
end

--- Called after a player spawns an NPC; makes a new Combine NPC hate non-Combine players.
--
-- The NPC also likes Combine players unless the `combine_attack_combine` config is enabled.
-- @param player [Player The player who spawned the NPC]
-- @param npc [NPC The NPC that was spawned]
function PLUGIN:PlayerSpawnedNPC(player, npc)
  if stored[npc:GetClass():lower()] then
    if !config.GetVal('combine_attack_combine') then
      npc:Fire('setrelationship', 'f_combine d_li 99', 0)
    end

    npc:Fire('setrelationship', 'f_human d_ht 98', 0)
  end
end

--- Called when a player is ragdolled; makes Combine NPCs treat the player as friendly while down.
-- @param player [Player The player who was ragdolled]
-- @param state [Number The new ragdoll state, a `RAGDOLL_*` value]
-- @param ragTab [Map The player's ragdoll data]
function PLUGIN:PlayerRagdolled(player, state, ragTab)
  ApplyNPCRelations(player, false)
end

--- Called after a player gets up; makes Combine NPCs hostile again towards non-Combine players.
--
-- Combine, the admin faction and players carrying a Combine security card stay friendly.
-- @param player [Player The player who was unragdolled]
-- @param state [Number The ragdoll state being set, a `RAGDOLL_*` value]
-- @param ragdollTable [Map The player's ragdoll data]
function PLUGIN:PlayerUnragdolled(player, state, ragdollTable)
  if !player:IsCombine() and player:GetFaction(player) != FACTION_ADMIN
  and !player:HasItemByID('combine_security_card') then
    ApplyNPCRelations(player, true)
  end
end

--- Called after a player's character has loaded; sets whether Combine NPCs are friendly towards them.
--
-- MPF, OTA, the admin faction and players carrying a Combine security card are friendly; everyone
-- else is hostile.
-- @param player [Player The player whose character loaded]
function PLUGIN:PlayerCharacterLoaded(player)
  local faction = player:GetFaction(player)

  if faction == FACTION_MPF or faction == FACTION_OTA or faction == FACTION_ADMIN
  or player:HasItemByID('combine_security_card') then
    ApplyNPCRelations(player, false)
  else
    ApplyNPCRelations(player, true)
  end
end

--- Called when an item is taken from a player; losing a Combine security card makes Combine NPCs hostile.
--
-- The hook runs before the card is removed, so this applies when it is the player's last card.
-- @param player [Player The player who lost the item]
-- @param itemTable [Item The item that was taken]
function PLUGIN:PlayerItemTaken(player, itemTable)
  if itemTable.uniqueID == 'combine_security_card' and player:GetItemCountByID('combine_security_card') < 2 then
    ApplyNPCRelations(player, true)
  end
end

--- Called when a player is given an item; a Combine security card makes Combine NPCs friendly.
-- @param player [Player The player who received the item]
-- @param itemTable [Item The item that was given]
-- @param bForce [Boolean Whether the item was given regardless of inventory limits]
function PLUGIN:PlayerItemGiven(player, itemTable, bForce)
  if itemTable.uniqueID == 'combine_security_card' then
    ApplyNPCRelations(player, false)
  end
end

--- Called when a player takes damage; scales damage dealt by Combine NPCs.
--
-- Combine and security card holders take none, fallen-over players take 20 percent, and
-- turrets deal five times their normal damage to everyone else.
-- @param victim [Player The player taking damage]
-- @param inflictor [Entity The entity that dealt the damage]
-- @param attacker [Entity The entity responsible for the damage]
-- @param hitGroup [Number The `HITGROUP_*` that was hit]
-- @param damageInfo [CTakeDamageInfo The damage being dealt; scaled in place]
function PLUGIN:PlayerTakeDamage(victim, inflictor, attacker, hitGroup, damageInfo)
  if IsValid(attacker) and IsValid(victim) and attacker:IsNPC() then
    local class = attacker:GetClass():lower()

    if stored[class] then
      if Schema:PlayerIsCombine(victim) or victim:HasItemByID('combine_security_card') then
        damageInfo:ScaleDamage(0)
      elseif victim:GetRagdollState() == RAGDOLL_FALLENOVER then
        damageInfo:ScaleDamage(0.2)
      elseif class == 'npc_turret_floor' or class == 'npc_turret_ceiling' then
        damageInfo:ScaleDamage(5)
      end
    end
  end
end
