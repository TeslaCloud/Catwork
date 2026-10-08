--- Registers the Cloth blueprint (`blueprint_cloth`) of the Craft plugin, which makes one `cloth` at the workbench
-- (`cw_crafttable`) from two `weed`.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintCloth_Name'
BLUEPRINT.uniqueID = 'blueprint_cloth'
BLUEPRINT.model = 'models/props_wasteland/prison_toiletchunk01f.mdl'
BLUEPRINT.category = '#Craft_Category_Materials'
BLUEPRINT.description = '#Blueprint_BlueprintCloth_Description'
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
  { 'weed', 2 }
}
BLUEPRINT.finish = {
  { 'cloth', 1 }
}
BLUEPRINT:Register()
