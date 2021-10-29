local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintM1911_Name"
BLUEPRINT.uniqueID = "blueprint_m1911"
BLUEPRINT.model = "models/weapons/w_1911_1.mdl"
BLUEPRINT.category = "Чертежи оружия"
BLUEPRINT.description = "#Blueprint_BlueprintM1911_Description"
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
	{"broken_m1911", 2},
	{"reclaimed_metal", 2},
	{"box_of_screws", 2}
}
BLUEPRINT.finish = {
	{"sxbase_m1911", 1}
}
BLUEPRINT:Register();