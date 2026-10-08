--- Defines the CP Unit Mask item (`cmb_gasmask1`), a Combine-wearable mask based on `bodygroup_base` that sets
-- bodygroup 2 to 1 and can only be worn over an item in bodygroup 5, the Protective Collar.
--
-- Originally written for the Global Cooldown community.

ITEM.baseItem = 'bodygroup_base'
ITEM.name = 'gasmask1'
ITEM.PrintName = '#ITEM_Cmb_Gasmask_1_Name'
ITEM.cost = 150
ITEM.model = 'models/half_life2/jnstudio/props/gasmask_1.mdl'
ITEM.plural = '#ITEM_Cmb_Gasmask_1_Plural'
ITEM.weight = 0.5
ITEM.uniqueID = 'cmb_gasmask1'
ITEM.business = false
ITEM.bodyGroup = 2
ITEM.bodyGroupVal = 1
ITEM.description = ''
ITEM.isCombine = true
ITEM.requiredBG = { 5, 1 }
