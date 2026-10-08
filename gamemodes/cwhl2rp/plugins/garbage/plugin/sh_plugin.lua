--- Main file of the Garbage plugin, which lets admins place spawn points for garbage piles that players can search for
-- items; exposes the plugin as `cwGarbage`, creates the `cwGarbage.stored` loot table and includes the plugin's server
-- and client files.

PLUGIN:SetGlobalAlias('cwGarbage')

cwGarbage.stored = cwGarbage.stored or {}

util.Include('sv_plugin.lua')
util.Include('sv_hooks.lua')
util.Include('cl_plugin.lua')
util.Include('cl_hooks.lua')
