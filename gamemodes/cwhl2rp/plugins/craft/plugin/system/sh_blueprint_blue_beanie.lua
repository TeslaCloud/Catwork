--- Registers the Blue Beanie blueprint (`blueprint_blue_beanie`) of the Craft plugin, which makes one `blue_beanie` at
-- the workbench (`cw_crafttable`) from two `cloth`, progressing Clothes making (`cloth`) by 25.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintBlueBeanie_Name'
BLUEPRINT.uniqueID = 'blueprint_blue_beanie'
BLUEPRINT.model = 'models/tnb/items/beanie.mdl'
BLUEPRINT.category = '#Craft_Category_Clothing'
BLUEPRINT.description = '#Blueprint_BlueprintBlueBeanie_Description'
BLUEPRINT.required = {}
BLUEPRINT.updatt = {
  { 'cloth', 25 }
}
BLUEPRINT.recipe = {
  { 'cloth', 2 }
}
BLUEPRINT.finish = {
  { 'blue_beanie', 1 }
}
BLUEPRINT:Register()
