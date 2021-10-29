--[[
	Catwork © 2016 Some good coders
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.

local ATTRIBUTE = cw.attribute:New()
	ATTRIBUTE.name = "Ближний бой"
	ATTRIBUTE.maximum = 100
	ATTRIBUTE.uniqueID = "melee"
	ATTRIBUTE.description = "Определяет, как хорошо Вы владеете холодным оружием и рукопашным боем."
	ATTRIBUTE.isOnCharScreen = false
	ATTRIBUTE.category = "Навыки"
ATB_MELEE = cw.attribute:Register(ATTRIBUTE)
--]]
