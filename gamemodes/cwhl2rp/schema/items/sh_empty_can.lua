--- Defines the Empty Can junk item, `empty_can`, which has no behaviour of its own and is accepted as garbage by the
-- metal recycler.

ITEM.name = 'Empty Can'
ITEM.PrintName = '#Item_EmptyCan_PrintName'
ITEM.uniqueID = 'empty_can'
ITEM.cost = 0
ITEM.model = 'models/props_junk/garbage_metalcan001a.mdl'
ITEM.weight = 0.35
ITEM.business = false
ITEM.category = 'Junk'
ITEM.description = '#Item_EmptyCan_Description'

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
