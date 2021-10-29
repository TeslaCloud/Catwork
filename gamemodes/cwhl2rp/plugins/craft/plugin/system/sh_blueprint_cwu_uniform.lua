local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintCwuUniform_Name"
BLUEPRINT.uniqueID = "blueprint_cwu_uniform"
BLUEPRINT.model = "models/tnb/items/shirt_citizen1.mdl"
BLUEPRINT.category = "Одежда"
BLUEPRINT.description = "#Blueprint_BlueprintCwuUniform_Description"
BLUEPRINT.required = {}
BLUEPRINT.updatt = {
	{"cloth", 45}
}
BLUEPRINT.reqatt = {
	{"cloth", 20}
}
BLUEPRINT.recipe = {
	{"cloth", 5},
}
BLUEPRINT.finish = {
	{"cwu_uniform", 1}
}
BLUEPRINT:Register();