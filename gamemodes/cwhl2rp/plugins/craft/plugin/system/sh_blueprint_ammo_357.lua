--- Registers the `blueprint_ammo_357` ammunition blueprint of the Craft plugin, which makes one `ammo_357` at the ammo
-- workbench (`cw_craft_bullet`) from one `bullet_casings`, two `gunpowder` and one `refined_metal`, requiring 40
-- Repair (`rem`) and progressing it by 20.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintAmmo357_Name'
BLUEPRINT.uniqueID = 'blueprint_ammo_357'
BLUEPRINT.model = 'models/items/357ammo.mdl'
BLUEPRINT.category = '#Craft_Category_Ammo'
BLUEPRINT.description = '#Blueprint_BlueprintAmmo357_Description'
BLUEPRINT.craftplace = 'cw_craft_bullet'
BLUEPRINT.reqatt = {
  { 'rem', 40 }
}
BLUEPRINT.updatt = {
  { 'rem', 20 }
}
BLUEPRINT.recipe = {
  { 'bullet_casings', 1 },
  { 'gunpowder', 2 },
  { 'refined_metal', 1 }
}
BLUEPRINT.finish = {
  { 'ammo_357', 1 }
}
BLUEPRINT:Register()
