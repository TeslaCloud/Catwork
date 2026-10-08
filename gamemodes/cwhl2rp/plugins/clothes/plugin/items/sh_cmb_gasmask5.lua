--- Defines the Officer Mask item (`cmb_gasmask5`), a Combine-wearable mask based on `bodygroup_base` that sets
-- bodygroup 2 to 5 and can only be worn over an item in bodygroup 5, the Protective Collar.
--
-- Originally written for the Global Cooldown community.

ITEM.baseItem = 'bodygroup_base'
ITEM.name = 'gasmask5'
ITEM.PrintName = '#ITEM_Cmb_Gasmask_5_Name'
ITEM.cost = 150
ITEM.model = 'models/half_life2/jnstudio/props/gasmask_5.mdl'
ITEM.plural = '#ITEM_Cmb_Gasmask_5_Plural'
ITEM.weight = 1
ITEM.uniqueID = 'cmb_gasmask5'
ITEM.business = false
ITEM.bodyGroup = 2
ITEM.bodyGroupVal = 5
ITEM.description = ''
ITEM.isCombine = true
ITEM.requiredBG = { 5, 1 }
