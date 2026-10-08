--- Registers the Refined Electronics blueprint (`blueprint_electronics`) of the Craft plugin, which makes one
-- `refined_electronics` at the workbench (`cw_crafttable`) from two `scrap_electronics`, using `screw_driver` as a
-- tool, progressing Repair (`rem`) by 15.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintElectronics_Name'
BLUEPRINT.uniqueID = 'blueprint_electronics'
BLUEPRINT.model = 'models/props_lab/reciever01d.mdl'
BLUEPRINT.category = '#Craft_Category_Materials'
BLUEPRINT.description = '#Blueprint_BlueprintElectronics_Description'
BLUEPRINT.reqatt = {}
BLUEPRINT.updatt = {
  { 'rem', 15 }
}
BLUEPRINT.required = {
  { 'screw_driver', 1 }
}
BLUEPRINT.recipe = {
  { 'scrap_electronics', 2 }
}
BLUEPRINT.finish = {
  { 'refined_electronics', 1 }
}
BLUEPRINT:Register()
