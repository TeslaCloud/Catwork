local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintBread_Name"
BLUEPRINT.uniqueID = "blueprint_bread"
BLUEPRINT.model = "models/bioshockinfinite/dread_loaf.mdl"
BLUEPRINT.category = "Еда"
BLUEPRINT.description = "#Blueprint_BlueprintBread_Description"
BLUEPRINT.craftplace = "cw_craft_cook"
BLUEPRINT.reqatt = {
	{"cook", 5}
}
BLUEPRINT.updatt = {
	{"cook", 30}
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
	{"flour", 1},
	{"breens_water", 1},
}
BLUEPRINT.finish = {
	{"bread", 1},
	{"empty_carton", 1},
	{"empty_soda_can", 1}
}
BLUEPRINT:Register();