local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintCitUniform2_Name"
BLUEPRINT.uniqueID = "blueprint_uniform_2"
BLUEPRINT.model = "models/tnb/items/shirt_citizen2.mdl"
BLUEPRINT.category = "Одежда"
BLUEPRINT.description = "#Blueprint_BlueprintCitUniform2_Description"
BLUEPRINT.required = {}
BLUEPRINT.updatt = {
	{"cloth", 35}
}
BLUEPRINT.reqatt = {
	{"cloth", 10}
}
BLUEPRINT.recipe = {
	{"cloth", 4},
}
BLUEPRINT.finish = {
	{"cit_uniform_2", 1}
}
BLUEPRINT:Register();