--[[
	© 2016 TeslaCloud Studios.
	Please do not use anywhere else.
--]]

util.Include("sv_plugin.lua")
util.Include("sv_hooks.lua")
util.Include("cl_plugin.lua")
util.Include("cl_hooks.lua");

function PLUGIN:PlayerHasNeeds(player)
	return !player:IsCombine() or player:GetFaction() == FACTION_MPF
end