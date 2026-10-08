--- Defines the Gunpowder item (`gunpowder`) of the Craft plugin, a crafting material made from `selitra`, `sulphur` and
-- `charcoal` and used by the ammunition and breaching charge blueprints.

ITEM.name = 'Gunpowder'
ITEM.PrintName = '#Item_Gunpowder_Name'
ITEM.model = 'models/props_lab/box01a.mdl'
ITEM.weight = 0.2
ITEM.category = 'Materials'
ITEM.description = '#Item_Gunpowder_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
