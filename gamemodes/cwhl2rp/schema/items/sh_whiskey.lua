--- Defines the Whiskey item on `alcohol_base`, a drink that boosts the Stamina attribute by 2 through the base item's
-- drinking behaviour.

ITEM.baseItem = 'alcohol_base'
ITEM.name = 'Whiskey'
ITEM.PrintName = '#ITEM_Whiskey'
ITEM.cost = 13
ITEM.model = 'models/props_junk/garbage_glassbottle002a.mdl'
ITEM.weight = 1
ITEM.access = 'w'
ITEM.business = true
ITEM.attributes = { Stamina = 2 }
ITEM.description = '#ITEM_Whiskey_Desc'
ITEM.thirst = 15
