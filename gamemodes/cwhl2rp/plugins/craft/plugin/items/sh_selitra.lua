--- Defines the Selitra item (`selitra`) of the Craft plugin, saltpeter, a crafting material used to make `gunpowder`.

ITEM.name = 'Selitra'
ITEM.PrintName = '#Item_Selitra_Name'
ITEM.model = 'models/props_junk/garbage_bag001a.mdl'
ITEM.weight = 0.5
ITEM.category = 'Materials'
ITEM.description = '#Item_Selitra_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
