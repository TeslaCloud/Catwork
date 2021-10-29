local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintBlueBeanie_Name"
BLUEPRINT.uniqueID = "blueprint_blue_beanie"
BLUEPRINT.model = "models/tnb/items/beanie.mdl"
BLUEPRINT.category = "Одежда"
BLUEPRINT.description = "#Blueprint_BlueprintBlueBeanie_Description"
BLUEPRINT.required = {}
BLUEPRINT.updatt = {
	{"cloth", 25}
}
BLUEPRINT.recipe = {
	{"cloth", 2},
}
BLUEPRINT.finish = {
	{"blue_beanie", 1}
}
BLUEPRINT:Register();