--- Defines the Broken HK-21 item (`broken_hk21`) of the Craft plugin, a crafting material that the `blueprint_hk21`
-- blueprint rebuilds into the `sxbase_hmg` weapon.

ITEM.name = 'Broken HK-21'
ITEM.PrintName = '#Item_BrokenHk21_Name'
ITEM.model = 'models/weapons/w_hmg.mdl'
ITEM.weight = 6
ITEM.category = 'Materials'
ITEM.description = '#Item_BrokenHk21_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
