--- Main file of the Cleaned Maps plugin, which aliases it as `cwCleanedMaps` and includes its files.
--
-- The plugin removes commonly unwanted entities from maps when they load.

--[[
  You don't have to do this, but I think it's nicer.
  Alternatively, you can simply use the PLUGIN variable.
--]]
PLUGIN:SetGlobalAlias('cwCleanedMaps')

--[[ You don't have to do this either, but I prefer to seperate the functions. --]]
util.Include('cl_plugin.lua')
util.Include('sv_plugin.lua')
util.Include('sv_hooks.lua')
