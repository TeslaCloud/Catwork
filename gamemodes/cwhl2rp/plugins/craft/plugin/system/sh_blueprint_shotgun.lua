--- Registers the SPAS-12 blueprint (`blueprint_shotgun`) of the Craft plugin, which makes one `sxbase_spas12` at the
-- weapon workbench (`cw_craft_wep`) from two `broken_shotgun`, four `reclaimed_metal`, two `box_of_screws` and two
-- `box_of_bolts`, using `screw_driver`, `weld` and `wrench` as tools, requiring 65 Repair (`rem`) and progressing it
-- by 25.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintShotgun_Name'
BLUEPRINT.uniqueID = 'blueprint_shotgun'
BLUEPRINT.model = 'models/weapons/w_shotgun.mdl'
BLUEPRINT.category = '#Craft_Category_Weapons'
BLUEPRINT.description = '#Blueprint_BlueprintShotgun_Description'
BLUEPRINT.craftplace = 'cw_craft_wep'
BLUEPRINT.reqatt = {
  { 'rem', 65 }
}
BLUEPRINT.updatt = {
  { 'rem', 25 }
}
BLUEPRINT.required = {
  { 'screw_driver', 1 },
  { 'weld', 1 },
  { 'wrench', 1 }
}
BLUEPRINT.recipe = {
  { 'broken_shotgun', 2 },
  { 'reclaimed_metal', 4 },
  { 'box_of_screws', 2 },
  { 'box_of_bolts', 2 }
}
BLUEPRINT.finish = {
  { 'sxbase_spas12', 1 }
}
BLUEPRINT:Register()
