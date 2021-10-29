--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.baseItem = "weapon_base"
ITEM.name = "9mm Pistol"
ITEM.PrintName = "#ITEM_9mm_Pistol"
ITEM.cost = 100
ITEM.model = "models/weapons/w_pistol.mdl"
ITEM.weight = 1
ITEM.access = "V"
ITEM.classes = {CLASS_EMP, CLASS_EOW}
ITEM.weaponClass = "sxbase_uspmatch"
ITEM.business = true
ITEM.description = "#ITEM_9mm_Pistol_Desc"
ITEM.isAttachment = true
ITEM.loweredOrigin = Vector(3, 0, -4)
ITEM.loweredAngles = Angle(0, 45, 0)
ITEM.attachmentBone = "ValveBiped.Bip01_Pelvis"
ITEM.attachmentOffsetAngles = Angle(0, 0, 90)
ITEM.attachmentOffsetVector = Vector(0, 4, -8)
