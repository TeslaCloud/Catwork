--- Defines the Broken Shotgun item (`broken_shotgun`) of the Craft plugin, a crafting material that the
-- `blueprint_shotgun` blueprint rebuilds into the `sxbase_spas12` weapon.

ITEM.name = 'Broken Shotgun'
ITEM.PrintName = '#Item_BrokenShotgun_Name'
ITEM.model = 'models/weapons/w_shotgun.mdl'
ITEM.weight = 4
ITEM.category = 'Materials'
ITEM.description = '#Item_BrokenShotgun_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
