--- Registers the Gloves blueprint (`blueprint_gloves`) of the Craft plugin, which makes one `gloves` at the workbench
-- (`cw_crafttable`) from one `cloth`, progressing Clothes making (`cloth`) by 15.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintGloves_Name'
BLUEPRINT.uniqueID = 'blueprint_gloves'
BLUEPRINT.model = 'models/tnb/items/gloves.mdl'
BLUEPRINT.category = '#Craft_Category_Clothing'
BLUEPRINT.description = '#Blueprint_BlueprintGloves_Description'
BLUEPRINT.required = {}
BLUEPRINT.updatt = {
  { 'cloth', 15 }
}
BLUEPRINT.recipe = {
  { 'cloth', 1 }
}
BLUEPRINT.finish = {
  { 'gloves', 1 }
}
BLUEPRINT:Register()
