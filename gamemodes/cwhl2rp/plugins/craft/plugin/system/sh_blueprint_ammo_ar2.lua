local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintAmmoAr2_Name"
BLUEPRINT.uniqueID = "blueprint_ammo_ar2"
BLUEPRINT.model = "models/Items/combine_rifle_cartridge01.mdl"
BLUEPRINT.category = "Боеприпасы"
BLUEPRINT.description = "#Blueprint_BlueprintAmmoAr2_Description"
BLUEPRINT.craftplace = "cw_craft_bullet"
BLUEPRINT.reqatt = {
	{"rem", 55}
}
BLUEPRINT.updatt = {
	{"rem", 35}
}
BLUEPRINT.required = {
	{"weld", 1}
}
BLUEPRINT.recipe = {
	{"energy_cell", 1},
	{"refined_metal", 1}
}
BLUEPRINT.finish = {
	{"ammo_ar2", 1}
}
BLUEPRINT:Register();