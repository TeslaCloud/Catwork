--- Registers the Scrap Metal blueprint (`blueprint_scrapmetal`) of the Craft plugin, which makes one `scrap_metal` at
-- the furnace (`cw_craft_furnace`) from five `empty_soda_can` and one `charcoal`, progressing Repair (`rem`) by 7.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintScrapmetal_Name'
BLUEPRINT.uniqueID = 'blueprint_scrapmetal'
BLUEPRINT.model = 'models/props_debris/metal_panelchunk02d.mdl'
BLUEPRINT.category = '#Craft_Category_Recycling'
BLUEPRINT.description = '#Blueprint_BlueprintScrapmetal_Description'
BLUEPRINT.craftplace = 'cw_craft_furnace'
BLUEPRINT.reqatt = {}
BLUEPRINT.updatt = {
  { 'rem', 7 }
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
  { 'empty_soda_can', 5 },
  { 'charcoal', 1 }
}
BLUEPRINT.finish = {
  { 'scrap_metal', 1 }
}
BLUEPRINT:Register()
