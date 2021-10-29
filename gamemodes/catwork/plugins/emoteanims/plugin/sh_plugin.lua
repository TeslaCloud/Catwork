--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

--[[
	You don't have to do this, but I think it's nicer.
	Alternatively, you can simply use the PLUGIN variable.
--]]
PLUGIN:SetGlobalAlias("cwEmoteAnims")

--[[ You don't have to do this either, but I prefer to seperate the functions. --]]
util.Include("sv_plugin.lua")
util.Include("cl_hooks.lua")
util.Include("sv_hooks.lua")

-- A function to get whether a player is in a stance.
function cwEmoteAnims:IsPlayerInStance(player)
	return player:GetNetVar("StancePos") != Vector(0, 0, 0)
end

-- Called when a player starts to move.
function cwEmoteAnims:Move(player, moveData)
	local stanceAng = player:GetNetVar("StanceAng")

	if (stanceAng) then
		player:SetAngles(stanceAng)

		return true
	end
end

function cwEmoteAnims:EntityFireBullets(entity, bulletInfo)
	if (!IsValid(entity)) then return false end

	local player = (!entity:IsPlayer() and entity:GetOwner()) or entity

	if (IsValid(player) and self:IsPlayerInStance(player)) then
		return false
	end
end

cwEmoteAnims.stanceList = {
	["d1_t03_tenements_look_out_window_idle"] = true,
	["d2_coast03_postbattle_idle02_entry"] = true,
	["d2_coast03_postbattle_idle01_entry"] = true,
	["d2_coast03_postbattle_idle02"] = true,
	["d2_coast03_postbattle_idle01"] = true,
	["d1_t03_lookoutwindow"] = true,
	["idle_to_sit_ground"] = true,
	["sit_ground_to_idle"] = true,
	["spreadwallidle"] = true,
	["apcarrestidle"] = true,
	["plazathreat2"] = true,
	["plazathreat1"] = true,
	["sit_ground"] = true,
	["lineidle04"] = true,
	["lineidle02"] = true,
	["lineidle01"] = true,
	["plazaidle4"] = true,
	["plazaidle2"] = true,
	["plazaidle1"] = true,
	["spreadwall"] = true,
	["wave_close"] = true,
	["idle_baton"] = true,
	["wave_smg1"] = true,
	["lean_back"] = true,
	["cheer1"] = true,
	["wave"] = true
};
