--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local ATTRIBUTE = cw.attribute:New()
	ATTRIBUTE.name = "#Attribute_Agility"
	ATTRIBUTE.maximum = 75
	ATTRIBUTE.uniqueID = "agt"
	ATTRIBUTE.description = "#Attribute_Agility_Desc"
	ATTRIBUTE.isOnCharScreen = true
	ATTRIBUTE.category = "Характеристики"
ATB_AGILITY = cw.attribute:Register(ATTRIBUTE);
