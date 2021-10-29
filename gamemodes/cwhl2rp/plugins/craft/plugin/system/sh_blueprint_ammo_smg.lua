local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintAmmoSmg_Name"
BLUEPRINT.uniqueID = "blueprint_ammo_smg"
BLUEPRINT.model = "models/items/boxmrounds.mdl"
BLUEPRINT.category = "Боеприпасы"
BLUEPRINT.description = "#Blueprint_BlueprintAmmoSmg_Description"
BLUEPRINT.craftplace = "cw_craft_bullet"
BLUEPRINT.reqatt = {
	{"rem", 25}
}
BLUEPRINT.updatt = {
	{"rem", 10}
}
BLUEPRINT.recipe = {
	{"bullet_casings", 2},
	{"gunpowder", 1},
	{"refined_metal", 2}
}
BLUEPRINT.finish = {
	{"ammo_smg1", 1}
}
BLUEPRINT:Register();