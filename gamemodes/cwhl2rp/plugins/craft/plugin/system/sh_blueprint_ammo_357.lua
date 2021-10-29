local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintAmmo357_Name"
BLUEPRINT.uniqueID = "blueprint_ammo_357"
BLUEPRINT.model = "models/items/357ammo.mdl"
BLUEPRINT.category = "Боеприпасы"
BLUEPRINT.description = "#Blueprint_BlueprintAmmo357_Description"
BLUEPRINT.craftplace = "cw_craft_bullet"
BLUEPRINT.reqatt = {
	{"rem", 40}
}
BLUEPRINT.updatt = {
	{"rem", 20}
}
BLUEPRINT.recipe = {
	{"bullet_casings", 1},
	{"gunpowder", 2},
	{"refined_metal", 1}
}
BLUEPRINT.finish = {
	{"ammo_357", 1}
}
BLUEPRINT:Register();