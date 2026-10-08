--- Registers the Bright Jeans blueprint (`blueprint_cwu_legs`) of the Craft plugin, which makes one `cwu_legs` at the
-- workbench (`cw_crafttable`) from three `cloth`, requiring 15 Clothes making (`cloth`) and progressing it by 45.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintCwuLegs_Name'
BLUEPRINT.uniqueID = 'blueprint_cwu_legs'
BLUEPRINT.model = 'models/tnb/items/pants_citizen.mdl'
BLUEPRINT.category = '#Craft_Category_Clothing'
BLUEPRINT.description = '#Blueprint_BlueprintCwuLegs_Description'
BLUEPRINT.required = {}
BLUEPRINT.updatt = {
  { 'cloth', 45 }
}
BLUEPRINT.reqatt = {
  { 'cloth', 15 }
}
BLUEPRINT.recipe = {
  { 'cloth', 3 }
}
BLUEPRINT.finish = {
  { 'cwu_legs', 1 }
}
BLUEPRINT:Register()
