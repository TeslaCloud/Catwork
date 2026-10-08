--- Defines the Crossbow weapon item, which gives the `weapon_crossbow` weapon and is not sold in the business menu.

ITEM.baseItem = 'weapon_base'
ITEM.name = 'Crossbow'
ITEM.PrintName = '#ITEM_Crossbow'
ITEM.cost = 400
ITEM.model = 'models/weapons/w_crossbow.mdl'
ITEM.weight = 5
ITEM.access = 'V'
ITEM.weaponClass = 'weapon_crossbow'
ITEM.business = false
ITEM.description = '#ITEM_Crossbow_Desc'
ITEM.isAttachment = true
ITEM.attachmentBone = 'ValveBiped.Bip01_Spine'
ITEM.loweredOrigin = Vector(3, 0, -4)
ITEM.loweredAngles = Angle(0, 45, 0)
ITEM.attachmentOffsetAngles = Angle(270, 0, 0)
ITEM.attachmentOffsetVector = Vector(3, 7, -3)
