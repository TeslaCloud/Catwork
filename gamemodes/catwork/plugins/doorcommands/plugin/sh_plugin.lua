--- Main file of the Door Commands plugin, which aliases it as `cwDoorCmds` and includes its files.
--
-- The plugin adds admin commands and tools for locking doors, naming them, hiding them, setting whether they can be
-- owned and parenting them to each other, and keeps that data for each map.

--[[
  You don't have to do this, but I think it's nicer.
  Alternatively, you can simply use the PLUGIN variable.
--]]
PLUGIN:SetGlobalAlias('cwDoorCmds')

--[[ You don't have to do this either, but I prefer to seperate the functions. --]]
util.Include('cl_plugin.lua')
util.Include('sv_plugin.lua')
util.Include('sv_hooks.lua')
