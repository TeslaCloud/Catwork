--- Registers the AK-74 blueprint (`blueprint_ak74`) of the Craft plugin, which makes one `sxbase_ak74` at the weapon
-- workbench (`cw_craft_wep`) from two `broken_ak74`, three `reclaimed_metal`, three `box_of_screws` and two
-- `wooden_parts`, using `screw_driver` and `weld` as tools, requiring 50 Repair (`rem`) and progressing it by 30.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintAk74_Name'
BLUEPRINT.uniqueID = 'blueprint_ak74'
BLUEPRINT.model = 'models/weapons/w_ak74.mdl'
BLUEPRINT.category = '#Craft_Category_Weapons'
BLUEPRINT.description = '#Blueprint_BlueprintAk74_Description'
BLUEPRINT.craftplace = 'cw_craft_wep'
BLUEPRINT.reqatt = {
  { 'rem', 50 }
}
BLUEPRINT.updatt = {
  { 'rem', 30 }
}
BLUEPRINT.required = {
  { 'screw_driver', 1 },
  { 'weld', 1 }
}
BLUEPRINT.recipe = {
  { 'broken_ak74', 2 },
  { 'reclaimed_metal', 3 },
  { 'box_of_screws', 3 },
  { 'wooden_parts', 2 }
}
BLUEPRINT.finish = {
  { 'sxbase_ak74', 1 }
}
BLUEPRINT:Register()
