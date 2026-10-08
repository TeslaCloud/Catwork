--- Defines the `ammo_buckshot` item, Shotgun Shells, which gives 16 rounds of `buckshot` ammo and is sold to the Elite
-- Overwatch Soldier class.

ITEM.baseItem = 'ammo_base'
ITEM.name = 'Shotgun Shells'
ITEM.PrintName = '#Item_AmmoBuckshot_PrintName'
ITEM.cost = 30
ITEM.classes = { CLASS_EOW }
ITEM.model = 'models/items/boxbuckshot.mdl'
ITEM.weight = 1
ITEM.uniqueID = 'ammo_buckshot'
ITEM.business = true
ITEM.ammoClass = 'buckshot'
ITEM.ammoAmount = 16
ITEM.description = '#Item_AmmoBuckshot_Description'
