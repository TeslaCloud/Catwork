--- Defines the `Weed` item (`weed`) of the Farming plugin, a crafting material with no use of its own.

ITEM.name = 'Weed'
ITEM.PrintName = '#Item_Weed_PrintName'
ITEM.cost = 15
ITEM.model = 'models/props_lab/box01a.mdl'
ITEM.weight = 0.1
ITEM.access = 'v'
ITEM.uniqueID = 'weed'
ITEM.category = 'Materials'
ITEM.business = true
ITEM.description = '#Item_Weed_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
