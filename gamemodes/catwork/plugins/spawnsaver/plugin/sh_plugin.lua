--- Entry point of the Spawn Saver plugin, which makes characters spawn where they were last left when the
-- `spawn_where_left` config is on.
--
-- Sets the `cwSpawnSaver` global alias and includes the plugin's client and server files.

--[[
  You don't have to do this, but I think it's nicer.
  Alternatively, you can simply use the PLUGIN variable.
--]]
PLUGIN:SetGlobalAlias('cwSpawnSaver')

--[[ You don't have to do this either, but I prefer to seperate the functions. --]]
util.Include('cl_plugin.lua')
util.Include('sv_plugin.lua')
util.Include('sv_hooks.lua')
