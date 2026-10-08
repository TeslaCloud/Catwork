--- Registers the LAR Grizzly Big Boar blueprint (`blueprint_lar`) of the Craft plugin, which makes one `sxbase_lar` at
-- the weapon workbench (`cw_craft_wep`) from two `broken_lar`, four `reclaimed_metal`, three `box_of_screws`, three
-- `plastic` and two `empty_glass_bottle`, using `screw_driver`, `weld` and `wrench` as tools, requiring 90 Repair
-- (`rem`) and progressing it by 80.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintLar_Name'
BLUEPRINT.uniqueID = 'blueprint_lar'
BLUEPRINT.model = 'models/rtb_weapons/w_sniper.mdl'
BLUEPRINT.category = '#Craft_Category_Weapons'
BLUEPRINT.description = '#Blueprint_BlueprintLar_Description'
BLUEPRINT.craftplace = 'cw_craft_wep'
BLUEPRINT.reqatt = {
  { 'rem', 90 }
}
BLUEPRINT.updatt = {
  { 'rem', 80 }
}
BLUEPRINT.required = {
  { 'screw_driver', 1 },
  { 'weld', 1 },
  { 'wrench', 1 }
}
BLUEPRINT.recipe = {
  { 'broken_lar', 2 },
  { 'reclaimed_metal', 4 },
  { 'box_of_screws', 3 },
  { 'plastic', 3 },
  { 'empty_glass_bottle', 2 }
}
BLUEPRINT.finish = {
  { 'sxbase_lar', 1 }
}
BLUEPRINT:Register()
