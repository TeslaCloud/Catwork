--- Defines the `Tomato Seeds` item (`seed_tomato`), a `seeds_base` item whose plant ripens in 1800 to 3000 seconds and
-- yields `seed_tomato` and `tomato`.

ITEM.baseItem = 'seeds_base'
ITEM.name = 'Tomato Seeds'
ITEM.PrintName = '#Item_SeedTomato_PrintName'
ITEM.description = '#Item_SeedTomato_Description'
ITEM.model = 'models/props_lab/box01a.mdl'
ITEM.uniqueID = 'seed_tomato'
ITEM.PlantModel = 'models/props/de_inferno/claypot03_damage_01.mdl'
ITEM.PlantName = '#Farming_Plant_Tomato'
ITEM.GrowTime = { 1800, 3000 }
ITEM.Harvest = { 'seed_tomato', 'tomato' }
