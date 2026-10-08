--- Defines the Broken AK-74 item (`broken_ak74`) of the Craft plugin, a crafting material that the `blueprint_ak74`
-- blueprint rebuilds into the `sxbase_ak74` weapon.

ITEM.name = 'Broken AK-74'
ITEM.PrintName = '#Item_BrokenAk74_Name'
ITEM.model = 'models/weapons/w_ak74.mdl'
ITEM.weight = 3
ITEM.category = 'Materials'
ITEM.description = '#Item_BrokenAk74_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
