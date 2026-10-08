--- Defines the Reclaimed Metal item (`reclaimed_metal`) of the Craft plugin, a crafting material smelted from
-- `scrap_metal` and used by the weapon blueprints and to make `refined_metal`.

ITEM.name = 'Reclaimed Metal'
ITEM.PrintName = '#Item_ReclaimedMetal_Name'
ITEM.model = 'models/props_lab/pipesystem03a.mdl'
ITEM.weight = 1
ITEM.category = 'Materials'
ITEM.description = '#Item_ReclaimedMetal_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
