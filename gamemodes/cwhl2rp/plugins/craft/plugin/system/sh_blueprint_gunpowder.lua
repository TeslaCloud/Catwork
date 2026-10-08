--- Registers the Gunpowder blueprint (`blueprint_gunpowder`) of the Craft plugin, which makes three `gunpowder` at the
-- chemical laboratory (`cw_craft_chem`) from two `selitra`, one `charcoal` and one `sulphur`, progressing Chemistry
-- (`chem`) by 15.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintGunpowder_Name'
BLUEPRINT.uniqueID = 'blueprint_gunpowder'
BLUEPRINT.model = 'models/props_lab/box01a.mdl'
BLUEPRINT.category = '#Craft_Category_Substances'
BLUEPRINT.description = '#Blueprint_BlueprintGunpowder_Description'
BLUEPRINT.craftplace = 'cw_craft_chem'
BLUEPRINT.required = {}
BLUEPRINT.updatt = {
  { 'chem', 15 }
}
BLUEPRINT.recipe = {
  { 'selitra', 2 },
  { 'charcoal', 1 },
  { 'sulphur', 1 }
}
BLUEPRINT.finish = {
  { 'gunpowder', 3 }
}
BLUEPRINT:Register()
