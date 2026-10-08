--- Defines the HK21 machine gun item, which gives the `sxbase_hmg` weapon and is sold to the Elite Overwatch Soldier
-- class.

ITEM.baseItem = 'weapon_base'
ITEM.name = 'HK21'
ITEM.PrintName = '#Item_WeaponHk21_PrintName'
ITEM.cost = 400
ITEM.model = 'models/weapons/w_hmg.mdl'
ITEM.weight = 8
ITEM.classes = { CLASS_EOW }
ITEM.weaponClass = 'sxbase_hmg'
ITEM.business = true
ITEM.description = '#Item_WeaponHk21_Description'
ITEM.isAttachment = true
ITEM.loweredOrigin = Vector(3, 0, -4)
ITEM.loweredAngles = Angle(0, 45, 0)
ITEM.attachmentBone = 'ValveBiped.Bip01_Spine'
ITEM.attachmentOffsetAngles = Angle(0, 0, 0)
ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97)
