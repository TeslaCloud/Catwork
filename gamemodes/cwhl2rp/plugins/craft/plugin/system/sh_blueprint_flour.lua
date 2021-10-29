local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintFlour_Name"
BLUEPRINT.uniqueID = "blueprint_flour"
BLUEPRINT.model = "models/bioshockinfinite/topcorn_bag.mdl"
BLUEPRINT.category = "Материалы"
BLUEPRINT.description = "#Blueprint_BlueprintFlour_Description"
BLUEPRINT.craftplace = "cw_craft_cook"
BLUEPRINT.reqatt = {}
BLUEPRINT.updatt = {
	{"cook", 10}
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
	{"corn", 1},
	{"empty_carton", 1}
}
BLUEPRINT.finish = {
	{"flour", 1}
}
BLUEPRINT:Register();