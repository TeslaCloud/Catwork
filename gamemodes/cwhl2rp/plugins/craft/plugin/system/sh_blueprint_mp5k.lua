--- Registers the MP5K blueprint (`blueprint_mp5k`) of the Craft plugin, which makes one `sxbase_mp5k` at the weapon
-- workbench (`cw_craft_wep`) from two `broken_mp5k`, three `reclaimed_metal`, two `box_of_screws`, one `box_of_bolts`
-- and two `plastic`, using `screw_driver` and `wrench` as tools, requiring 40 Repair (`rem`) and progressing it by 30.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintMp5k_Name'
BLUEPRINT.uniqueID = 'blueprint_mp5k'
BLUEPRINT.model = 'models/weapons/w_smg2.mdl'
BLUEPRINT.category = '#Craft_Category_Weapons'
BLUEPRINT.description = '#Blueprint_BlueprintMp5k_Description'
BLUEPRINT.craftplace = 'cw_craft_wep'
BLUEPRINT.reqatt = {
  { 'rem', 40 }
}
BLUEPRINT.updatt = {
  { 'rem', 30 }
}
BLUEPRINT.required = {
  { 'screw_driver', 1 },
  { 'wrench', 1 }
}
BLUEPRINT.recipe = {
  { 'broken_mp5k', 2 },
  { 'reclaimed_metal', 3 },
  { 'box_of_screws', 2 },
  { 'box_of_bolts', 1 },
  { 'plastic', 2 }
}
BLUEPRINT.finish = {
  { 'sxbase_mp5k', 1 }
}
BLUEPRINT:Register()
