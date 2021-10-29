local PLUGIN = PLUGIN
PLUGIN:SetGlobalAlias("factionnpc")

factionnpc.stored = {
	["npc_combine_s"] = true,
	["npc_helicopter"] = true,
	["npc_metropolice"] = true,
	["npc_manhack"] = true,
	["npc_combinedropship"] = true,
	["npc_rollermine"] = true,
	["npc_stalker"] = true,
	["npc_turret_floor"] = true,
	["npc_combinegunship"] = true,
	["npc_cscanner"] = true,
	["npc_clawscanner"] = true,
	["npc_strider"] = true,
	["npc_hunter"] = true,
	["npc_cremator"] = true,
	["npc_turret_ceiling"] = true,
	["npc_turret_ground"] = true,
	["npc_combine_camera"] = true,
	["combine_mine"] = true,
	["npc_citizen"] = false,
	["npc_vortigaunt"] = false,
	["npc_alyx"] = false,
	["npc_barney"] = false,
	["npc_dog"] = false,
	["npc_eli"] = false,
	["npc_monk"] = false
}

function factionnpc:IsNPCCombine(npc)
	if IsValid(npc) then
		if npc:HasSpawnFlags(SF_FLOOR_TURRET_CITIZEN) and npc:GetClass() == "npc_turret_floor" then
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
function factionnpc:IsNPCRebel(npc)
	if IsValid(npc) then
		if npc:HasSpawnFlags(SF_FLOOR_TURRET_CITIZEN) and npc:GetClass() == "npc_turret_floor" then
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

function factionnpc:PlayerSpawn(ply)
	self:UpdateNPCRelations(ply)
end

function factionnpc:PlayerSpawnedNPC(ply, npc)
	self:UpdateNPCRelation(npc)
end