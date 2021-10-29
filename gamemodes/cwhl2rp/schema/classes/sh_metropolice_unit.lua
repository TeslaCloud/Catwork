--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local CLASS = cw.class:New("#Class_MPF")
	CLASS.color = Color(50, 100, 150, 255)
	CLASS.wages = 10
	CLASS.factions = {FACTION_MPF}
	CLASS.isDefault = true
	CLASS.wagesName = "#Class_MPF_Wages"
	CLASS.description = "#Class_MPF_Desc"
	CLASS.defaultPhysDesc = "Wearing a metrocop jacket with a radio"
CLASS_MPU = CLASS:Register();
