--- Defines the Impulse Rifle Mk.1 weapon item, which gives the `sxbase_ar21` weapon and is sold to the Elite Overwatch
-- Soldier class.

ITEM.baseItem = 'weapon_base'
ITEM.name = 'Impulse Rifle Mk.1'
ITEM.PrintName = '#Item_WeaponAr21_PrintName'
ITEM.cost = 0
ITEM.model = 'models/weapons/w_irifle.mdl'
ITEM.weight = 4
ITEM.classes = { CLASS_EOW }
ITEM.weaponClass = 'sxbase_ar21'
ITEM.business = true
ITEM.description = '#Item_WeaponAr21_Description'
ITEM.isAttachment = true
ITEM.hasFlashlight = true
ITEM.loweredOrigin = Vector(3, 0, -4)
ITEM.loweredAngles = Angle(0, 45, 0)
ITEM.attachmentBone = 'ValveBiped.Bip01_Spine'
ITEM.attachmentOffsetAngles = Angle(0, 0, 0)
ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97)
ITEM.primaryAmmoClass = 'ar2'
