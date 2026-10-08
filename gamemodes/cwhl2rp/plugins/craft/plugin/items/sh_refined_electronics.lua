--- Defines the Refined Electronics item (`refined_electronics`) of the Craft plugin, a crafting material made from
-- `scrap_electronics` and used by the handheld radio, health kit, breaching charge and welding tool blueprints.

ITEM.name = 'Refined Electronics'
ITEM.PrintName = '#Item_RefinedElectronics_Name'
ITEM.model = 'models/props_lab/reciever01b.mdl'
ITEM.weight = 0.5
ITEM.category = 'Materials'
ITEM.description = '#Item_RefinedElectronics_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
