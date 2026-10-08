--- Registers the Orange Juice blueprint (`blueprint_orange_juice`) of the Craft plugin, which makes one `orange_juice`
-- at the cooking stove (`cw_craft_cook`) from two `orange_cleaned` and one `empty_soda_can`, progressing Cooking
-- (`cook`) by 10.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintOrangeJuice_Name'
BLUEPRINT.uniqueID = 'blueprint_orange_juice'
BLUEPRINT.model = 'models/props_nunk/popcan01a.mdl'
BLUEPRINT.category = '#Craft_Category_Drinks'
BLUEPRINT.description = '#Blueprint_BlueprintOrangeJuice_Description'
BLUEPRINT.craftplace = 'cw_craft_cook'
BLUEPRINT.reqatt = {}
BLUEPRINT.updatt = {
  { 'cook', 10 }
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
  { 'orange_cleaned', 2 },
  { 'empty_soda_can', 1 }
}
BLUEPRINT.finish = {
  { 'orange_juice', 1 }
}
BLUEPRINT:Register()
