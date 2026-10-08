--- Registers the Medic Tactical Pants blueprint (`blueprint_medic_legs`) of the Craft plugin, which makes one
-- `rebel_legs_3` at the workbench (`cw_crafttable`) from five `cloth` and two `refined_metal`, requiring 65 Clothes
-- making (`cloth`) and progressing it by 65.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintMedicLegs_Name'
BLUEPRINT.uniqueID = 'blueprint_medic_legs'
BLUEPRINT.model = 'models/tnb/items/pants_rebel.mdl'
BLUEPRINT.category = '#Craft_Category_Clothing'
BLUEPRINT.description = '#Blueprint_BlueprintMedicLegs_Description'
BLUEPRINT.required = {}
BLUEPRINT.updatt = {
  { 'cloth', 65 }
}
BLUEPRINT.reqatt = {
  { 'cloth', 65 }
}
BLUEPRINT.recipe = {
  { 'cloth', 5 },
  { 'refined_metal', 2 }
}
BLUEPRINT.finish = {
  { 'rebel_legs_3', 1 }
}
BLUEPRINT:Register()
