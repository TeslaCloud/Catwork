--- Main file of the Static Entities plugin, which aliases it as `cwStaticEnts` and includes its server-side hooks.
--
-- Backported from the [Flux](https://github.com/TeslaCloud/flux-ce) project.

PLUGIN:SetGlobalAlias('cwStaticEnts')

util.Include('sv_hooks.lua')
