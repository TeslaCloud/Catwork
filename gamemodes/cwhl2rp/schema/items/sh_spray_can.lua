--- Defines the Spray Can item, which a player must carry to use their spray and has no behaviour of its own.

ITEM.name = 'Spray Can'
ITEM.PrintName = '#ITEM_Spray_Can'
ITEM.cost = 15
ITEM.model = 'models/sprayca2.mdl'
ITEM.weight = 0.4
ITEM.access = 'v'
ITEM.category = 'Reusables'
ITEM.business = true
ITEM.description = '#ITEM_Spray_Can_Desc'

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
