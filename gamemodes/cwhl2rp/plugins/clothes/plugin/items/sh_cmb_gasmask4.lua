--- Defines the VICE Division Mask item (`cmb_gasmask4`), a Combine-wearable mask based on `bodygroup_base` that sets
-- bodygroup 2 to 4 and can only be worn over an item in bodygroup 5, the Protective Collar.
--
-- Originally written for the Global Cooldown community.

ITEM.baseItem = 'bodygroup_base'
ITEM.name = 'gasmask4'
ITEM.PrintName = '#ITEM_Cmb_Gasmask_4_Name'
ITEM.cost = 150
ITEM.model = 'models/half_life2/jnstudio/props/gasmask_4.mdl'
ITEM.plural = '#ITEM_Cmb_Gasmask_4_Plural'
ITEM.weight = 1
ITEM.uniqueID = 'cmb_gasmask4'
ITEM.business = false
ITEM.bodyGroup = 2
ITEM.bodyGroupVal = 4
ITEM.description = ''
ITEM.isCombine = true
ITEM.requiredBG = { 5, 1 }
