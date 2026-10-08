--- Registers the Vodka blueprint (`blueprint_vodka`) of the Craft plugin, which makes one `vodka` and one
-- `empty_soda_can` at the chemical laboratory (`cw_craft_chem`) from one `empty_glass_bottle`, one `breens_water` and
-- two `potato`, requiring 5 Chemistry (`chem`) and progressing it by 25.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintVodka_Name'
BLUEPRINT.uniqueID = 'blueprint_vodka'
BLUEPRINT.model = 'models/props_junk/garbage_glassbottle002a.mdl'
BLUEPRINT.category = '#Craft_Category_Alcohol'
BLUEPRINT.description = '#Blueprint_BlueprintVodka_Description'
BLUEPRINT.craftplace = 'cw_craft_chem'
BLUEPRINT.updatt = {
  { 'chem', 25 }
}
BLUEPRINT.reqatt = {
  { 'chem', 5 }
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
  { 'empty_glass_bottle', 1 },
  { 'breens_water', 1 },
  { 'potato', 2 }
}
BLUEPRINT.finish = {
  { 'vodka', 1 },
  { 'empty_soda_can', 1 }
}
BLUEPRINT:Register()
