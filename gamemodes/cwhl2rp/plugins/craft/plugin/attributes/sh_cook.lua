--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local ATTRIBUTE = cw.attribute:New()
	ATTRIBUTE.name = "#Attribute_Cook"
	ATTRIBUTE.maximum = 100
	ATTRIBUTE.uniqueID = "cook"
	ATTRIBUTE.description = "#Attribute_Cook_Desc"
	ATTRIBUTE.isOnCharScreen = false
	ATTRIBUTE.category = "Навыки"
ATB_COOK = cw.attribute:Register(ATTRIBUTE);
