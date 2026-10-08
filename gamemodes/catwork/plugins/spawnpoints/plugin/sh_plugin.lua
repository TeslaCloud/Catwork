--- Entry point of the Spawn Points plugin, which lets admins set spawn points per class, per faction or as a default.
--
-- Sets the `cwSpawnPoints` global alias and includes the plugin's server and client files.

--[[
  You don't have to do this, but I think it's nicer.
  Alternatively, you can simply use the PLUGIN variable.
--]]
PLUGIN:SetGlobalAlias('cwSpawnPoints')

--[[ You don't have to do this either, but I prefer to seperate the functions. --]]
util.Include('sv_plugin.lua')
util.Include('sv_hooks.lua')
util.Include('cl_hooks.lua')
