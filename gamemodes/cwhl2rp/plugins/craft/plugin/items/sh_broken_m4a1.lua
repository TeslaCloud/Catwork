--- Defines the Broken M4A1 item (`broken_m4a1`) of the Craft plugin, a crafting material that the `blueprint_m4a1`
-- blueprint rebuilds into the `sxbase_m4a1` weapon.

ITEM.name = 'Broken M4A1'
ITEM.PrintName = '#Item_BrokenM4a1_Name'
ITEM.model = 'models/weapons/w_m4_1.mdl'
ITEM.weight = 2
ITEM.category = 'Materials'
ITEM.description = '#Item_BrokenM4a1_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
