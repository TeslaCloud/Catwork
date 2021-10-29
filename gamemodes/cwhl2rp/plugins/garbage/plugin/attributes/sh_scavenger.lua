--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local ATTRIBUTE = cw.attribute:New()
	ATTRIBUTE.name = "Мусорщик"
	ATTRIBUTE.maximum = 75
	ATTRIBUTE.uniqueID = "scv"
	ATTRIBUTE.description = "Влияет на шанс найти что-то ценное в мусоре."
	ATTRIBUTE.isOnCharScreen = false
	ATTRIBUTE.category = "Навыки"
ATB_SCAVENGER = cw.attribute:Register(ATTRIBUTE);
