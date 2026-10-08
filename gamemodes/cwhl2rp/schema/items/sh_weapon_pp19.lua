--- Defines the PP19 weapon item, which gives the `sxbase_pp19` weapon and is sold to the Elite Metropolice and Elite
-- Overwatch Soldier classes.

ITEM.baseItem = 'weapon_base'
ITEM.name = 'PP19'
ITEM.PrintName = '#Item_WeaponPp19_PrintName'
ITEM.cost = 0
ITEM.model = 'models/weapons/w_smg_biz.mdl'
ITEM.weight = 2.7
ITEM.access = 'V'
ITEM.classes = { CLASS_EMP, CLASS_EOW }
ITEM.weaponClass = 'sxbase_pp19'
ITEM.business = true
ITEM.description = '#Item_WeaponPp19_Description'
ITEM.isAttachment = true
ITEM.hasFlashlight = true
ITEM.loweredOrigin = Vector(3, 0, -4)
ITEM.loweredAngles = Angle(0, 45, 0)
ITEM.attachmentBone = 'ValveBiped.Bip01_Spine'
ITEM.attachmentOffsetAngles = Angle(0, 0, 180)
ITEM.attachmentOffsetVector = Vector(-2, 5, 4)
