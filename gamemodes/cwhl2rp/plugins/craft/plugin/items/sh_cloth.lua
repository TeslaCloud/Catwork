--- Defines the Cloth item (`cloth`) of the Craft plugin, a crafting material made by the `blueprint_cloth` blueprint
-- and used by the clothing, bag, backpack and bandage blueprints.

ITEM.name = 'Cloth'
ITEM.PrintName = '#Item_Cloth_Name'
ITEM.model = 'models/props_wasteland/prison_toiletchunk01f.mdl'
ITEM.weight = 0.5
ITEM.category = 'Materials'
ITEM.description = '#Item_Cloth_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
