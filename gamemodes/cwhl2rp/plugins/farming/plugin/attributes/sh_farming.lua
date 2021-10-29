--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local ATTRIBUTE = cw.attribute:New()
	ATTRIBUTE.name = "Фермерство"
	ATTRIBUTE.maximum = 100
	ATTRIBUTE.uniqueID = "farm"
	ATTRIBUTE.description = "Влияет на шанс успешного сбора урожая."
	ATTRIBUTE.isOnCharScreen = false
	ATTRIBUTE.category = "Навыки"
ATB_FARM = cw.attribute:Register(ATTRIBUTE);
