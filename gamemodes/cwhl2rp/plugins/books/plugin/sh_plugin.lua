--- Entry point of the Books plugin, which adds books that players can place in the world and read.
--
-- Adds the Literature custom permit (flag `3`) with `Schema:AddCustomPermit` and includes the plugin's client and
-- server files.

local PLUGIN = PLUGIN

Schema:AddCustomPermit('Literature', '3', 'models/props_lab/bindergreenlabel.mdl')

util.Include('cl_plugin.lua')
util.Include('cl_hooks.lua')
util.Include('sv_plugin.lua')
util.Include('sv_hooks.lua')
