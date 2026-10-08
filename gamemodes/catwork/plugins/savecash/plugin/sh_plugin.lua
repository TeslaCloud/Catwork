--- Main file of the Save Cash plugin, which saves the cash lying on the map and respawns it when the map is loaded
-- again.
--
-- Aliases the plugin as `cwSaveCash` and includes its two server files; the plugin has no client-side code.

--[[
  You don't have to do this, but I think it's nicer.
  Alternatively, you can simply use the PLUGIN variable.
--]]
PLUGIN:SetGlobalAlias('cwSaveCash')

--[[ You don't have to do this either, but I prefer to seperate the functions. --]]
util.Include('sv_plugin.lua')
util.Include('sv_hooks.lua')
