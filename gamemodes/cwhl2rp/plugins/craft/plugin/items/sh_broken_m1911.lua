--- Defines the Broken M1911 item (`broken_m1911`) of the Craft plugin, a crafting material that the `blueprint_m1911`
-- blueprint rebuilds into the `sxbase_m1911` weapon.

ITEM.name = 'Broken M1911'
ITEM.PrintName = '#Item_BrokenM1911_Name'
ITEM.model = 'models/weapons/w_1911_1.mdl'
ITEM.weight = 0.5
ITEM.category = 'Materials'
ITEM.description = '#Item_BrokenM1911_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
