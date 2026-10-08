--- Registers the Makeshift Radio blueprint (`blueprint_handheld_radio`) of the Craft plugin, which makes one
-- `handheld_radio` at the workbench (`cw_crafttable`) from one `refined_electronics`, one `plastic` and one
-- `energy_cell`, using `screw_driver` as a tool, requiring 45 Repair (`rem`) and progressing it by 20.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintHandheldRadio_Name'
BLUEPRINT.uniqueID = 'blueprint_handheld_radio'
BLUEPRINT.model = 'models/deadbodies/dead_male_civilian_radio.mdl'
BLUEPRINT.category = '#Craft_Category_Misc'
BLUEPRINT.description = '#Blueprint_BlueprintHandheldRadio_Description'
BLUEPRINT.reqatt = {
  { 'rem', 45 }
}
BLUEPRINT.updatt = {
  { 'rem', 20 }
}
BLUEPRINT.required = {
  { 'screw_driver', 1 }
}
BLUEPRINT.recipe = {
  { 'refined_electronics', 1 },
  { 'plastic', 1 },
  { 'energy_cell', 1 }
}
BLUEPRINT.finish = {
  { 'handheld_radio', 1 }
}
BLUEPRINT:Register()
