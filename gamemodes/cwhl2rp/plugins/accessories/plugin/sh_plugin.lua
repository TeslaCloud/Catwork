--- Main file of the Advanced Accessories plugin, which only includes its server-side hooks file.
--
-- The plugin currently adds nothing but language strings: the hooks file is empty and its only item, `backpack_large`,
-- is commented out.

local PLUGIN = PLUGIN

util.Include('sv_hooks.lua')
