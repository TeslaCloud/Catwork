local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintAmmo50_Name"
BLUEPRINT.uniqueID = "blueprint_ammo_50"
BLUEPRINT.model = "models/items/357ammo.mdl"
BLUEPRINT.category = "Боеприпасы"
BLUEPRINT.description = "#Blueprint_BlueprintAmmo50_Description"
BLUEPRINT.craftplace = "cw_craft_bullet"
BLUEPRINT.reqatt = {
	{"rem", 45}
}
BLUEPRINT.updatt = {
	{"rem", 25}
}
BLUEPRINT.recipe = {
	{"bullet_casings", 1},
	{"gunpowder", 2},
	{"refined_metal", 2}
}
BLUEPRINT.finish = {
	{"ammo_50", 1}
}
BLUEPRINT:Register();