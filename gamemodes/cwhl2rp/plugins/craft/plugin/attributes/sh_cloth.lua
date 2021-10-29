--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local ATTRIBUTE = cw.attribute:New()
	ATTRIBUTE.name = "#Attribute_Cloth"
	ATTRIBUTE.maximum = 100
	ATTRIBUTE.uniqueID = "cloth"
	ATTRIBUTE.description = "#Attribute_Cloth_Desc"
	ATTRIBUTE.isOnCharScreen = false
	ATTRIBUTE.category = "Навыки"
ATB_CLOTH = cw.attribute:Register(ATTRIBUTE);
