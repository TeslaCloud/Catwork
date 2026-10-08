--- Defines the Sulphur item (`sulphur`) of the Craft plugin, a crafting material used to make `gunpowder`.

ITEM.name = 'Sulphur'
ITEM.PrintName = '#Item_Sulphur_Name'
ITEM.model = 'models/props_junk/garbage_bag001a.mdl'
ITEM.weight = 0.5
ITEM.category = 'Materials'
ITEM.description = '#Item_Sulphur_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
