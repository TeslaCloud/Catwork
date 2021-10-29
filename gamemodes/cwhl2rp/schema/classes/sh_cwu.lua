--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local CLASS = cw.class:New("#Class_CWU")
	CLASS.color = Color(240, 220, 100, 255)
	CLASS.factions = {FACTION_CWU}
	CLASS.wages = 8
	CLASS.isDefault = true
	CLASS.wagesName = "#Class_CWU_Wages"
	CLASS.description = "#Class_CWU_Desc"
	CLASS.defaultPhysDesc = "Wearing clothes. wow."
CLASS_CWU = CLASS:Register();
