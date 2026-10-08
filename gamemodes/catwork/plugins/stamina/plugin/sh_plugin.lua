--- Entry point of the Stamina plugin, which gives characters stamina that running, jumping and punching use up.
--
-- Sets the `cwStamina` global alias and includes the plugin's server and client files.

--[[
  You don't have to do this, but I think it's nicer.
  Alternatively, you can simply use the PLUGIN variable.
--]]
PLUGIN:SetGlobalAlias('cwStamina')

--[[ You don't have to do this either, but I prefer to seperate the functions. --]]
util.Include('sv_plugin.lua')
util.Include('sv_hooks.lua')
util.Include('cl_plugin.lua')
util.Include('cl_hooks.lua')
