local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintZipTie_Name"
BLUEPRINT.uniqueID = "blueprint_zip_tie"
BLUEPRINT.model = "models/items/crossbowrounds.mdl"
BLUEPRINT.category = "Разное"
BLUEPRINT.description = "#Blueprint_BlueprintZipTie_Description"
BLUEPRINT.required = {}
BLUEPRINT.updatt = {
	{"rem", 5}
}
BLUEPRINT.recipe = {
	{"cables", 1},
}
BLUEPRINT.finish = {
	{"zip_tie", 2}
}
BLUEPRINT:Register();