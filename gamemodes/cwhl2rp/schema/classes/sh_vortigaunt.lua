--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local CLASS = cw.class:New("#Class_Vortigaunt")
	CLASS.color = Color(150, 125, 100, 255)
	CLASS.factions = {FACTION_VORT}
	CLASS.description = "#Class_Vortigaunt_Desc"
	CLASS.defaultPhysDesc = "Don't wear clothes."
CLASS_VORT = CLASS:Register();
