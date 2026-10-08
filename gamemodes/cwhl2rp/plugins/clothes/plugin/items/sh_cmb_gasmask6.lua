--- Defines the CmD Mask item (`cmb_gasmask6`), a Combine-wearable mask based on `bodygroup_base` that sets bodygroup 2
-- to 6 and can only be worn over an item in bodygroup 5, the Protective Collar.
--
-- Originally written for the Global Cooldown community.

ITEM.baseItem = 'bodygroup_base'
ITEM.name = 'gasmask6'
ITEM.PrintName = '#ITEM_Cmb_Gasmask_6_Name'
ITEM.cost = 150
ITEM.model = 'models/half_life2/jnstudio/props/gasmask_6.mdl'
ITEM.plural = '#ITEM_Cmb_Gasmask_6_Plural'
ITEM.weight = 1
ITEM.uniqueID = 'cmb_gasmask6'
ITEM.business = false
ITEM.bodyGroup = 2
ITEM.bodyGroupVal = 6
ITEM.description = ''
ITEM.isCombine = true
ITEM.requiredBG = { 5, 1 }
