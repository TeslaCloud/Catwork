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
PLUGIN:SetGlobalAlias("cwAreaDisplays")

--[[ You don't have to do this either, but I prefer to seperate the functions. --]]
util.Include("cl_plugin.lua")
util.Include("sv_plugin.lua")
util.Include("sv_hooks.lua")
util.Include("cl_hooks.lua")

cwAreaDisplays.storedList = cwAreaDisplays.storedList or {};
