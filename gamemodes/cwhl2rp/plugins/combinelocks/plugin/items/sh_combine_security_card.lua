ITEM.name = 'Combine Security Clearance Card'
ITEM.PrintName = '#Item_CombineSecurityCard_PrintName'
ITEM.uniqueID = 'combine_security_card'
ITEM.model = 'models/gibs/metal_gib4.mdl'
ITEM.weight = 0.1
ITEM.business = true
ITEM.description = '#Item_CombineSecurityCard_Description'
ITEM.category = '#Item_Category_CardsAndLocks'

--- Called when the security card is dropped; does nothing, so it can be dropped freely.
function ITEM:OnDrop(player, position) end
