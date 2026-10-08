--- Registers the Corn Beer blueprint (`blueprint_beer`) of the Craft plugin, which makes one `beer` and one
-- `empty_soda_can` at the chemical laboratory (`cw_craft_chem`) from two `corn`, one `empty_glass_bottle` and one
-- `breens_water`, progressing Chemistry (`chem`) by 25.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintBeer_Name'
BLUEPRINT.uniqueID = 'blueprint_beer'
BLUEPRINT.model = 'models/props_junk/garbage_glassbottle002a.mdl'
BLUEPRINT.category = '#Craft_Category_Alcohol'
BLUEPRINT.description = '#Blueprint_BlueprintBeer_Description'
BLUEPRINT.craftplace = 'cw_craft_chem'
BLUEPRINT.updatt = {
  { 'chem', 25 }
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
  { 'corn', 2 },
  { 'empty_glass_bottle', 1 },
  { 'breens_water', 1 }
}
BLUEPRINT.finish = {
  { 'beer', 1 },
  { 'empty_soda_can', 1 }
}
BLUEPRINT:Register()
