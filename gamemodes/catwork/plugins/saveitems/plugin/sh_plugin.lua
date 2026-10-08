--- Main file of the Save Items plugin, which saves the items and shipments lying on the map and respawns them when the
-- map is loaded again.
--
-- Aliases the plugin as `cwSaveItems` and includes its two server files; the plugin has no client-side code.

--[[
  You don't have to do this, but I think it's nicer.
  Alternatively, you can simply use the PLUGIN variable.
--]]
PLUGIN:SetGlobalAlias('cwSaveItems')

--[[ You don't have to do this either, but I prefer to seperate the functions. --]]
util.Include('sv_plugin.lua')
util.Include('sv_hooks.lua')
