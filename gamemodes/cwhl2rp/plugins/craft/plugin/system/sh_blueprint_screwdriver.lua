--- Registers the Screwdriver blueprint (`blueprint_screwdriver`) of the Craft plugin, which makes one `screw_driver` at
-- the workbench (`cw_crafttable`) from one `refined_metal`, requiring 10 Repair (`rem`) and progressing it by 15.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintScrewdriver_Name'
BLUEPRINT.uniqueID = 'blueprint_screwdriver'
BLUEPRINT.model = 'models/props_c17/TrapPropeller_Lever.mdl'
BLUEPRINT.category = '#Craft_Category_Tools'
BLUEPRINT.description = '#Blueprint_BlueprintScrewdriver_Description'
BLUEPRINT.reqatt = {
  { 'rem', 10 }
}
BLUEPRINT.updatt = {
  { 'rem', 15 }
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
  { 'refined_metal', 1 }
}
BLUEPRINT.finish = {
  { 'screw_driver', 1 }
}
BLUEPRINT:Register()
