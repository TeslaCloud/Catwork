local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintPp19_Name"
BLUEPRINT.uniqueID = "blueprint_pp19"
BLUEPRINT.model = "models/weapons/w_smg_biz.mdl"
BLUEPRINT.category = "Чертежи оружия"
BLUEPRINT.description = "#Blueprint_BlueprintPp19_Description"
BLUEPRINT.craftplace = "cw_craft_wep"
BLUEPRINT.reqatt = {
	{"rem", 65}
}
BLUEPRINT.updatt = {
	{"rem", 40}
}
BLUEPRINT.required = {
	{"screw_driver", 1},
	{"weld", 1},
	{"wrench", 1}
}
BLUEPRINT.recipe = {
	{"broken_pp19", 2},
	{"reclaimed_metal", 3},
	{"box_of_screws", 2},
	{"box_of_bolts", 2}
}
BLUEPRINT.finish = {
	{"sxbase_pp19", 1}
}
BLUEPRINT:Register();