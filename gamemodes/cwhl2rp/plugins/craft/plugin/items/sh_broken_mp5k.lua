--- Defines the Broken MP5K item (`broken_mp5k`) of the Craft plugin, a crafting material that the `blueprint_mp5k`
-- blueprint rebuilds into the `sxbase_mp5k` weapon.

ITEM.name = 'Broken MP5K'
ITEM.PrintName = '#Item_BrokenMp5k_Name'
ITEM.model = 'models/weapons/w_smg2.mdl'
ITEM.weight = 1
ITEM.category = 'Materials'
ITEM.description = '#Item_BrokenMp5k_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
