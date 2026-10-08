--- Registers the CWU Shirt blueprint (`blueprint_cwu_uniform`) of the Craft plugin, which makes one `cwu_uniform` at
-- the workbench (`cw_crafttable`) from five `cloth`, requiring 20 Clothes making (`cloth`) and progressing it by 45.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintCwuUniform_Name'
BLUEPRINT.uniqueID = 'blueprint_cwu_uniform'
BLUEPRINT.model = 'models/tnb/items/shirt_citizen1.mdl'
BLUEPRINT.category = '#Craft_Category_Clothing'
BLUEPRINT.description = '#Blueprint_BlueprintCwuUniform_Description'
BLUEPRINT.required = {}
BLUEPRINT.updatt = {
  { 'cloth', 45 }
}
BLUEPRINT.reqatt = {
  { 'cloth', 20 }
}
BLUEPRINT.recipe = {
  { 'cloth', 5 }
}
BLUEPRINT.finish = {
  { 'cwu_uniform', 1 }
}
BLUEPRINT:Register()
