--- Registers the Bandage blueprint (`blueprint_bandage`) of the Craft plugin, which makes one `bandage` at the
-- workbench (`cw_crafttable`) from one `cloth`, progressing Medical (`med`) by 15.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintBandage_Name'
BLUEPRINT.uniqueID = 'blueprint_bandage'
BLUEPRINT.model = 'models/props_wasteland/prison_toiletchunk01f.mdl'
BLUEPRINT.category = '#Craft_Category_Misc'
BLUEPRINT.description = '#Blueprint_BlueprintBandage_Description'
BLUEPRINT.updatt = {
  { 'med', 15 }
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
  { 'cloth', 1 }
}
BLUEPRINT.finish = {
  { 'bandage', 1 }
}
BLUEPRINT:Register()
