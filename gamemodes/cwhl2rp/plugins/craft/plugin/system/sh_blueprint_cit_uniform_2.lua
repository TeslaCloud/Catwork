--- Registers the Short-Sleeved Citizen Uniform blueprint (`blueprint_uniform_2`) of the Craft plugin, which makes one
-- `cit_uniform_2` at the workbench (`cw_crafttable`) from four `cloth`, requiring 10 Clothes making (`cloth`) and
-- progressing it by 35.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintCitUniform2_Name'
BLUEPRINT.uniqueID = 'blueprint_uniform_2'
BLUEPRINT.model = 'models/tnb/items/shirt_citizen2.mdl'
BLUEPRINT.category = '#Craft_Category_Clothing'
BLUEPRINT.description = '#Blueprint_BlueprintCitUniform2_Description'
BLUEPRINT.required = {}
BLUEPRINT.updatt = {
  { 'cloth', 35 }
}
BLUEPRINT.reqatt = {
  { 'cloth', 10 }
}
BLUEPRINT.recipe = {
  { 'cloth', 4 }
}
BLUEPRINT.finish = {
  { 'cit_uniform_2', 1 }
}
BLUEPRINT:Register()
