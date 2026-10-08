--- Defines the level 4 `Combine Lock Access Card` item (`combine_lock_access_4`) of the Combine Locks plugin, the
-- orange card that lets a non-Combine player open Combine locks with access level 4.

ITEM.name = 'Combine Lock Access Card'
ITEM.PrintName = '#Item_CombineLockAccess4_PrintName'
ITEM.uniqueID = 'combine_lock_access_4'
ITEM.model = 'models/gibs/metal_gib4.mdl'
ITEM.weight = 0.1
ITEM.classes = { CLASS_EMP, CLASS_EOW }
ITEM.business = true
ITEM.description = '#Item_CombineLockAccess4_Description'
ITEM.category = '#Item_Category_CardsAndLocks'

--- Called when the access card is dropped; does nothing, so it can be dropped freely.
function ITEM:OnDrop(player, position) end
