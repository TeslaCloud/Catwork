local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintAmmo762x51_Name"
BLUEPRINT.uniqueID = "blueprint_ammo_762x51"
BLUEPRINT.model = "models/items/357ammo.mdl"
BLUEPRINT.category = "Боеприпасы"
BLUEPRINT.description = "#Blueprint_BlueprintAmmo762x51_Description"
BLUEPRINT.craftplace = "cw_craft_bullet"
BLUEPRINT.reqatt = {
	{"rem", 30}
}
BLUEPRINT.updatt = {
	{"rem", 15}
}
BLUEPRINT.recipe = {
	{"bullet_casings", 1},
	{"gunpowder", 2},
	{"refined_metal", 1}
}
BLUEPRINT.finish = {
	{"ammo_762x51", 1}
}
BLUEPRINT:Register();