--- Defines the 9mm Pistol weapon item, which gives the `sxbase_uspmatch` weapon and is sold to the Elite Metropolice
-- and Elite Overwatch Soldier classes.

ITEM.baseItem = 'weapon_base'
ITEM.name = '9mm Pistol'
ITEM.PrintName = '#ITEM_9mm_Pistol'
ITEM.cost = 100
ITEM.model = 'models/weapons/w_pistol.mdl'
ITEM.weight = 1
ITEM.access = 'V'
ITEM.classes = { CLASS_EMP, CLASS_EOW }
ITEM.weaponClass = 'sxbase_uspmatch'
ITEM.business = true
ITEM.description = '#ITEM_9mm_Pistol_Desc'
ITEM.isAttachment = true
ITEM.loweredOrigin = Vector(3, 0, -4)
ITEM.loweredAngles = Angle(0, 45, 0)
ITEM.attachmentBone = 'ValveBiped.Bip01_Pelvis'
ITEM.attachmentOffsetAngles = Angle(0, 0, 90)
ITEM.attachmentOffsetVector = Vector(0, 4, -8)
