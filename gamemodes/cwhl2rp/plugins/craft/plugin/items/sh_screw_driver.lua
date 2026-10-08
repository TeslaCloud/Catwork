--- Defines the Screw Driver item (`screw_driver`) of the Craft plugin, a tool that the weapon blueprints and some
-- others require but do not use up.

ITEM.name = 'Screw Driver'
ITEM.PrintName = '#Item_ScrewDriver_Name'
ITEM.model = 'models/props_c17/TrapPropeller_Lever.mdl'
ITEM.weight = 0.6
ITEM.category = 'Tools'
ITEM.description = '#Item_ScrewDriver_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
