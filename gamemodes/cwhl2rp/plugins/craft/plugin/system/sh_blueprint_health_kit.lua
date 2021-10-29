local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintHealthKit_Name"
BLUEPRINT.uniqueID = "blueprint_health_kit"
BLUEPRINT.model = "models/items/healthkit.mdl"
BLUEPRINT.category = "Медицина"
BLUEPRINT.description = "#Blueprint_BlueprintHealthKit_Description"
BLUEPRINT.craftplace = "cw_craft_chem"
BLUEPRINT.updatt = {
	{"chem", 55}
}
BLUEPRINT.reqatt = {
	{"chem", 30}
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
	{"plastic", 1},
	{"health_vial", 1},
	{"refined_electronics", 1}
}
BLUEPRINT.finish = {
	{"health_kit", 1},
}
BLUEPRINT:Register();