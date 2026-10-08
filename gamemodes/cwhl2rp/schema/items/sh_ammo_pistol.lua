--- Defines the `ammo_pistol` item, 9mm Pistol Bullets, which gives 30 rounds of `9x19mm` ammo and is sold to the Elite
-- Metropolice and Elite Overwatch Soldier classes.

ITEM.baseItem = 'ammo_base'
ITEM.name = '9mm Pistol Bullets'
ITEM.PrintName = '#Item_AmmoPistol_PrintName'
ITEM.cost = 20
ITEM.classes = { CLASS_EMP, CLASS_EOW }
ITEM.model = 'models/items/boxsrounds.mdl'
ITEM.weight = 1
ITEM.access = 'V'
ITEM.uniqueID = 'ammo_pistol'
ITEM.business = true
ITEM.ammoClass = '9x19mm'
ITEM.ammoAmount = 30
ITEM.description = '#Item_AmmoPistol_Description'
