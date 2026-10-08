--- Defines the `Corn Seeds` item (`seed_corn`), a `seeds_base` item whose plant ripens in 3200 to 4000 seconds and
-- yields `seed_corn` and `corn`.

ITEM.baseItem = 'seeds_base'
ITEM.name = 'Corn Seeds'
ITEM.PrintName = '#Item_SeedCorn_PrintName'
ITEM.description = '#Item_SeedCorn_Description'
ITEM.model = 'models/props_lab/box01a.mdl'
ITEM.uniqueID = 'seed_corn'
ITEM.PlantModel = 'models/props/de_inferno/fountain_bowl_p6.mdl'
ITEM.PlantName = '#Farming_Plant_Corn'
ITEM.GrowTime = { 3200, 4000 }
ITEM.Harvest = { 'seed_corn', 'corn' }
