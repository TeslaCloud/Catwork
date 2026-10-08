--- Registers the Tomato Juice blueprint (`blueprint_tomato_juice`) of the Craft plugin, which makes one `tomato_juice`
-- at the cooking stove (`cw_craft_cook`) from two `tomato` and one `empty_soda_can`, progressing Cooking (`cook`) by
-- 10.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintTomatoJuice_Name'
BLUEPRINT.uniqueID = 'blueprint_tomato_juice'
BLUEPRINT.model = 'models/props_nunk/popcan01a.mdl'
BLUEPRINT.category = '#Craft_Category_Drinks'
BLUEPRINT.description = '#Blueprint_BlueprintTomatoJuice_Description'
BLUEPRINT.craftplace = 'cw_craft_cook'
BLUEPRINT.reqatt = {}
BLUEPRINT.updatt = {
  { 'cook', 10 }
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
  { 'tomato', 2 },
  { 'empty_soda_can', 1 }
}
BLUEPRINT.finish = {
  { 'tomato_juice', 1 }
}
BLUEPRINT:Register()
