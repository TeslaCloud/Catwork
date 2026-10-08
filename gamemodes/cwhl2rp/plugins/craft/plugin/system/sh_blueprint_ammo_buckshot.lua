--- Registers the 12 Gauge Buckshot blueprint (`blueprint_ammo_buckshot`) of the Craft plugin, which makes one
-- `ammo_buckshot` at the ammo workbench (`cw_craft_bullet`) from one `bullet_casings`, one `gunpowder` and one
-- `scrap_metal`, requiring 30 Repair (`rem`) and progressing it by 20.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintAmmoBuckshot_Name'
BLUEPRINT.uniqueID = 'blueprint_ammo_buckshot'
BLUEPRINT.model = 'models/items/boxbuckshot.mdl'
BLUEPRINT.category = '#Craft_Category_Ammo'
BLUEPRINT.description = '#Blueprint_BlueprintAmmoBuckshot_Description'
BLUEPRINT.craftplace = 'cw_craft_bullet'
BLUEPRINT.reqatt = {
  { 'rem', 30 }
}
BLUEPRINT.updatt = {
  { 'rem', 20 }
}
BLUEPRINT.recipe = {
  { 'bullet_casings', 1 },
  { 'gunpowder', 1 },
  { 'scrap_metal', 1 }
}
BLUEPRINT.finish = {
  { 'ammo_buckshot', 1 }
}
BLUEPRINT:Register()
