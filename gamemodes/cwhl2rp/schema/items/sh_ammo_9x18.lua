--- Defines the `ammo_9x18` item, a box of 30 rounds of `9x18mm` ammo sold to the Elite Metropolice and Elite Overwatch
-- Soldier classes.

ITEM.baseItem = 'ammo_base'
ITEM.name = '9x18 Bullets'
ITEM.PrintName = '#Item_Ammo9x18_PrintName'
ITEM.cost = 20
ITEM.classes = { CLASS_EMP, CLASS_EOW }
ITEM.model = 'models/items/boxsrounds.mdl'
ITEM.weight = 1
ITEM.access = 'V'
ITEM.uniqueID = 'ammo_9x18'
ITEM.business = true
ITEM.ammoClass = '9x18mm'
ITEM.ammoAmount = 30
ITEM.description = '#Item_Ammo9x18_Description'
