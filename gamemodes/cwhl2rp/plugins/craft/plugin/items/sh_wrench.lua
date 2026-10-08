--- Defines the Wrench item (`wrench`) of the Craft plugin, a tool that most weapon blueprints require but do not use
-- up.

ITEM.name = 'Wrench'
ITEM.PrintName = '#Item_Wrench_Name'
ITEM.model = 'models/props_c17/tools_wrench01a.mdl'
ITEM.weight = 1
ITEM.category = 'Tools'
ITEM.description = '#Item_Wrench_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
