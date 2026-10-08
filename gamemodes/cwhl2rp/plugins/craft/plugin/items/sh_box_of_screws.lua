--- Defines the Box of Screws item (`box_of_screws`) of the Craft plugin, a crafting material used by every weapon
-- blueprint.

ITEM.name = 'Box of Screws'
ITEM.PrintName = '#Item_BoxOfScrews_Name'
ITEM.model = 'models/props_junk/cardboard_box004a.mdl'
ITEM.weight = 0.5
ITEM.category = 'Materials'
ITEM.description = '#Item_BoxOfScrews_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
