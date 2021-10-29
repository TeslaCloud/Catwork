--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local CLASS = cw.class:New("#Class_Citizen")
	CLASS.color = Color(150, 125, 100, 255)
	CLASS.factions = {FACTION_CITIZEN}
	CLASS.isDefault = true
	CLASS.wagesName = "#Class_Citizen_Wages"
	CLASS.description = "#Class_Citizen_Desc"
	CLASS.defaultPhysDesc = "Wearing dirty clothes."
CLASS_CITIZEN = CLASS:Register();
