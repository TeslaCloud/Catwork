local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintAmmo545x39_Name"
BLUEPRINT.uniqueID = "blueprint_ammo_545x39"
BLUEPRINT.model = "models/items/boxmrounds.mdl"
BLUEPRINT.category = "Боеприпасы"
BLUEPRINT.description = "#Blueprint_BlueprintAmmo545x39_Description"
BLUEPRINT.craftplace = "cw_craft_bullet"
BLUEPRINT.reqatt = {
	{"rem", 30}
}
BLUEPRINT.updatt = {
	{"rem", 15}
}
BLUEPRINT.recipe = {
	{"bullet_casings", 2},
	{"gunpowder", 2},
	{"refined_metal", 2}
}
BLUEPRINT.finish = {
	{"ammo_545x39", 1}
}
BLUEPRINT:Register();