--- Main file of the Dynamic Adverts plugin, which lets admins place images from URLs on surfaces of the map.
--
-- Aliases the plugin as `cwDynamicAdverts`, includes its client and server files and creates
-- `cwDynamicAdverts.storedList`, the list of adverts that both realms keep.

--[[
  You don't have to do this, but I think it's nicer.
  Alternatively, you can simply use the PLUGIN variable.
--]]
PLUGIN:SetGlobalAlias('cwDynamicAdverts')

--[[ You don't have to do this either, but I prefer to seperate the functions. --]]
util.Include('cl_plugin.lua')
util.Include('sv_plugin.lua')
util.Include('sv_hooks.lua')
util.Include('cl_hooks.lua')

cwDynamicAdverts.storedList = cwDynamicAdverts.storedList or {}
