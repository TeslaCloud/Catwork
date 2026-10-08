--- Registers the `blueprint_ammo_smg` ammunition blueprint of the Craft plugin, which makes one `ammo_smg1` at the ammo
-- workbench (`cw_craft_bullet`) from two `bullet_casings`, one `gunpowder` and two `refined_metal`, requiring 25
-- Repair (`rem`) and progressing it by 10.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintAmmoSmg_Name'
BLUEPRINT.uniqueID = 'blueprint_ammo_smg'
BLUEPRINT.model = 'models/items/boxmrounds.mdl'
BLUEPRINT.category = '#Craft_Category_Ammo'
BLUEPRINT.description = '#Blueprint_BlueprintAmmoSmg_Description'
BLUEPRINT.craftplace = 'cw_craft_bullet'
BLUEPRINT.reqatt = {
  { 'rem', 25 }
}
BLUEPRINT.updatt = {
  { 'rem', 10 }
}
BLUEPRINT.recipe = {
  { 'bullet_casings', 2 },
  { 'gunpowder', 1 },
  { 'refined_metal', 2 }
}
BLUEPRINT.finish = {
  { 'ammo_smg1', 1 }
}
BLUEPRINT:Register()
