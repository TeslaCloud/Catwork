--- Defines the Empty Tin Can junk item, `empty_tin_can`, a plastic jar that is left behind by citizen supplements and
-- has no behaviour of its own.

ITEM.name = 'Empty Tin Can'
ITEM.PrintName = '#Item_EmptyPlastic2_PrintName'
ITEM.uniqueID = 'empty_tin_can'
ITEM.cost = 0
ITEM.model = 'models/props_lab/jar01b.mdl'
ITEM.weight = 0.2
ITEM.business = false
ITEM.category = 'Junk'
ITEM.description = '#Item_EmptyPlastic2_Description'

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
