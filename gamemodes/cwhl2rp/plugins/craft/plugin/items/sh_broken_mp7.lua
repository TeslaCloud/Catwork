--- Defines the Broken MP7 item (`broken_mp7`) of the Craft plugin, a crafting material that the `blueprint_mp7`
-- blueprint rebuilds into the `sxbase_mp7` weapon.

ITEM.name = 'Broken MP7'
ITEM.PrintName = '#Item_BrokenMp7_Name'
ITEM.model = 'models/weapons/w_hkmp7.mdl'
ITEM.weight = 1
ITEM.category = 'Materials'
ITEM.description = '#Item_BrokenMp7_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
