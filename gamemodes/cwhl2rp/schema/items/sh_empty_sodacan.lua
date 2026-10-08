--- Defines the Empty Soda Can junk item, `empty_soda_can`, which is left behind by Breen's water and juices, serves as
-- a crafting material and has no behaviour of its own.

ITEM.name = 'Empty Soda Can'
ITEM.PrintName = '#Item_EmptySodacan_PrintName'
ITEM.uniqueID = 'empty_soda_can'
ITEM.cost = 0
ITEM.model = 'models/props_junk/popcan01a.mdl'
ITEM.weight = 0.16
ITEM.business = false
ITEM.category = 'Junk'
ITEM.description = '#Item_EmptySodacan_Description'

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
