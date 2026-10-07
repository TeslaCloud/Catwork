--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local ATTRIBUTE = cw.attribute:New()
	ATTRIBUTE.name = "#Attribute_Farm"
	ATTRIBUTE.maximum = 100
	ATTRIBUTE.uniqueID = "farm"
	ATTRIBUTE.description = "#Attribute_Farm_Desc"
	ATTRIBUTE.isOnCharScreen = false
	ATTRIBUTE.category = "#AttributeCategory_Skills"
ATB_FARM = cw.attribute:Register(ATTRIBUTE)
