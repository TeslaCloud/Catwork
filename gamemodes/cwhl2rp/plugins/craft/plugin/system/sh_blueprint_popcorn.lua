local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintPopcorn_Name"
BLUEPRINT.uniqueID = "blueprint_popcorn"
BLUEPRINT.model = "models/bioshockinfinite/topcorn_bag.mdl"
BLUEPRINT.category = "Еда"
BLUEPRINT.description = "#Blueprint_BlueprintPopcorn_Description"
BLUEPRINT.craftplace = "cw_craft_cook"
BLUEPRINT.reqatt = {
	{"cook", 10}
}
BLUEPRINT.updatt = {
	{"cook", 10}
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
	{"corn", 2},
	{"empty_carton", 3}
}
BLUEPRINT.finish = {
	{"popcorn", 3}
}
BLUEPRINT:Register();