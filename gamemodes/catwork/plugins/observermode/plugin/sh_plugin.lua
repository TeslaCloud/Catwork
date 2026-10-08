--- Main file of the Observer Mode plugin, which replaces noclip for staff with an invisible observer mode that returns
-- them to where they entered it.
--
-- Aliases the plugin as `cwObserverMode` and includes its client and server files.

--[[
  You don't have to do this, but I think it's nicer.
  Alternatively, you can simply use the PLUGIN variable.
--]]
PLUGIN:SetGlobalAlias('cwObserverMode')

--[[ You don't have to do this either, but I prefer to seperate the functions. --]]
util.Include('sv_plugin.lua')
util.Include('sv_hooks.lua')
util.Include('cl_hooks.lua')
util.Include('cl_plugin.lua')
