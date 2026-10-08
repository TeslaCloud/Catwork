--- Defines the Broken MP7A1 item (`broken_smg1`) of the Craft plugin, a broken submachine gun in the Materials category
-- that no blueprint uses yet.

ITEM.name = 'Broken MP7A1'
ITEM.PrintName = '#Item_BrokenSmg1_Name'
ITEM.model = 'models/weapons/w_smg1.mdl'
ITEM.weight = 1
ITEM.category = 'Materials'
ITEM.description = '#Item_BrokenSmg1_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
