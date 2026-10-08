--- Defines the Plastic item (`plastic`) of the Craft plugin, a crafting material recycled from empty tin cans and
-- plastic bottles and used by medical, radio, gas mask and some weapon blueprints.

ITEM.name = 'Plastic'
ITEM.PrintName = '#Item_Plastic_Name'
ITEM.model = 'models/props_debris/metal_panelshard01b.mdl'
ITEM.weight = 0.5
ITEM.category = 'Materials'
ITEM.description = '#Item_Plastic_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
