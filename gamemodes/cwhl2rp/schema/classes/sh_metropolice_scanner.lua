--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local CLASS = cw.class:New("#Class_Scanner")
	CLASS.color = Color(50, 100, 150, 255)
	CLASS.factions = {FACTION_MPF}
	CLASS.description = "#Class_Scanner_Desc"
	CLASS.defaultPhysDesc = "Making beeping sounds"
CLASS_MPS = CLASS:Register();
