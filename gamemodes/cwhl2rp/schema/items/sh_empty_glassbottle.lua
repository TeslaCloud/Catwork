--- Defines the Empty Glass Bottle junk item, `empty_glass_bottle`, which is left behind by beer and vodka, serves as a
-- crafting material and has no behaviour of its own.

ITEM.name = 'Empty Glass Bottle'
ITEM.PrintName = '#Item_EmptyGlassbottle_PrintName'
ITEM.uniqueID = 'empty_glass_bottle'
ITEM.cost = 0
ITEM.model = 'models/props_junk/garbage_glassbottle003a.mdl'
ITEM.weight = 0.3
ITEM.business = false
ITEM.category = 'Junk'
ITEM.description = '#Item_EmptyGlassbottle_Description'

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
