--- Defines the level 3 `Combine Lock Access Card` item (`combine_lock_access_3`) of the Combine Locks plugin, the pink
-- card that lets a non-Combine player open Combine locks with access level 3.

ITEM.name = 'Combine Lock Access Card'
ITEM.PrintName = '#Item_CombineLockAccess3_PrintName'
ITEM.uniqueID = 'combine_lock_access_3'
ITEM.model = 'models/gibs/metal_gib4.mdl'
ITEM.weight = 0.1
ITEM.classes = { CLASS_EMP, CLASS_EOW }
ITEM.business = true
ITEM.description = '#Item_CombineLockAccess3_Description'
ITEM.category = '#Item_Category_CardsAndLocks'

--- Called when the access card is dropped; does nothing, so it can be dropped freely.
function ITEM:OnDrop(player, position) end
