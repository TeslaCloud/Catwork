--- Registers the Backpack blueprint (`blueprint_backpack`) of the Craft plugin, which makes one `boxed_backpack` at the
-- workbench (`cw_crafttable`) from two `cloth` and two `cables`, requiring 30 Clothes making (`cloth`) and progressing
-- it by 20.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintBackpack_Name'
BLUEPRINT.uniqueID = 'blueprint_backpack'
BLUEPRINT.model = 'models/props_junk/cardboard_box004a.mdl'
BLUEPRINT.category = '#Craft_Category_Storage'
BLUEPRINT.description = '#Blueprint_BlueprintBackpack_Description'
BLUEPRINT.reqatt = {
  { 'cloth', 30 }
}
BLUEPRINT.updatt = {
  { 'cloth', 20 }
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
  { 'cloth', 2 },
  { 'cables', 2 }
}
BLUEPRINT.finish = {
  { 'boxed_backpack', 1 }
}
BLUEPRINT:Register()
