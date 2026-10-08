--- Defines the MP7 Barska AN/PEQ-15 weapon item, which gives the `sxbase_mp7_bsk_ls` weapon and is sold to the Elite
-- Metropolice and Elite Overwatch Soldier classes.

ITEM.baseItem = 'weapon_base'
ITEM.name = 'MP7 Barska AN/PEQ-15'
ITEM.PrintName = '#Item_SxbaseMp7bskls_PrintName'
ITEM.cost = 0
ITEM.model = 'models/weapons/items/mp7_bsk_ls.mdl'
ITEM.weight = 2.5
ITEM.access = 'V'
ITEM.classes = { CLASS_EMP, CLASS_EOW }
ITEM.weaponClass = 'sxbase_mp7_bsk_ls'
ITEM.business = true
ITEM.description = '#Item_SxbaseMp7bskls_Description'
ITEM.isAttachment = true
ITEM.hasFlashlight = true
ITEM.loweredOrigin = Vector(3, 0, -4)
ITEM.loweredAngles = Angle(0, 45, 0)
ITEM.attachmentBone = 'ValveBiped.Bip01_Spine'
ITEM.attachmentOffsetAngles = Angle(0, 0, 180)
ITEM.attachmentOffsetVector = Vector(-2, 5, 4)
