--- Defines the universal `Combine Lock Access Card` item (`combine_lock_access_x`) of the Combine Locks plugin, the red
-- card that opens Combine locks of every access level.

ITEM.name = 'Combine Lock Access Card'
ITEM.PrintName = '#Item_CombineLockAccessX_PrintName'
ITEM.uniqueID = 'combine_lock_access_x'
ITEM.model = 'models/gibs/metal_gib4.mdl'
ITEM.weight = 0.1
ITEM.classes = { CLASS_EMP, CLASS_EOW }
ITEM.business = true
ITEM.description = '#Item_CombineLockAccessX_Description'
ITEM.category = '#Item_Category_CardsAndLocks'

--- Called when the access card is dropped; does nothing, so it can be dropped freely.
function ITEM:OnDrop(player, position) end
