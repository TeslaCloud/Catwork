--- Defines the Grenade item on `grenade_base`, which gives the `sxbase_he` weapon and is sold to the Elite Overwatch
-- Soldier class.

ITEM.baseItem = 'grenade_base'
ITEM.name = 'Grenade'
ITEM.PrintName = '#ITEM_Granade'
ITEM.cost = 50
ITEM.model = 'models/items/grenadeammo.mdl'
ITEM.weight = 0.8
ITEM.access = 'V'
ITEM.classes = { CLASS_EOW }
ITEM.weaponClass = 'sxbase_he'
ITEM.business = true
ITEM.description = '#ITEM_Granade_Desc'
ITEM.isAttachment = true
ITEM.loweredOrigin = Vector(3, 0, -4)
ITEM.loweredAngles = Angle(0, 45, 0)
ITEM.attachmentBone = 'ValveBiped.Bip01_Pelvis'
ITEM.attachmentOffsetAngles = Angle(90, 0, 0)
ITEM.attachmentOffsetVector = Vector(0, 6.55, 8.72)
