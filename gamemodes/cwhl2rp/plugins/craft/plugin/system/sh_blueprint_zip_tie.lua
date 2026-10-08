--- Registers the Zip Ties blueprint (`blueprint_zip_tie`) of the Craft plugin, which makes two `zip_tie` at the
-- workbench (`cw_crafttable`) from one `cables`, progressing Repair (`rem`) by 5.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintZipTie_Name'
BLUEPRINT.uniqueID = 'blueprint_zip_tie'
BLUEPRINT.model = 'models/items/crossbowrounds.mdl'
BLUEPRINT.category = '#Craft_Category_Misc'
BLUEPRINT.description = '#Blueprint_BlueprintZipTie_Description'
BLUEPRINT.required = {}
BLUEPRINT.updatt = {
  { 'rem', 5 }
}
BLUEPRINT.recipe = {
  { 'cables', 1 }
}
BLUEPRINT.finish = {
  { 'zip_tie', 2 }
}
BLUEPRINT:Register()
