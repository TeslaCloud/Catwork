--- Defines the MP7A1 submachine gun item, which gives the `sxbase_smg` weapon (the same weapon and model as the MP7
-- item) and is sold to the Elite Metropolice and Elite Overwatch Soldier classes.

ITEM.baseItem = 'weapon_base'
ITEM.name = 'MP7A1'
ITEM.PrintName = '#Item_WeaponMp7a1_PrintName'
ITEM.cost = 0
ITEM.model = 'models/weapons/w_smg1.mdl'
ITEM.weight = 2.5
ITEM.access = 'V'
ITEM.classes = { CLASS_EMP, CLASS_EOW }
ITEM.weaponClass = 'sxbase_smg'
ITEM.business = true
ITEM.description = '#Item_WeaponMp7a1_Description'
ITEM.isAttachment = true
ITEM.hasFlashlight = true
ITEM.loweredOrigin = Vector(3, 0, -4)
ITEM.loweredAngles = Angle(0, 45, 0)
ITEM.attachmentBone = 'ValveBiped.Bip01_Spine'
ITEM.attachmentOffsetAngles = Angle(0, 0, 180)
ITEM.attachmentOffsetVector = Vector(-2, 5, 4)
