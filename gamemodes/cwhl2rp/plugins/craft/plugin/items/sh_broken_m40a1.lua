--- Defines the Broken M40A1 item (`broken_m40a1`) of the Craft plugin, a crafting material that the `blueprint_m40a1`
-- blueprint rebuilds into the `sxbase_m40a1` weapon.

ITEM.name = 'Broken M40A1'
ITEM.PrintName = '#Item_BrokenM40a1_Name'
ITEM.model = 'models/items/m40a1.mdl'
ITEM.weight = 3
ITEM.category = 'Materials'
ITEM.description = '#Item_BrokenM40a1_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
