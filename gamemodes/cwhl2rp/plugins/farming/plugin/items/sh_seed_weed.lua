--- Defines the `Weed Seeds` item (`seed_weed`), a `seeds_base` item whose plant ripens in 1800 to 2000 seconds and
-- yields `seed_weed` and `weed`.

ITEM.baseItem = 'seeds_base'
ITEM.name = 'Weed Seeds'
ITEM.PrintName = '#Item_SeedWeed_PrintName'
ITEM.description = '#Item_SeedWeed_Description'
ITEM.model = 'models/props_lab/box01a.mdl'
ITEM.uniqueID = 'seed_weed'
ITEM.PlantModel = 'models/props/de_inferno/fountain_bowl_p6.mdl'
ITEM.PlantName = '#Farming_Plant_Weed'
ITEM.GrowTime = { 1800, 2000 }
ITEM.Harvest = { 'seed_weed', 'weed' }
