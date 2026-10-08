--- Main file of the Animated Legs plugin, which aliases it as `cwAnimatedLegs` and includes its client files.
--
-- The plugin draws the local player's own legs when they look down in first person.

--[[
  You don't have to do this, but I think it's nicer.
  Alternatively, you can simply use the PLUGIN variable.
--]]
PLUGIN:SetGlobalAlias('cwAnimatedLegs')

--[[ You don't have to do this either, but I prefer to seperate the functions. --]]
util.Include('cl_plugin.lua')
util.Include('cl_hooks.lua')
