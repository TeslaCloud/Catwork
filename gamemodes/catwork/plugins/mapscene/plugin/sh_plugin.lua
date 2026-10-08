--- Main file of the Map Scenes plugin, which shows a saved view of the map behind the character menu.
--
-- Aliases the plugin as `cwMapScene` and includes its client and server files. Scenes are added with `/MapSceneAdd`
-- and removed with `/MapSceneRemove`.

--[[
  You don't have to do this, but I think it's nicer.
  Alternatively, you can simply use the PLUGIN variable.
--]]
PLUGIN:SetGlobalAlias('cwMapScene')

--[[ You don't have to do this either, but I prefer to seperate the functions. --]]
util.Include('cl_plugin.lua')
util.Include('sv_plugin.lua')
util.Include('cl_hooks.lua')
util.Include('sv_hooks.lua')
