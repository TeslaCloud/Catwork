--- Defines the `Banana Seeds` item (`seed_banana`), a `seeds_base` item whose plant ripens in 2800 to 3000 seconds and
-- yields `seed_banana` and `banana`.

ITEM.baseItem = 'seeds_base'
ITEM.name = 'Banana Seeds'
ITEM.PrintName = '#Item_SeedBanana_PrintName'
ITEM.description = '#Item_SeedBanana_Description'
ITEM.model = 'models/props_lab/box01a.mdl'
ITEM.uniqueID = 'seed_banana'
ITEM.PlantModel = 'models/props/cs_office/plant01_p1.mdl'
ITEM.PlantName = '#Farming_Plant_Banana'
ITEM.GrowTime = { 2800, 3000 }
ITEM.Harvest = { 'seed_banana', 'banana' }
