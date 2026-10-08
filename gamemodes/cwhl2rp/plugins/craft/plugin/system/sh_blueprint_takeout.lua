--- Registers the Noodles blueprint (`blueprint_takeout`) of the Craft plugin, which makes one `chinese_takeout` and one
-- `empty_soda_can` at the cooking stove (`cw_craft_cook`) from one `flour` and one `breens_water`, progressing Cooking
-- (`cook`) by 15.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintTakeout_Name'
BLUEPRINT.uniqueID = 'blueprint_takeout'
BLUEPRINT.model = 'models/props_junk/garbage_takeoutcarton001a.mdl'
BLUEPRINT.category = '#Craft_Category_Food'
BLUEPRINT.description = '#Blueprint_BlueprintTakeout_Description'
BLUEPRINT.craftplace = 'cw_craft_cook'
BLUEPRINT.reqatt = {}
BLUEPRINT.updatt = {
  { 'cook', 15 }
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
  { 'flour', 1 },
  { 'breens_water', 1 }
}
BLUEPRINT.finish = {
  { 'chinese_takeout', 1 },
  { 'empty_soda_can', 1 }
}
BLUEPRINT:Register()
