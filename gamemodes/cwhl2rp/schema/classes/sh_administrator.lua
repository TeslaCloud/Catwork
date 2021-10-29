--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local CLASS = cw.class:New("#Class_Admin")
	CLASS.color = Color(255, 200, 100, 255)
	CLASS.wages = 25
	CLASS.factions = {FACTION_ADMIN}
	CLASS.isDefault = true
	CLASS.wagesName = "#Class_Admin_Wages"
	CLASS.description = "#Class_Admin_Desc"
	CLASS.defaultPhysDesc = "Wearing a clean brown suit"
CLASS_ADMIN = CLASS:Register();
