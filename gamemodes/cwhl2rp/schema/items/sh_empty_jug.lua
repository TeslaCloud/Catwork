--- Defines the Empty Jug junk item, `empty_jug`, which is left behind by a milk jug and has no behaviour of its own.

ITEM.name = 'Empty Jug'
ITEM.PrintName = '#Item_EmptyJug_PrintName'
ITEM.uniqueID = 'empty_jug'
ITEM.cost = 0
ITEM.model = 'models/props_junk/garbage_milkcarton001a.mdl'
ITEM.weight = 0.38
ITEM.business = false
ITEM.category = 'Junk'
ITEM.description = '#Item_EmptyJug_Description'

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
