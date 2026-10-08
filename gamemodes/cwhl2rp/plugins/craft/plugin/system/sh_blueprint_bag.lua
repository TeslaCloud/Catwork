--- Registers the Bag blueprint (`blueprint_bag`) of the Craft plugin, which makes one `boxed_bag` at the workbench
-- (`cw_crafttable`) from one `cloth` and one `cables`, requiring 15 Clothes making (`cloth`) and progressing it by 15.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintBag_Name'
BLUEPRINT.uniqueID = 'blueprint_bag'
BLUEPRINT.model = 'models/props_junk/cardboard_box004a.mdl'
BLUEPRINT.category = '#Craft_Category_Storage'
BLUEPRINT.description = '#Blueprint_BlueprintBag_Description'
BLUEPRINT.reqatt = {
  { 'cloth', 15 }
}
BLUEPRINT.updatt = {
  { 'cloth', 15 }
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
  { 'cloth', 1 },
  { 'cables', 1 }
}
BLUEPRINT.finish = {
  { 'boxed_bag', 1 }
}
BLUEPRINT:Register()
