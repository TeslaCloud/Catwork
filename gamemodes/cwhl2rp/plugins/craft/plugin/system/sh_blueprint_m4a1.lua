--- Registers the M4A1 blueprint (`blueprint_m4a1`) of the Craft plugin, which makes one `sxbase_m4a1` at the weapon
-- workbench (`cw_craft_wep`) from two `broken_m4a1`, three `reclaimed_metal`, three `box_of_screws`, two
-- `box_of_bolts` and two `plastic`, using `screw_driver`, `weld` and `wrench` as tools, requiring 50 Repair (`rem`)
-- and progressing it by 40.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintM4a1_Name'
BLUEPRINT.uniqueID = 'blueprint_m4a1'
BLUEPRINT.model = 'models/weapons/w_m4_1.mdl'
BLUEPRINT.category = '#Craft_Category_Weapons'
BLUEPRINT.description = '#Blueprint_BlueprintM4a1_Description'
BLUEPRINT.craftplace = 'cw_craft_wep'
BLUEPRINT.reqatt = {
  { 'rem', 50 }
}
BLUEPRINT.updatt = {
  { 'rem', 40 }
}
BLUEPRINT.required = {
  { 'screw_driver', 1 },
  { 'weld', 1 },
  { 'wrench', 1 }
}
BLUEPRINT.recipe = {
  { 'broken_m4a1', 2 },
  { 'reclaimed_metal', 3 },
  { 'box_of_screws', 3 },
  { 'box_of_bolts', 2 },
  { 'plastic', 2 }
}
BLUEPRINT.finish = {
  { 'sxbase_m4a1', 1 }
}
BLUEPRINT:Register()
