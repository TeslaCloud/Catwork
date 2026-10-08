--- Registers the M9 Beretta blueprint (`blueprint_m9`) of the Craft plugin, which makes one `sxbase_m9` at the weapon
-- workbench (`cw_craft_wep`) from two `broken_m9`, two `reclaimed_metal` and two `box_of_screws`, using `screw_driver`
-- and `wrench` as tools, requiring 35 Repair (`rem`) and progressing it by 20.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintM9_Name'
BLUEPRINT.uniqueID = 'blueprint_m9'
BLUEPRINT.model = 'models/weapons/w_m9beretta.mdl'
BLUEPRINT.category = '#Craft_Category_Weapons'
BLUEPRINT.description = '#Blueprint_BlueprintM9_Description'
BLUEPRINT.craftplace = 'cw_craft_wep'
BLUEPRINT.reqatt = {
  { 'rem', 35 }
}
BLUEPRINT.updatt = {
  { 'rem', 20 }
}
BLUEPRINT.required = {
  { 'screw_driver', 1 },
  { 'wrench', 1 }
}
BLUEPRINT.recipe = {
  { 'broken_m9', 2 },
  { 'reclaimed_metal', 2 },
  { 'box_of_screws', 2 }
}
BLUEPRINT.finish = {
  { 'sxbase_m9', 1 }
}
BLUEPRINT:Register()
