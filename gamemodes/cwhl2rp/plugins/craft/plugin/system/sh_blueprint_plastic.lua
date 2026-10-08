--- Registers the Plastic blueprint (`blueprint_plastic`) of the Craft plugin, which makes one `plastic` at the furnace
-- (`cw_craft_furnace`) from three `empty_tin_can`, progressing Repair (`rem`) by 5.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintPlastic_Name'
BLUEPRINT.uniqueID = 'blueprint_plastic'
BLUEPRINT.model = 'models/props_debris/metal_panelshard01b.mdl'
BLUEPRINT.category = '#Craft_Category_Recycling'
BLUEPRINT.description = '#Blueprint_BlueprintPlastic_Description'
BLUEPRINT.craftplace = 'cw_craft_furnace'
BLUEPRINT.required = {}
BLUEPRINT.updatt = {
  { 'rem', 5 }
}
BLUEPRINT.recipe = {
  { 'empty_tin_can', 3 }
}
BLUEPRINT.finish = {
  { 'plastic', 1 }
}
BLUEPRINT:Register()
