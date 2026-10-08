--- Defines the `Orange Seeds` item (`seed_orange`), a `seeds_base` item whose plant ripens in 1337 to 1488 seconds and
-- yields `seed_orange` and `orange`.

ITEM.baseItem = 'seeds_base'
ITEM.name = 'Orange Seeds'
ITEM.PrintName = '#Item_SeedOrange_PrintName'
ITEM.description = '#Item_SeedOrange_Description'
ITEM.model = 'models/props_lab/box01a.mdl'
ITEM.uniqueID = 'seed_orange'
ITEM.PlantModel = 'models/props/cs_office/plant01_p1.mdl'
ITEM.PlantName = '#Farming_Plant_Orange'
ITEM.GrowTime = { 1337, 1488 }
ITEM.Harvest = { 'seed_orange', 'orange' }
