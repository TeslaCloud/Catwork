--- Main file of the Combine Devices plugin, which adds the `cw_combineaccessmonitor` entity and keeps the Combine
-- devices placed on a map across restarts, and includes the plugin's server files.

local PLUGIN = PLUGIN

util.Include('sv_schema.lua')
util.Include('sv_hooks.lua')
