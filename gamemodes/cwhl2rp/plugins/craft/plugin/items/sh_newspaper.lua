--- Defines the Newspaper item (`newspaper`) of the Craft plugin, an item in the Materials category that no blueprint
-- uses yet.

ITEM.name = 'Newspaper'
ITEM.PrintName = '#Item_Newspaper_Name'
ITEM.model = 'models/props_junk/garbage_newspaper001a.mdl'
ITEM.weight = 0.4
ITEM.category = 'Materials'
ITEM.description = '#Item_Newspaper_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
