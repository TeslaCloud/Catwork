PLUGIN:SetGlobalAlias("cwForceField")

cwForceField.Blocked = {};

cwForceField.modes = {
	"Do not allow anyone.",
	"Allow CWU.",
	"Allow everyone.",
	"Off."
}

local allowedEnts = {
	prop_combine_ball		= true,
	npc_grenade_frag		= true,
	rpg_missile				= true,
	grenade_ar2				= true,
	crossbow_bolt			= true,
	npc_combine_camera		= true,
	npc_turret_ceiling		= true,
	npc_cscanner			= true,
	npc_combinedropship		= true,
	npc_combine_s			= true,
	npc_combinegunship		= true,
	npc_hunter				= true,
	npc_helicopter			= true,
	npc_manhack				= true,
	npc_metropolice			= true,
	npc_rollermine			= true,
	npc_clawscanner			= true,
	npc_stalker				= true,
	npc_strider				= true,
	npc_turret_floor 		= true,
	prop_vehicle_zapc		= true,
	prop_physics			= true,
	hunter_flechette		= true,
	npc_tripmine			= true,
	prop_vehicle_zapc		= true
}

function cwForceField:ShouldCollide(a, b)
	local player;
	local entity;

	if (a:IsPlayer()) then
		player = a;
		entity = b;
	elseif (b:IsPlayer()) then
		player = b;
		entity = a;
	elseif (allowedEnts[a:GetClass()] and b:GetClass() == "cw_forcefield") then
		return false;
	elseif (allowedEnts[b:GetClass()] and a:GetClass() == "cw_forcefield") then
		return false;
	end;

	if (IsValid(entity) and entity:GetClass() == "cw_forcefield") then
		if (IsValid(player)) then
			if (player:KeyDown(IN_USE)) then return true end -- if the player is pressing "use" key they should always collide so that using works.

			if (player:IsCombine() or player:GetNetVar("ShouldForceFieldCollide") == false) then
				return false
			end

			return plugin.Call("ShouldForcefieldCollide", player, entity, entity:GetDTInt(0) or 1)
		else
			return true
		end
	end
end

function cwForceField:ShouldForcefieldCollide(player, field, mode)
	if (mode == 2 and IsValid(player)) then
		if (player:GetFaction() == FACTION_CWU) then
			return false
		end
	end

	if (mode == 3 or mode == 4) then
		return false
	elseif (mode == 1) then
		return true
	end
end

util.Include("sv_plugin.lua");
util.Include("cl_hooks.lua");
util.Include("sv_hooks.lua");