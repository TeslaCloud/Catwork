--[[
	Catwork � 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local stored = {
	"npc_metropolice",
	"npc_combine_s" ,
	"npc_manhack",
	"npc_scanner",
	"combine_mine",
	"npc_combinegunship",
	"npc_combinedropship",
	"npc_strider",
	"npc_rollermine",
	"npc_cscanner",
	"npc_turret_ceiling",
	"npc_clawscanner",
	"npc_turret_floor"
}

local function applyNPCRelations(player, bHostile)
	if (!bHostile) then
		player:SetVar("faction", "f_combine")
		player:SetName("f_combine")
	else
		player:SetVar("faction", "f_human")
		player:SetName("f_human")
	end

	for k, v in ipairs(ents.GetAll()) do
		if (v:IsNPC()) then
			local class = v:GetClass()

			if (class and table.HasValue(stored, class:lower())) then
				v:Fire("setrelationship", "f_combine d_li 99", 0)
				v:Fire("setrelationship", "f_human d_ht 98", 0)
			end
		end
	end
end

function PLUGIN:PlayerSpawn(player)
	player:SetVar("faction", nil)
end

function PLUGIN:PlayerSpawnedNPC(player, npc)
	local class = npc:GetClass()

	if (class and table.HasValue(stored, class:lower())) then
		if (!config.GetVal("combine_attack_combine")) then
			npc:Fire("setrelationship", "f_combine d_li 99", 0)
		end

		npc:Fire("setrelationship", "f_human d_ht 98", 0)
	end
end

function PLUGIN:PlayerRagdolled(player, state, ragTab)
	applyNPCRelations(player, false)
end

function PLUGIN:PlayerUnragdolled(player, state, ragdollTable)
	if (!player:IsCombine() and player:GetFaction(player) != FACTION_ADMIN and !player:HasItemByID("combine_security_card")) then
		applyNPCRelations(player, true)
	end
end

function PLUGIN:PlayerCharacterLoaded(player)
	local faction = player:GetFaction(player)

	if (faction == FACTION_MPF or faction == FACTION_OTA or faction == FACTION_ADMIN or player:HasItemByID("combine_security_card")) then
		applyNPCRelations(player, false)
	else
		applyNPCRelations(player, true)
	end
end

function PLUGIN:PlayerItemTaken(player, itemTable)
	if (itemTable.uniqueID == "combine_security_card" and player:GetItemCountByID("combine_security_card") < 2) then
		applyNPCRelations(player, true)
	end
end

function PLUGIN:PlayerItemGiven(player, itemTable, bForce)
	if (itemTable.uniqueID == "combine_security_card") then
		applyNPCRelations(player, false)
	end
end

function PLUGIN:PlayerTakeDamage(victim, inflictor, attacker, hitGroup, damageInfo)
	if (IsValid(attacker) and IsValid(victim) and attacker:IsNPC()) then
		local class = attacker:GetClass()

		if (class and table.HasValue(stored, class:lower())) then
			if (Schema:PlayerIsCombine(victim) or victim:HasItemByID("combine_security_card")) then
				damageInfo:ScaleDamage(0); -- �������� �� �������� �����
			elseif (victim:GetRagdollState() == RAGDOLL_FALLENOVER) then
				damageInfo:ScaleDamage(0.2); -- ���� � ��������� �������� 20% �� �����
			elseif (class:lower() == "npc_turret_floor" or class:lower() == "npc_turret_ceiling") then
				damageInfo:ScaleDamage(5); -- ������ ������� 500% ����� �� ��-���������
			end
		end
	end
end
