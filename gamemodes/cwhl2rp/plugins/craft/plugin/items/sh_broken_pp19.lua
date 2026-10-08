--- Defines the Broken PP19 item (`broken_pp19`) of the Craft plugin, a crafting material that the `blueprint_pp19`
-- blueprint rebuilds into the `sxbase_pp19` weapon.

ITEM.name = 'Broken PP19'
ITEM.PrintName = '#Item_BrokenPp19_Name'
ITEM.model = 'models/weapons/w_smg_biz.mdl'
ITEM.weight = 1
ITEM.category = 'Materials'
ITEM.description = '#Item_BrokenPp19_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
