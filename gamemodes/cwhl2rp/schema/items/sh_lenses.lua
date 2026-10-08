--- Defines the Contact Lenses item, `lenses`, which has no behaviour of its own; the framework's `PlayerHasLenses` hook
-- checks whether the local player carries it.

ITEM.name = 'Contact Lenses'
ITEM.PrintName = '#Item_Lenses_PrintName'
ITEM.cost = 0
ITEM.model = 'models/props_lab/box01a.mdl'
ITEM.weight = 0.01
ITEM.access = 'v'
ITEM.category = 'Other'
ITEM.business = true
ITEM.description = '#Item_Lenses_Description'

--- Lets the item be dropped; nothing else happens.
function ITEM:OnDrop(player, position) end
