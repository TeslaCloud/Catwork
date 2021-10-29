local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintBandana_Name"
BLUEPRINT.uniqueID = "blueprint_bandana"
BLUEPRINT.model = "models/tnb/items/facewrap.mdl"
BLUEPRINT.category = "Одежда"
BLUEPRINT.description = "#Blueprint_BlueprintBandana_Description"
BLUEPRINT.required = {}
BLUEPRINT.updatt = {
	{"cloth", 15}
}
BLUEPRINT.recipe = {
	{"cloth", 1},
}
BLUEPRINT.finish = {
	{"bandana", 1}
}
BLUEPRINT:Register();