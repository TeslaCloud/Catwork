--- Defines the Empty Cup junk item, `empty_cup`, which is found in garbage piles and has no behaviour of its own.

ITEM.name = 'Empty Cup'
ITEM.PrintName = '#Item_EmptyCup_PrintName'
ITEM.uniqueID = 'empty_cup'
ITEM.cost = 0
ITEM.model = 'models/props_junk/garbage_coffeemug001a.mdl'
ITEM.weight = 0.3
ITEM.business = false
ITEM.category = 'Junk'
ITEM.description = '#Item_EmptyCup_Description'

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
