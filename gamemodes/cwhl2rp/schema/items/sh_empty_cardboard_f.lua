--- Defines the Empty Cardboard box junk item, `empty_cardboard`, which is left behind by the loyalist and premium
-- supplements and has no behaviour of its own.

ITEM.name = 'Empty Cardboard box'
ITEM.PrintName = '#Item_EmptyCardboardF_PrintName'
ITEM.uniqueID = 'empty_cardboard'
ITEM.cost = 0
ITEM.model = 'models/bioshockinfinite/hext_cereal_box_cornflakes.mdl'
ITEM.weight = 0.1
ITEM.business = false
ITEM.category = 'Junk'
ITEM.description = '#Item_EmptyCardboardF_Description'

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
