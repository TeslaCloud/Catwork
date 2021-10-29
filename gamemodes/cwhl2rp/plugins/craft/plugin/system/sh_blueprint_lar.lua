local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintLar_Name"
BLUEPRINT.uniqueID = "blueprint_lar"
BLUEPRINT.model = "models/rtb_weapons/w_sniper.mdl"
BLUEPRINT.category = "Чертежи оружия"
BLUEPRINT.description = "#Blueprint_BlueprintLar_Description"
BLUEPRINT.craftplace = "cw_craft_wep"
BLUEPRINT.reqatt = {
	{"rem", 90}
}
BLUEPRINT.updatt = {
	{"rem", 80}
}
BLUEPRINT.required = {
	{"screw_driver", 1},
	{"weld", 1},
	{"wrench", 1}
}
BLUEPRINT.recipe = {
	{"broken_lar", 2},
	{"reclaimed_metal", 4},
	{"box_of_screws", 3},
	{"plastic", 3},
	{"empty_glass_bottle", 2}
}
BLUEPRINT.finish = {
	{"sxbase_lar", 1}
}
BLUEPRINT:Register();