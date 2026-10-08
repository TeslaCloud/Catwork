--- Registers the M1911 blueprint (`blueprint_m1911`) of the Craft plugin, which makes one `sxbase_m1911` at the weapon
-- workbench (`cw_craft_wep`) from two `broken_m1911`, two `reclaimed_metal` and two `box_of_screws`, using
-- `screw_driver` and `wrench` as tools, requiring 40 Repair (`rem`) and progressing it by 20.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintM1911_Name'
BLUEPRINT.uniqueID = 'blueprint_m1911'
BLUEPRINT.model = 'models/weapons/w_1911_1.mdl'
BLUEPRINT.category = '#Craft_Category_Weapons'
BLUEPRINT.description = '#Blueprint_BlueprintM1911_Description'
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
  { 'broken_m1911', 2 },
  { 'reclaimed_metal', 2 },
  { 'box_of_screws', 2 }
}
BLUEPRINT.finish = {
  { 'sxbase_m1911', 1 }
}
BLUEPRINT:Register()
