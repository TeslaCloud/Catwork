--- Main file of the Area Displays plugin, which aliases it as `cwAreaDisplays`, includes its files and creates
-- `cwAreaDisplays.storedList`.
--
-- The plugin shows the name of a map area to players who walk into it, as scrolling HUD text, 3D text in the world or
-- cinematic text.

--[[
  You don't have to do this, but I think it's nicer.
  Alternatively, you can simply use the PLUGIN variable.
--]]
PLUGIN:SetGlobalAlias('cwAreaDisplays')

--[[ You don't have to do this either, but I prefer to seperate the functions. --]]
util.Include('cl_plugin.lua')
util.Include('sv_plugin.lua')
util.Include('sv_hooks.lua')
util.Include('cl_hooks.lua')

cwAreaDisplays.storedList = cwAreaDisplays.storedList or {}
