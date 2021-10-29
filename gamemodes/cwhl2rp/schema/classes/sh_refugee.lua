--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local CLASS = cw.class:New("#Class_Refugee")
	CLASS.color = Color(150, 125, 100, 255)
	CLASS.factions = {FACTION_REFUGEE}
	CLASS.isDefault = true
	CLASS.wagesName = "#Class_Refugee_Wages"
	CLASS.description = "#Class_Refugee_Desc"
	CLASS.defaultPhysDesc = "Wearing clothes."
CLASS_REFUGE = CLASS:Register();
