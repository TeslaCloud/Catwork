--- Main file of the Pickup Objects plugin, which lets players pick up, carry and throw light objects and ragdolls with
-- the hands weapon.
--
-- Aliases the plugin as `cwPickupObjects` and includes its client and server files.

--[[
  You don't have to do this, but I think it's nicer.
  Alternatively, you can simply use the PLUGIN variable.
--]]
PLUGIN:SetGlobalAlias('cwPickupObjects')

--[[ You don't have to do this either, but I prefer to seperate the functions. --]]
util.Include('cl_plugin.lua')
util.Include('sv_plugin.lua')
util.Include('sv_hooks.lua')
util.Include('cl_hooks.lua')
