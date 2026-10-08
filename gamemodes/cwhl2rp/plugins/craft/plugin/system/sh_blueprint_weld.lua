--- Registers the Welding Tool blueprint (`blueprint_weld`) of the Craft plugin, which makes one `weld` at the workbench
-- (`cw_crafttable`) from two `refined_metal` and one `refined_electronics`, requiring 20 Repair (`rem`) and
-- progressing it by 25.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintWeld_Name'
BLUEPRINT.uniqueID = 'blueprint_weld'
BLUEPRINT.model = 'models/props_vehicles/carparts_muffler01a.mdl'
BLUEPRINT.category = '#Craft_Category_Tools'
BLUEPRINT.description = '#Blueprint_BlueprintWeld_Description'
BLUEPRINT.reqatt = {
  { 'rem', 20 }
}
BLUEPRINT.updatt = {
  { 'rem', 25 }
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
  { 'refined_metal', 2 },
  { 'refined_electronics', 1 }
}
BLUEPRINT.finish = {
  { 'weld', 1 }
}
BLUEPRINT:Register()
