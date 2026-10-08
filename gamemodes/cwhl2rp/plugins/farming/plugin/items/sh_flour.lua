--- Defines the `Flour` item (`flour`) of the Farming plugin, a crafting material with no use of its own.

ITEM.name = 'Flour'
ITEM.PrintName = '#Item_Flour_PrintName'
ITEM.cost = 15
ITEM.model = 'models/bioshockinfinite/topcorn_bag.mdl'
ITEM.weight = 0.1
ITEM.access = 'v'
ITEM.uniqueID = 'flour'
ITEM.category = 'Materials'
ITEM.business = true
ITEM.description = '#Item_Flour_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
