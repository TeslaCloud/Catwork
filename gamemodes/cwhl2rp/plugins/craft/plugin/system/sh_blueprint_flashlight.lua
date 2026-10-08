--- Registers the Makeshift Flashlight blueprint (`blueprint_flashlight`) of the Craft plugin, which makes one
-- `flashlight` at the workbench (`cw_crafttable`) from two `empty_soda_can`, one `energy_cell` and one
-- `scrap_electronics`, requiring 15 Repair (`rem`) and progressing it by 15.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintFlashlight_Name'
BLUEPRINT.uniqueID = 'blueprint_flashlight'
BLUEPRINT.model = 'models/lagmite/lagmite.mdl'
BLUEPRINT.category = '#Craft_Category_Misc'
BLUEPRINT.description = '#Blueprint_BlueprintFlashlight_Description'
BLUEPRINT.reqatt = {
  { 'rem', 15 }
}
BLUEPRINT.updatt = {
  { 'rem', 15 }
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
  { 'empty_soda_can', 2 },
  { 'energy_cell', 1 },
  { 'scrap_electronics', 1 }
}
BLUEPRINT.finish = {
  { 'flashlight', 1 }
}
BLUEPRINT:Register()
