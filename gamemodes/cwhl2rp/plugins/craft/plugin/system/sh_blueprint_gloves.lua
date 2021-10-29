local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintGloves_Name"
BLUEPRINT.uniqueID = "blueprint_gloves"
BLUEPRINT.model = "models/tnb/items/gloves.mdl"
BLUEPRINT.category = "Одежда"
BLUEPRINT.description = "#Blueprint_BlueprintGloves_Description"
BLUEPRINT.required = {}
BLUEPRINT.updatt = {
	{"cloth", 15}
}
BLUEPRINT.recipe = {
	{"cloth", 1},
}
BLUEPRINT.finish = {
	{"gloves", 1}
}
BLUEPRINT:Register();