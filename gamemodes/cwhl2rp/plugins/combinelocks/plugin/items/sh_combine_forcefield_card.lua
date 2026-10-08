--- Defines the `Combine Forcefield Pass` item (`combine_forcefield_card`) of the Combine Locks plugin, a card with no
-- use action whose bearer the Force Fields plugin lets through force fields.

ITEM.name = 'Combine Forcefield Pass'
ITEM.PrintName = '#Item_CombineForcefieldCard_PrintName'
ITEM.uniqueID = 'combine_forcefield_card'
ITEM.model = 'models/gibs/metal_gib4.mdl'
ITEM.weight = 0.1
ITEM.business = true
ITEM.description = '#Item_CombineForcefieldCard_Description'
ITEM.category = '#Item_Category_CardsAndLocks'

--- Called when the forcefield pass is dropped; does nothing, so it can be dropped freely.
function ITEM:OnDrop(player, position) end
