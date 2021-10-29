local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintUspmatch_Name"
BLUEPRINT.uniqueID = "blueprint_uspmatch"
BLUEPRINT.model = "models/weapons/w_uspmatch.mdl"
BLUEPRINT.category = "Чертежи оружия"
BLUEPRINT.description = "#Blueprint_BlueprintUspmatch_Description"
BLUEPRINT.craftplace = "cw_craft_wep"
BLUEPRINT.reqatt = {
	{"rem", 40}
}
BLUEPRINT.updatt = {
	{"rem", 20}
}
BLUEPRINT.required = {
	{"screw_driver", 1},
	{"wrench", 1}
}
BLUEPRINT.recipe = {
	{"broken_uspmatch", 2},
	{"reclaimed_metal", 3},
	{"box_of_screws", 2}
}
BLUEPRINT.finish = {
	{"sxbase_uspmatch", 1}
}
BLUEPRINT:Register();