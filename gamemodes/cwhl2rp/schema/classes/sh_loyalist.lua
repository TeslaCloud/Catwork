--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local CLASS = cw.class:New("#Class_Loyalist")
	CLASS.color = Color(50, 150, 150, 255)
	CLASS.factions = {FACTION_LOYAL}
	CLASS.isDefault = true
	CLASS.description = "#Class_Loyalist_Desc"
	CLASS.defaultPhysDesc = "Wearing clothes."
CLASS_LOYAL = CLASS:Register();
