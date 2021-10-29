local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintMp7_Name"
BLUEPRINT.uniqueID = "blueprint_mp7"
BLUEPRINT.model = "models/weapons/w_smg1.mdl"
BLUEPRINT.category = "Чертежи оружия"
BLUEPRINT.description = "#Blueprint_BlueprintMp7_Description"
BLUEPRINT.craftplace = "cw_craft_wep"
BLUEPRINT.reqatt = {
	{"rem", 70}
}
BLUEPRINT.updatt = {
	{"rem", 30}
}
BLUEPRINT.required = {
	{"screw_driver", 1},
	{"weld", 1},
	{"wrench", 1}
}
BLUEPRINT.recipe = {
	{"broken_mp7", 2},
	{"reclaimed_metal", 3},
	{"box_of_screws", 2},
	{"box_of_bolts", 2}
}
BLUEPRINT.finish = {
	{"sxbase_mp7", 1}
}
BLUEPRINT:Register();