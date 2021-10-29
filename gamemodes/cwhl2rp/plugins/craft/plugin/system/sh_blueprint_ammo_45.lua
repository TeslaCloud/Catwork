local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintAmmo45_Name"
BLUEPRINT.uniqueID = "blueprint_ammo_45"
BLUEPRINT.model = "models/items/boxsrounds.mdl"
BLUEPRINT.category = "Боеприпасы"
BLUEPRINT.description = "#Blueprint_BlueprintAmmo45_Description"
BLUEPRINT.craftplace = "cw_craft_bullet"
BLUEPRINT.reqatt = {
	{"rem", 25}
}
BLUEPRINT.updatt = {
	{"rem", 15}
}
BLUEPRINT.recipe = {
	{"bullet_casings", 1},
	{"gunpowder", 1},
	{"refined_metal", 1}
}
BLUEPRINT.finish = {
	{"ammo_45", 1}
}
BLUEPRINT:Register();