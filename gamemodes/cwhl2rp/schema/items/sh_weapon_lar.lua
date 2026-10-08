--- Defines the LAR sniper rifle item, which gives the `sxbase_lar` weapon and is sold to the Elite Overwatch Soldier
-- class.

ITEM.baseItem = 'weapon_base'
ITEM.name = 'LAR'
ITEM.PrintName = '#Item_WeaponLar_PrintName'
ITEM.cost = 1000
ITEM.model = 'models/rtb_weapons/w_sniper.mdl'
ITEM.weight = 4
ITEM.classes = { CLASS_EOW }
ITEM.weaponClass = 'sxbase_lar'
ITEM.business = true
ITEM.description = '#Item_WeaponLar_Description'
ITEM.isAttachment = true
ITEM.hasFlashlight = false
ITEM.loweredOrigin = Vector(3, 0, -4)
ITEM.loweredAngles = Angle(0, 45, 0)
ITEM.attachmentBone = 'ValveBiped.Bip01_Spine'
ITEM.attachmentOffsetAngles = Angle(0, 0, 0)
ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97)
