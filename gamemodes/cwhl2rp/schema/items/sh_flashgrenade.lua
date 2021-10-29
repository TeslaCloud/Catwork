--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.baseItem = "grenade_base"
ITEM.name = "Flash"
ITEM.PrintName = "#ITEM_Flash"
ITEM.cost = 25
ITEM.classes = {CLASS_EMP, CLASS_EOW}
ITEM.model = "models/items/grenadeammo.mdl"
ITEM.weight = 0.8
ITEM.uniqueID = "sxbase_fg"
ITEM.business = true
ITEM.description = "#ITEM_Flash_Desc"
ITEM.isAttachment = true
ITEM.loweredOrigin = Vector(3, 0, -4)
ITEM.loweredAngles = Angle(0, 45, 0)
ITEM.attachmentBone = "ValveBiped.Bip01_Pelvis"
ITEM.attachmentOffsetAngles = Angle(90, 0, 0)
ITEM.attachmentOffsetVector = Vector(0, 6.55, 8.72)
