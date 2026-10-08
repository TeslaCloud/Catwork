--- Defines the Broken USP Match item (`broken_uspmatch`) of the Craft plugin, a crafting material that the
-- `blueprint_uspmatch` blueprint rebuilds into the `sxbase_uspmatch` weapon.

ITEM.name = 'Broken USP Match'
ITEM.PrintName = '#Item_BrokenUspmatch_Name'
ITEM.model = 'models/weapons/w_uspmatch.mdl'
ITEM.weight = 1
ITEM.category = 'Materials'
ITEM.description = '#Item_BrokenUspmatch_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
