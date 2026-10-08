--- Registers the Flour blueprint (`blueprint_flour`) of the Craft plugin, which makes one `flour` at the cooking stove
-- (`cw_craft_cook`) from one `corn` and one `empty_carton`, progressing Cooking (`cook`) by 10.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintFlour_Name'
BLUEPRINT.uniqueID = 'blueprint_flour'
BLUEPRINT.model = 'models/bioshockinfinite/topcorn_bag.mdl'
BLUEPRINT.category = '#Craft_Category_Materials'
BLUEPRINT.description = '#Blueprint_BlueprintFlour_Description'
BLUEPRINT.craftplace = 'cw_craft_cook'
BLUEPRINT.reqatt = {}
BLUEPRINT.updatt = {
  { 'cook', 10 }
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
  { 'corn', 1 },
  { 'empty_carton', 1 }
}
BLUEPRINT.finish = {
  { 'flour', 1 }
}
BLUEPRINT:Register()
