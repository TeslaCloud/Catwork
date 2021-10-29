--[[
	Catwork © 2016 Some good coders
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.

local ATTRIBUTE = cw.attribute:New()
	ATTRIBUTE.name = "Стрельба"
	ATTRIBUTE.maximum = 100
	ATTRIBUTE.uniqueID = "shoot"
	ATTRIBUTE.description = "Определяет, как хорошо Вы управляетесь с огнестрельным оружием."
	ATTRIBUTE.isOnCharScreen = false
	ATTRIBUTE.category = "Навыки"
ATB_SHOOT = cw.attribute:Register(ATTRIBUTE)
--]]
