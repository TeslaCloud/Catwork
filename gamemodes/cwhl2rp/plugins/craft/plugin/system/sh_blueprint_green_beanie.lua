--- Registers the Green Beanie blueprint (`blueprint_green_beanie`) of the Craft plugin, which makes one `green_beanie`
-- at the workbench (`cw_crafttable`) from two `cloth`, progressing Clothes making (`cloth`) by 25.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintGreenBeanie_Name'
BLUEPRINT.uniqueID = 'blueprint_green_beanie'
BLUEPRINT.model = 'models/tnb/items/beanie.mdl'
BLUEPRINT.category = '#Craft_Category_Clothing'
BLUEPRINT.description = '#Blueprint_BlueprintGreenBeanie_Description'
BLUEPRINT.required = {}
BLUEPRINT.updatt = {
  { 'cloth', 25 }
}
BLUEPRINT.recipe = {
  { 'cloth', 2 }
}
BLUEPRINT.finish = {
  { 'green_beanie', 1 }
}
BLUEPRINT:Register()
