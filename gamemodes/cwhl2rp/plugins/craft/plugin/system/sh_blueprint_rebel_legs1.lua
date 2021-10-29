local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintRebelLegs1_Name"
BLUEPRINT.uniqueID = "blueprint_rebel_legs"
BLUEPRINT.skin = 1
BLUEPRINT.model = "models/tnb/items/pants_rebel.mdl"
BLUEPRINT.category = "Одежда"
BLUEPRINT.description = "#Blueprint_BlueprintRebelLegs1_Description"
BLUEPRINT.required = {}
BLUEPRINT.updatt = {
	{"cloth", 55}
}
BLUEPRINT.reqatt = {
	{"cloth", 55}
}
BLUEPRINT.recipe = {
	{"cloth", 5},
	{"refined_metal", 1}
}
BLUEPRINT.finish = {
	{"rebel_legs_1", 1}
}
BLUEPRINT:Register();