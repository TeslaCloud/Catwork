local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintCwuLegs_Name"
BLUEPRINT.uniqueID = "blueprint_cwu_legs"
BLUEPRINT.model = "models/tnb/items/pants_citizen.mdl"
BLUEPRINT.category = "Одежда"
BLUEPRINT.description = "#Blueprint_BlueprintCwuLegs_Description"
BLUEPRINT.required = {}
BLUEPRINT.updatt = {
	{"cloth", 45}
}
BLUEPRINT.reqatt = {
	{"cloth", 15}
}
BLUEPRINT.recipe = {
	{"cloth", 3},
}
BLUEPRINT.finish = {
	{"cwu_legs", 1}
}
BLUEPRINT:Register();