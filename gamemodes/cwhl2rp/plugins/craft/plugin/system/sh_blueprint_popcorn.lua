--- Registers the Popcorn blueprint (`blueprint_popcorn`) of the Craft plugin, which makes three `popcorn` at the
-- cooking stove (`cw_craft_cook`) from two `corn` and three `empty_carton`, requiring 10 Cooking (`cook`) and
-- progressing it by 10.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintPopcorn_Name'
BLUEPRINT.uniqueID = 'blueprint_popcorn'
BLUEPRINT.model = 'models/bioshockinfinite/topcorn_bag.mdl'
BLUEPRINT.category = '#Craft_Category_Food'
BLUEPRINT.description = '#Blueprint_BlueprintPopcorn_Description'
BLUEPRINT.craftplace = 'cw_craft_cook'
BLUEPRINT.reqatt = {
  { 'cook', 10 }
}
BLUEPRINT.updatt = {
  { 'cook', 10 }
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
  { 'corn', 2 },
  { 'empty_carton', 3 }
}
BLUEPRINT.finish = {
  { 'popcorn', 3 }
}
BLUEPRINT:Register()
