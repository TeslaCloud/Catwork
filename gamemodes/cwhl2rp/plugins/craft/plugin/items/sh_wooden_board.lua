--- Defines the Wooden Board item (`wooden_board`) of the Craft plugin, an item in the Materials category that is not
-- sold in the business menu and that no blueprint uses yet.

ITEM.name = 'Wooden Board'
ITEM.PrintName = '#Item_WoodenBoard_Name'
ITEM.uniqueID = 'wooden_board'
ITEM.model = 'models/gibs/furniture_gibs/furnituredrawer002a_gib07.mdl'
ITEM.weight = 1
ITEM.category = 'Materials'
ITEM.business = false
ITEM.description = '#Item_WoodenBoard_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
