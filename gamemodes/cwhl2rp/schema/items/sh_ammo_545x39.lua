--- Defines the `ammo_545x39` item, a box of 30 rifle rounds sold to the Elite Metropolice and Elite Overwatch Soldier
-- classes.
--
-- Its ammo class is `5.45x39mm`.

ITEM.baseItem = 'ammo_base'
ITEM.name = 'Ammo 545x39'
ITEM.PrintName = '#Item_Ammo545x39_PrintName'
ITEM.cost = 0
ITEM.classes = { CLASS_EMP, CLASS_EOW }
ITEM.model = 'models/items/boxmrounds.mdl'
ITEM.weight = 3
ITEM.access = 'V'
ITEM.uniqueID = 'ammo_545x39'
ITEM.business = true
ITEM.ammoClass = '5.45x39mm'
ITEM.ammoAmount = 30
ITEM.description = '#Item_Ammo545x39_Description'
