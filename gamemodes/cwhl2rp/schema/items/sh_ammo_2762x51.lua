--- Defines the `ammo_2762x51` item, a crate of 100 machine gun rounds sold to the Elite Metropolice and Elite Overwatch
-- Soldier classes.
--
-- It gives the same `7.62x51mm` ammo class as `ammo_762x51`, in a larger amount.

ITEM.baseItem = 'ammo_base'
ITEM.name = 'Ammo 762x51'
ITEM.PrintName = '#Item_Ammo2762x51_PrintName'
ITEM.cost = 0
ITEM.classes = { CLASS_EMP, CLASS_EOW }
ITEM.model = 'models/items/largeboxbrounds.mdl'
ITEM.weight = 4
ITEM.access = 'V'
ITEM.uniqueID = 'ammo_2762x51'
ITEM.business = true
ITEM.ammoClass = '7.62x51mm'
ITEM.ammoAmount = 100
ITEM.description = '#Item_Ammo2762x51_Description'
