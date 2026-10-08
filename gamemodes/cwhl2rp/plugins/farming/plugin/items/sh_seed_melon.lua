--- Defines the `Melon Seeds` item (`seed_melon`), a `seeds_base` item whose plant ripens in 3600 to 7200 seconds and
-- yields `seed_melon` and `melon`.

ITEM.baseItem = 'seeds_base'
ITEM.name = 'Melon Seeds'
ITEM.PrintName = '#Item_SeedMelon_PrintName'
ITEM.description = '#Item_SeedMelon_Description'
ITEM.model = 'models/props_lab/box01a.mdl'
ITEM.uniqueID = 'seed_melon'
ITEM.PlantModel = 'models/props/cs_office/plant01_p1.mdl'
ITEM.PlantName = '#Farming_Plant_Melon'
ITEM.GrowTime = { 3600, 7200 }
ITEM.Harvest = { 'seed_melon', 'melon' }
