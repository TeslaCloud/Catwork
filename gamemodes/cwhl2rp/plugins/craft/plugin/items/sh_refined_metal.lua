--- Defines the Refined Metal item (`refined_metal`) of the Craft plugin, a crafting material smelted from
-- `reclaimed_metal` and used by the ammunition, tool and a few clothing blueprints.

ITEM.name = 'Refined Metal'
ITEM.PrintName = '#Item_RefinedMetal_Name'
ITEM.model = 'models/gibs/metal_gib2.mdl'
ITEM.weight = 1
ITEM.category = 'Materials'
ITEM.description = '#Item_RefinedMetal_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
