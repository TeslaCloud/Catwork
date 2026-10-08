--- Defines the `ammo_xbowbolt` item, Crossbow Bolts, which gives 4 rounds of `xbowbolt` ammo and is not sold in the
-- business menu.

ITEM.baseItem = 'ammo_base'
ITEM.name = 'Crossbow Bolts'
ITEM.PrintName = '#ITEM_Crossbow_Bolts'
ITEM.cost = 50
ITEM.model = 'models/items/crossbowrounds.mdl'
ITEM.access = 'V'
ITEM.weight = 1
ITEM.uniqueID = 'ammo_xbowbolt'
ITEM.business = false
ITEM.ammoClass = 'xbowbolt'
ITEM.ammoAmount = 4
ITEM.description = '#ITEM_Crossbow_Bolts_Desc'
