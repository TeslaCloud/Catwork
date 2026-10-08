--- Defines the Broken M9 item (`broken_m9`) of the Craft plugin, a crafting material that the `blueprint_m9` blueprint
-- rebuilds into the `sxbase_m9` weapon.

ITEM.name = 'Broken M9'
ITEM.PrintName = '#Item_BrokenM9_Name'
ITEM.model = 'models/weapons/w_m9beretta.mdl'
ITEM.weight = 0.5
ITEM.category = 'Materials'
ITEM.description = '#Item_BrokenM9_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
