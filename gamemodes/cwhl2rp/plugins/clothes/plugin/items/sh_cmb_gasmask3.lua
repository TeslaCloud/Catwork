--- Defines the HELIX/GRID Division Mask item (`cmb_gasmask3`), a Combine-wearable mask based on `bodygroup_base` that
-- sets bodygroup 2 to 3 and can only be worn over an item in bodygroup 5, the Protective Collar.
--
-- Originally written for the Global Cooldown community.

ITEM.baseItem = 'bodygroup_base'
ITEM.name = 'gasmask3'
ITEM.PrintName = '#ITEM_Cmb_Gasmask_3_Name'
ITEM.cost = 150
ITEM.model = 'models/half_life2/jnstudio/props/gasmask_3.mdl'
ITEM.plural = '#ITEM_Cmb_Gasmask_3_Plural'
ITEM.weight = 1
ITEM.uniqueID = 'cmb_gasmask3'
ITEM.business = false
ITEM.bodyGroup = 2
ITEM.bodyGroupVal = 3
ITEM.description = ''
ITEM.isCombine = true
ITEM.requiredBG = { 5, 1 }
