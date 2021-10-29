--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local ATTRIBUTE = cw.attribute:New()
	ATTRIBUTE.name = "#Attribute_Repair"
	ATTRIBUTE.maximum = 100
	ATTRIBUTE.uniqueID = "rem"
	ATTRIBUTE.description = "#Attribute_Repair_Desc"
	ATTRIBUTE.isOnCharScreen = false
	ATTRIBUTE.category = "Навыки"
ATB_REPAIR = cw.attribute:Register(ATTRIBUTE);
