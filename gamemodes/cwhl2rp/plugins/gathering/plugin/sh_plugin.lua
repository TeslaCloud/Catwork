--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

PLUGIN:SetGlobalAlias("cwGather")

local stored = cwGather.stored or {}
cwGather.stored = stored

util.Include("sv_plugin.lua")
util.Include("sv_hooks.lua")
util.Include("cl_plugin.lua")

cwGather.woodNodes = {
	"models/props_c17/bench01a.mdl",
	"models/props_c17/FurnitureChair001a.mdl",
	"models/props_c17/FurnitureDrawer001a.mdl",
	"models/props_c17/FurnitureDrawer001a_Chunk01.mdl",
	"models/props_c17/FurnitureDrawer001a_Chunk02.mdl",
	"models/props_c17/FurnitureDrawer001a_Chunk03.mdl",
	"models/props_c17/FurnitureDrawer001a_Chunk05.mdl",
	"models/props_c17/FurnitureDrawer001a_Chunk06.mdl",
	"models/props_c17/FurnitureDrawer002a.mdl",
	"models/props_c17/FurnitureDresser001a.mdl",
	"models/props_c17/FurnitureShelf001a.mdl",
	"models/props_c17/FurnitureTable001a.mdl",
	"models/props_c17/FurnitureTable002a.mdl",
	"models/props_c17/FurnitureTable003a.mdl",
	"models/props_c17/shelfunit01a.mdl",
	"models/props_interiors/Furniture_Desk01a.mdl",
	"models/props_interiors/Furniture_shelf01a.mdl",
	"models/props_interiors/Furniture_Vanity01a.mdl",
	"models/props_junk/wood_crate001a.mdl",
	"models/props_junk/wood_crate001a_damaged.mdl",
	"models/props_junk/wood_crate002a.mdl",
	"models/props_junk/wood_pallet001a.mdl",
	"models/props_wasteland/cafeteria_bench001a.mdl",
	"models/props_wasteland/cafeteria_table001a.mdl",
	"models/props_wasteland/prison_shelf002a.mdl"
}
