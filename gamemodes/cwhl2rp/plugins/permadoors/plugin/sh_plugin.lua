--- Main file of the Permanent Doors plugin, which lets admins assign doors to characters for good; exposes the plugin
-- as `cwPermaDoors`, creates `cwPermaDoors.stored` (door entity to door data) and includes the plugin's server-side
-- files.

PLUGIN:SetGlobalAlias('cwPermaDoors')

cwPermaDoors.stored = cwPermaDoors.stored or {}

util.Include('sv_plugin.lua')
util.Include('sv_hooks.lua')
