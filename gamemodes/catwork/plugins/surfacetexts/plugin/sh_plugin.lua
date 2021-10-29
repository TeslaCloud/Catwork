--[[
	LightFlare © 2016-2017 TeslaCloud Studios
	Do not share or re-distribute before
	the framework is publicly released.
--]]

--[[
	You don't have to do this, but I think it's nicer.
	Alternatively, you can simply use the PLUGIN variable.
--]]
PLUGIN:SetGlobalAlias("cwSurfaceTexts")

--[[ You don't have to do this either, but I prefer to seperate the functions. --]]
util.Include("cl_plugin.lua")
util.Include("sv_plugin.lua")
util.Include("sv_hooks.lua")
util.Include("cl_hooks.lua")

cwSurfaceTexts.stored = cwSurfaceTexts.stored or {};