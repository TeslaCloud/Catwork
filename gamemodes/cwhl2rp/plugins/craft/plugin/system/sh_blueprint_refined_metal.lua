--- Registers the Refined Metal blueprint (`blueprint_refined_metal`) of the Craft plugin, which makes two
-- `refined_metal` at the furnace (`cw_craft_furnace`) from five `reclaimed_metal` and three `charcoal`, progressing
-- Repair (`rem`) by 5.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintRefinedMetal_Name'
BLUEPRINT.uniqueID = 'blueprint_refined_metal'
BLUEPRINT.model = 'models/gibs/metal_gib2.mdl'
BLUEPRINT.category = '#Craft_Category_Metalworking'
BLUEPRINT.description = '#Blueprint_BlueprintRefinedMetal_Description'
BLUEPRINT.craftplace = 'cw_craft_furnace'
BLUEPRINT.required = {}
BLUEPRINT.updatt = {
  { 'rem', 5 }
}
BLUEPRINT.recipe = {
  { 'reclaimed_metal', 5 },
  { 'charcoal', 3 }
}
BLUEPRINT.finish = {
  { 'refined_metal', 2 }
}
BLUEPRINT:Register()
