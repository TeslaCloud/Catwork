--- Defines the Energy Cell item (`energy_cell`) of the Craft plugin, a crafting material used by the handheld radio,
-- flashlight, breaching charge and pulse rifle ammunition blueprints.

ITEM.name = 'Energy Cell'
ITEM.PrintName = '#Item_EnergyCell_Name'
ITEM.model = 'models/items/battery.mdl'
ITEM.weight = 0.5
ITEM.category = 'Materials'
ITEM.description = '#Item_EnergyCell_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
