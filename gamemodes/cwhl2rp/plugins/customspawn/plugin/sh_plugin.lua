--- Main file of the Custom Spawn plugin, which gives characters their own spawn point; exposes the plugin as
-- `cwCustomSpawn` and includes its server-side hooks.

PLUGIN:SetGlobalAlias('cwCustomSpawn')

util.Include('sv_hooks.lua')
