local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintAk74_Name"
BLUEPRINT.uniqueID = "blueprint_ak74"
BLUEPRINT.model = "models/weapons/w_ak74.mdl"
BLUEPRINT.category = "Чертежи оружия"
BLUEPRINT.description = "#Blueprint_BlueprintAk74_Description"
BLUEPRINT.craftplace = "cw_craft_wep"
BLUEPRINT.reqatt = {
	{"rem", 50}
}
BLUEPRINT.updatt = {
	{"rem", 30}
}
BLUEPRINT.required = {
	{"screw_driver", 1},
	{"weld", 1}
}
BLUEPRINT.recipe = {
	{"broken_ak74", 2},
	{"reclaimed_metal", 3},
	{"box_of_screws", 3},
	{"wooden_parts", 2}
}
BLUEPRINT.finish = {
	{"sxbase_ak74", 1}
}
BLUEPRINT:Register();