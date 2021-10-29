local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintWeld_Name"
BLUEPRINT.uniqueID = "blueprint_weld"
BLUEPRINT.model = "models/props_vehicles/carparts_muffler01a.mdl"
BLUEPRINT.category = "Инструменты"
BLUEPRINT.description = "#Blueprint_BlueprintWeld_Description"
BLUEPRINT.reqatt = {
	{"rem", 20}
}
BLUEPRINT.updatt = {
	{"rem", 25}
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
	{"refined_metal", 2},
	{"refined_electronics", 1}
}
BLUEPRINT.finish = {
	{"weld", 1}
}
BLUEPRINT:Register();