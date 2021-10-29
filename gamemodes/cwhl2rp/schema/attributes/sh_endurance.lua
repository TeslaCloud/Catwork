--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local ATTRIBUTE = cw.attribute:New()
	ATTRIBUTE.name = "#Attribute_Endurance"
	ATTRIBUTE.maximum = 75
	ATTRIBUTE.uniqueID = "end"
	ATTRIBUTE.description = "#Attribute_Endurance_Desc"
	ATTRIBUTE.isOnCharScreen = true
	ATTRIBUTE.category = "Характеристики"
ATB_ENDURANCE = cw.attribute:Register(ATTRIBUTE);
