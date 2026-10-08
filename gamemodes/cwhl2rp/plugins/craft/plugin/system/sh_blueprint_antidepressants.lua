--- Registers the Antidepressants blueprint (`blueprint_antidepressants`) of the Craft plugin, which makes one
-- `antidepressants` at the chemical laboratory (`cw_craft_chem`) from three `weed`, progressing Chemistry (`chem`) by
-- 15.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintAntidepressants_Name'
BLUEPRINT.uniqueID = 'blueprint_antidepressants'
BLUEPRINT.model = 'models/props_junk/garbage_metalcan001a.mdl'
BLUEPRINT.category = '#Craft_Category_Medical'
BLUEPRINT.description = '#Blueprint_BlueprintAntidepressants_Description'
BLUEPRINT.craftplace = 'cw_craft_chem'
BLUEPRINT.updatt = {
  { 'chem', 15 }
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
  { 'weed', 3 }
}
BLUEPRINT.finish = {
  { 'antidepressants', 1 }
}
BLUEPRINT:Register()
