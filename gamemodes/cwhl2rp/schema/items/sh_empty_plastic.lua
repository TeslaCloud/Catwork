--- Defines the Empty Plastic Bottle junk item, `empty_plastic_bottle`, which is left behind by a large soda and has no
-- behaviour of its own.

ITEM.name = 'Empty Plastic Bottle'
ITEM.PrintName = '#Item_EmptyPlastic_PrintName'
ITEM.uniqueID = 'empty_plastic_bottle'
ITEM.cost = 0
ITEM.model = 'models/props_junk/garbage_plasticbottle003a.mdl'
ITEM.weight = 0.5
ITEM.business = false
ITEM.category = 'Junk'
ITEM.description = '#Item_EmptyPlastic_Description'

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
