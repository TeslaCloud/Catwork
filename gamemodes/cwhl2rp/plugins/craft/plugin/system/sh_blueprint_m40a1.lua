local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintM40a1_Name"
BLUEPRINT.uniqueID = "blueprint_m40a1"
BLUEPRINT.model = "models/items/m40a1.mdl"
BLUEPRINT.category = "Чертежи оружия"
BLUEPRINT.description = "#Blueprint_BlueprintM40a1_Description"
BLUEPRINT.craftplace = "cw_craft_wep"
BLUEPRINT.reqatt = {
	{"rem", 60}
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
	{"broken_m40a1", 2},
	{"reclaimed_metal", 3},
	{"box_of_screws", 3},
	{"plastic", 3},
	{"empty_glass_bottle", 2}
}
BLUEPRINT.finish = {
	{"sxbase_m40a1", 1}
}
BLUEPRINT:Register();