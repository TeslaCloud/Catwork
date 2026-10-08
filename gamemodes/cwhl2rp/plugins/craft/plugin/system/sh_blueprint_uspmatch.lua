--- Registers the USP Match blueprint (`blueprint_uspmatch`) of the Craft plugin, which makes one `sxbase_uspmatch` at
-- the weapon workbench (`cw_craft_wep`) from two `broken_uspmatch`, three `reclaimed_metal` and two `box_of_screws`,
-- using `screw_driver` and `wrench` as tools, requiring 40 Repair (`rem`) and progressing it by 20.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintUspmatch_Name'
BLUEPRINT.uniqueID = 'blueprint_uspmatch'
BLUEPRINT.model = 'models/weapons/w_uspmatch.mdl'
BLUEPRINT.category = '#Craft_Category_Weapons'
BLUEPRINT.description = '#Blueprint_BlueprintUspmatch_Description'
BLUEPRINT.craftplace = 'cw_craft_wep'
BLUEPRINT.reqatt = {
  { 'rem', 40 }
}
BLUEPRINT.updatt = {
  { 'rem', 20 }
}
BLUEPRINT.required = {
  { 'screw_driver', 1 },
  { 'wrench', 1 }
}
BLUEPRINT.recipe = {
  { 'broken_uspmatch', 2 },
  { 'reclaimed_metal', 3 },
  { 'box_of_screws', 2 }
}
BLUEPRINT.finish = {
  { 'sxbase_uspmatch', 1 }
}
BLUEPRINT:Register()
