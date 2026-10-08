--- Registers the HK-21 blueprint (`blueprint_hk21`) of the Craft plugin, which makes one `sxbase_hmg` at the weapon
-- workbench (`cw_craft_wep`) from two `broken_hk21`, four `reclaimed_metal` and three `box_of_screws`, using
-- `screw_driver`, `weld` and `wrench` as tools, requiring 80 Repair (`rem`) and progressing it by 40.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintHk21_Name'
BLUEPRINT.uniqueID = 'blueprint_hk21'
BLUEPRINT.model = 'models/weapons/w_hmg.mdl'
BLUEPRINT.category = '#Craft_Category_Weapons'
BLUEPRINT.description = '#Blueprint_BlueprintHk21_Description'
BLUEPRINT.craftplace = 'cw_craft_wep'
BLUEPRINT.reqatt = {
  { 'rem', 80 }
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
  { 'broken_hk21', 2 },
  { 'reclaimed_metal', 4 },
  { 'box_of_screws', 3 }
}
BLUEPRINT.finish = {
  { 'sxbase_hmg', 1 }
}
BLUEPRINT:Register()
