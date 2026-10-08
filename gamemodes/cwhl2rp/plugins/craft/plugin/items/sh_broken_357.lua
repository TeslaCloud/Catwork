--- Defines the Broken 357 Magnum item (`broken_357`) of the Craft plugin, a broken revolver in the Materials category
-- that no blueprint uses yet.

ITEM.name = 'Broken 357 Magnum'
ITEM.PrintName = '#Item_Broken357_Name'
ITEM.model = 'models/weapons/w_357.mdl'
ITEM.weight = 2
ITEM.category = 'Materials'
ITEM.description = '#Item_Broken357_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
