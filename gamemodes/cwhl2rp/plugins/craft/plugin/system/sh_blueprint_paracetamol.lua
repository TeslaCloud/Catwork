--- Registers the Paracetamol blueprint (`blueprint_paracetamol`) of the Craft plugin, which makes one `paracetamol` and
-- one `empty_glass_bottle` at the chemical laboratory (`cw_craft_chem`) from one `health_vial`, one `charcoal` and one
-- `vodka`, requiring 15 Chemistry (`chem`) and progressing it by 35.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintParacetamol_Name'
BLUEPRINT.uniqueID = 'blueprint_paracetamol'
BLUEPRINT.model = 'models/props_junk/garbage_metalcan002a.mdl'
BLUEPRINT.category = '#Craft_Category_Medical'
BLUEPRINT.description = '#Blueprint_BlueprintParacetamol_Description'
BLUEPRINT.craftplace = 'cw_craft_chem'
BLUEPRINT.updatt = {
  { 'chem', 35 }
}
BLUEPRINT.reqatt = {
  { 'chem', 15 }
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
  { 'health_vial', 1 },
  { 'charcoal', 1 },
  { 'vodka', 1 }
}
BLUEPRINT.finish = {
  { 'paracetamol', 1 },
  { 'empty_glass_bottle', 1 }
}
BLUEPRINT:Register()
