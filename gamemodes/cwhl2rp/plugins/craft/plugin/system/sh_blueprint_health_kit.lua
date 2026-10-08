--- Registers the Health Kit blueprint (`blueprint_health_kit`) of the Craft plugin, which makes one `health_kit` at the
-- chemical laboratory (`cw_craft_chem`) from one `plastic`, one `health_vial` and one `refined_electronics`, requiring
-- 30 Chemistry (`chem`) and progressing it by 55.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintHealthKit_Name'
BLUEPRINT.uniqueID = 'blueprint_health_kit'
BLUEPRINT.model = 'models/items/healthkit.mdl'
BLUEPRINT.category = '#Craft_Category_Medical'
BLUEPRINT.description = '#Blueprint_BlueprintHealthKit_Description'
BLUEPRINT.craftplace = 'cw_craft_chem'
BLUEPRINT.updatt = {
  { 'chem', 55 }
}
BLUEPRINT.reqatt = {
  { 'chem', 30 }
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
  { 'plastic', 1 },
  { 'health_vial', 1 },
  { 'refined_electronics', 1 }
}
BLUEPRINT.finish = {
  { 'health_kit', 1 }
}
BLUEPRINT:Register()
