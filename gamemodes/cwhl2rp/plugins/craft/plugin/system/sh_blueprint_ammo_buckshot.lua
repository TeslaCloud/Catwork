local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintAmmoBuckshot_Name"
BLUEPRINT.uniqueID = "blueprint_ammo_buckshot"
BLUEPRINT.model = "models/items/boxbuckshot.mdl"
BLUEPRINT.category = "Боеприпасы"
BLUEPRINT.description = "#Blueprint_BlueprintAmmoBuckshot_Description"
BLUEPRINT.craftplace = "cw_craft_bullet"
BLUEPRINT.reqatt = {
	{"rem", 30}
}
BLUEPRINT.updatt = {
	{"rem", 20}
}
BLUEPRINT.recipe = {
	{"bullet_casings", 1},
	{"gunpowder", 1},
	{"scrap_metal", 1}
}
BLUEPRINT.finish = {
	{"ammo_buckshot", 1}
}
BLUEPRINT:Register();