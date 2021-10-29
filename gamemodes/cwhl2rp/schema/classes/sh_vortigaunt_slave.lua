--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local CLASS = cw.class:New("#Class_Vortigaunt_Slave")
	CLASS.color = Color(150, 125, 100, 255)
	CLASS.factions = {FACTION_VORT}
	CLASS.isDefault = true
	CLASS.description = "#Class_Vortigaunt_Slave_Desc"
	CLASS.defaultPhysDesc = "Don't wear clothes."
CLASS_VORT_SLAVE = CLASS:Register();
