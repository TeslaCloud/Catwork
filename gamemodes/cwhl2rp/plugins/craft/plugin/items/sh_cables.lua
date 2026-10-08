--- Defines the Cables item (`cables`) of the Craft plugin, a crafting material used by the backpack, bag, breaching
-- charge and zip tie blueprints.

ITEM.name = 'Cables'
ITEM.PrintName = '#Item_Cables_Name'
ITEM.model = 'models/Items/CrossbowRounds.mdl'
ITEM.weight = 0.2
ITEM.category = 'Materials'
ITEM.description = '#Item_Cables_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
