local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintChips_Name"
BLUEPRINT.uniqueID = "blueprint_chips"
BLUEPRINT.model = "models/bioshockinfinite/bag_of_hhips.mdl"
BLUEPRINT.category = "Еда"
BLUEPRINT.description = "#Blueprint_BlueprintChips_Description"
BLUEPRINT.craftplace = "cw_craft_cook"
BLUEPRINT.reqatt = {
	{"cook", 10}
}
BLUEPRINT.updatt = {
	{"cook", 15}
}
BLUEPRINT.required = {
	{"weapon_knife", 1},
	{"weapon_hl2pan", 1}
}
BLUEPRINT.recipe = {
	{"potato", 1},
	{"vegetable_oil", 1}
}
BLUEPRINT.finish = {
	{"chips", 1}
}
BLUEPRINT:Register();