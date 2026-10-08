--- Main file of the Salesmen plugin, which lets staff place NPCs that sell items to players and buy items from them.
--
-- Aliases the plugin as `cwSalesmen`, includes its client and server files and creates `cwSalesmen.salesmen`, the list
-- of salesman entities on the map.

--[[
  You don't have to do this, but I think it's nicer.
  Alternatively, you can simply use the PLUGIN variable.
--]]
PLUGIN:SetGlobalAlias('cwSalesmen')

--[[ You don't have to do this either, but I prefer to seperate the functions. --]]
util.Include('cl_plugin.lua')
util.Include('sv_plugin.lua')
util.Include('sv_hooks.lua')

cwSalesmen.salesmen = cwSalesmen.salesmen or {}
