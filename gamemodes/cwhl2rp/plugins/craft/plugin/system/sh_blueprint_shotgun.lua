local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintShotgun_Name"
BLUEPRINT.uniqueID = "blueprint_shotgun"
BLUEPRINT.model = "models/weapons/w_shotgun.mdl"
BLUEPRINT.category = "Чертежи оружия"
BLUEPRINT.description = "#Blueprint_BlueprintShotgun_Description"
BLUEPRINT.craftplace = "cw_craft_wep"
BLUEPRINT.reqatt = {
	{"rem", 65}
}
BLUEPRINT.updatt = {
	{"rem", 25}
}
BLUEPRINT.required = {
	{"screw_driver", 1},
	{"weld", 1},
	{"wrench", 1}
}
BLUEPRINT.recipe = {
	{"broken_shotgun", 2},
	{"reclaimed_metal", 4},
	{"box_of_screws", 2},
	{"box_of_bolts", 2}
}
BLUEPRINT.finish = {
	{"sxbase_spas12", 1}
}
BLUEPRINT:Register();