--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local CLASS = cw.class:New("#Class_OverwatchSoldierElite")
	CLASS.color = Color(150, 50, 50, 255)
	CLASS.wages = 25
	CLASS.factions = {FACTION_OTA}
	CLASS.wagesName = "#Class_OverwatchSoldierElite_Wages"
	CLASS.maleModel = "models/combine_super_soldier.mdl"
	CLASS.description = "#Class_OverwatchSoldierElite_Desc"
	CLASS.defaultPhysDesc = "Wearing shiny Overwatch gear"
CLASS_EOW = CLASS:Register();
