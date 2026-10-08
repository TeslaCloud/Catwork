--- Defines the Wooden Parts item (`wooden_parts`) of the Craft plugin, a crafting material that is not sold in the
-- business menu and is used to make `charcoal` and by the `blueprint_ak74` blueprint.

ITEM.name = 'Wooden Parts'
ITEM.PrintName = '#Item_WoodenParts_Name'
ITEM.model = 'models/gibs/furniture_gibs/furnituredrawer002a_gib03.mdl'
ITEM.weight = 0.25
ITEM.uniqueID = 'wooden_parts'
ITEM.category = 'Materials'
ITEM.business = false
ITEM.description = '#Item_WoodenParts_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
