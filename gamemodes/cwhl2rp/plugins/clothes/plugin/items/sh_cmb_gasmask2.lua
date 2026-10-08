--- Defines the STORM Division Mask item (`cmb_gasmask2`), a Combine-wearable mask based on `bodygroup_base` that sets
-- bodygroup 2 to 2 and can only be worn over an item in bodygroup 5, the Protective Collar.
--
-- Originally written for the Global Cooldown community.

ITEM.baseItem = 'bodygroup_base'
ITEM.name = 'gasmask2'
ITEM.PrintName = '#ITEM_Cmb_Gasmask_2_Name'
ITEM.cost = 150
ITEM.model = 'models/half_life2/jnstudio/props/gasmask_2.mdl'
ITEM.plural = '#ITEM_Cmb_Gasmask_2_Plural'
ITEM.weight = 0.5
ITEM.uniqueID = 'cmb_gasmask2'
ITEM.business = false
ITEM.bodyGroup = 2
ITEM.bodyGroupVal = 2
ITEM.description = ''
ITEM.isCombine = true
ITEM.requiredBG = { 5, 1 }
