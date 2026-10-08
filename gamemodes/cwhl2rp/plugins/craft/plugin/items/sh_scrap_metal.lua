--- Defines the Scrap Metal item (`scrap_metal`) of the Craft plugin, a crafting material smelted from empty cans and
-- used to make `reclaimed_metal` and buckshot.

ITEM.name = 'Scrap Metal'
ITEM.PrintName = '#Item_ScrapMetal_Name'
ITEM.model = 'models/gibs/scanner_gib02.mdl'
ITEM.weight = 0.8
ITEM.category = 'Materials'
ITEM.description = '#Item_ScrapMetal_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
