--- Registers the Steroids blueprint (`blueprint_steroids`) of the Craft plugin, which makes one `steroids` at the
-- chemical laboratory (`cw_craft_chem`) from one `health_vial` and one `antidepressants`, requiring 25 Chemistry
-- (`chem`) and progressing it by 45.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintSteroids_Name'
BLUEPRINT.uniqueID = 'blueprint_steroids'
BLUEPRINT.model = 'models/props_junk/garbage_metalcan002a.mdl'
BLUEPRINT.category = '#Craft_Category_Medical'
BLUEPRINT.description = '#Blueprint_BlueprintSteroids_Description'
BLUEPRINT.craftplace = 'cw_craft_chem'
BLUEPRINT.updatt = {
  { 'chem', 45 }
}
BLUEPRINT.reqatt = {
  { 'chem', 25 }
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
  { 'health_vial', 1 },
  { 'antidepressants', 1 }
}
BLUEPRINT.finish = {
  { 'steroids', 1 }
}
BLUEPRINT:Register()
