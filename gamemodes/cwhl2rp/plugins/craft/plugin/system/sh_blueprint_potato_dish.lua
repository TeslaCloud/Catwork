local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintPotatoDish_Name"
BLUEPRINT.uniqueID = "blueprint_potato_dish"
BLUEPRINT.model = "models/props_junk/garbage_takeoutcarton001a.mdl"
BLUEPRINT.category = "Еда"
BLUEPRINT.description = "#Blueprint_BlueprintPotatoDish_Description"
BLUEPRINT.craftplace = "cw_craft_cook"
BLUEPRINT.reqatt = {
	{"cook", 20}
}
BLUEPRINT.updatt = {
	{"cook", 40}
}
BLUEPRINT.required = {
	{"weapon_knife", 1},
	{"weapon_hl2pan", 1}
}
BLUEPRINT.recipe = {
	{"potato", 1},
	{"tomato", 1},
	{"corn", 1}
}
BLUEPRINT.finish = {
	{"potato_dish", 1}
}
BLUEPRINT:Register();