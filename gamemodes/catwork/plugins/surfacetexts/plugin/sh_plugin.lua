--- Main file of the Surface Texts plugin, which aliases it as `cwSurfaceTexts`, includes its files and creates
-- `cwSurfaceTexts.stored`.
--
-- Backported from the [Flux](https://github.com/TeslaCloud/flux-ce) project.

--[[
  You don't have to do this, but I think it's nicer.
  Alternatively, you can simply use the PLUGIN variable.
--]]
PLUGIN:SetGlobalAlias('cwSurfaceTexts')

--[[ You don't have to do this either, but I prefer to seperate the functions. --]]
util.Include('cl_plugin.lua')
util.Include('sv_plugin.lua')
util.Include('sv_hooks.lua')
util.Include('cl_hooks.lua')

cwSurfaceTexts.stored = cwSurfaceTexts.stored or {}
