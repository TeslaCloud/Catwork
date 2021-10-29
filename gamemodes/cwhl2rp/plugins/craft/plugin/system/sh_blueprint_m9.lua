local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintM9_Name"
BLUEPRINT.uniqueID = "blueprint_m9"
BLUEPRINT.model = "models/weapons/w_m9beretta.mdl"
BLUEPRINT.category = "Чертежи оружия"
BLUEPRINT.description = "#Blueprint_BlueprintM9_Description"
BLUEPRINT.craftplace = "cw_craft_wep"
BLUEPRINT.reqatt = {
	{"rem", 35}
}
BLUEPRINT.updatt = {
	{"rem", 20}
}
BLUEPRINT.required = {
	{"screw_driver", 1},
	{"wrench", 1}
}
BLUEPRINT.recipe = {
	{"broken_m9", 2},
	{"reclaimed_metal", 2},
	{"box_of_screws", 2},
}
BLUEPRINT.finish = {
	{"sxbase_m9", 1}
}
BLUEPRINT:Register();