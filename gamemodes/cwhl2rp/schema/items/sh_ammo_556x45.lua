--- Defines the `ammo_556x45` item, a box of 30 rifle rounds sold to the Elite Metropolice and Elite Overwatch Soldier
-- classes.
--
-- Its ammo class is `5.56x45mm`.

ITEM.baseItem = 'ammo_base'
ITEM.name = 'Ammo 5.56x45'
ITEM.PrintName = '#Item_Ammo556x45_PrintName'
ITEM.cost = 0
ITEM.classes = { CLASS_EMP, CLASS_EOW }
ITEM.model = 'models/items/boxmrounds.mdl'
ITEM.weight = 3
ITEM.access = 'V'
ITEM.uniqueID = 'ammo_556x45'
ITEM.business = true
ITEM.ammoClass = '5.56x45mm'
ITEM.ammoAmount = 30
ITEM.description = '#Item_Ammo556x45_Description'
