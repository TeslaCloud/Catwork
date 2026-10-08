--- Registers the Chips blueprint (`blueprint_chips`) of the Craft plugin, which makes one `chips` at the cooking stove
-- (`cw_craft_cook`) from one `potato` and one `vegetable_oil`, using `weapon_knife` and `weapon_hl2pan` as tools,
-- requiring 10 Cooking (`cook`) and progressing it by 15.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintChips_Name'
BLUEPRINT.uniqueID = 'blueprint_chips'
BLUEPRINT.model = 'models/bioshockinfinite/bag_of_hhips.mdl'
BLUEPRINT.category = '#Craft_Category_Food'
BLUEPRINT.description = '#Blueprint_BlueprintChips_Description'
BLUEPRINT.craftplace = 'cw_craft_cook'
BLUEPRINT.reqatt = {
  { 'cook', 10 }
}
BLUEPRINT.updatt = {
  { 'cook', 15 }
}
BLUEPRINT.required = {
  { 'weapon_knife', 1 },
  { 'weapon_hl2pan', 1 }
}
BLUEPRINT.recipe = {
  { 'potato', 1 },
  { 'vegetable_oil', 1 }
}
BLUEPRINT.finish = {
  { 'chips', 1 }
}
BLUEPRINT:Register()
