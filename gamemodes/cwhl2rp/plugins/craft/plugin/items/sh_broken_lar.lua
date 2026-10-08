--- Defines the Broken LAR item (`broken_lar`) of the Craft plugin, a crafting material that the `blueprint_lar`
-- blueprint rebuilds into the `sxbase_lar` weapon.

ITEM.name = 'Broken LAR'
ITEM.PrintName = '#Item_BrokenLar_Name'
ITEM.model = 'models/rtb_weapons/w_sniper.mdl'
ITEM.weight = 3
ITEM.category = 'Materials'
ITEM.description = '#Item_BrokenLar_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
