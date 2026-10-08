--- Defines the Empty Carton junk item, `empty_carton`, which is left behind by a milk carton or popcorn and has no
-- behaviour of its own.

ITEM.name = 'Empty Carton'
ITEM.PrintName = '#Item_EmptyCarton_PrintName'
ITEM.uniqueID = 'empty_carton'
ITEM.cost = 0
ITEM.model = 'models/props_junk/garbage_milkcarton002a.mdl'
ITEM.weight = 0.25
ITEM.business = false
ITEM.category = 'Junk'
ITEM.description = '#Item_EmptyCarton_Description'

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
