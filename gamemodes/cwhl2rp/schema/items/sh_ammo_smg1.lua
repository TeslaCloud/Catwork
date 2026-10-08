--- Defines the `ammo_smg1` item, SMG Bullets, which gives 30 rounds of `smg1` ammo and is sold to the Elite Metropolice
-- and Elite Overwatch Soldier classes.

ITEM.baseItem = 'ammo_base'
ITEM.name = 'SMG Bullets'
ITEM.PrintName = '#Item_AmmoSmg1_PrintName'
ITEM.cost = 30
ITEM.classes = { CLASS_EMP, CLASS_EOW }
ITEM.model = 'models/items/boxmrounds.mdl'
ITEM.weight = 1.25
ITEM.access = 'V'
ITEM.uniqueID = 'ammo_smg1'
ITEM.business = true
ITEM.ammoClass = 'smg1'
ITEM.ammoAmount = 30
ITEM.description = '#Item_AmmoSmg1_Description'
