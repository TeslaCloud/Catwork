local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintMedicLegs_Name"
BLUEPRINT.uniqueID = "blueprint_medic_legs"
BLUEPRINT.model = "models/tnb/items/pants_rebel.mdl"
BLUEPRINT.category = "Одежда"
BLUEPRINT.description = "#Blueprint_BlueprintMedicLegs_Description"
BLUEPRINT.required = {}
BLUEPRINT.updatt = {
	{"cloth", 65}
}
BLUEPRINT.reqatt = {
	{"cloth", 65}
}
BLUEPRINT.recipe = {
	{"cloth", 5},
	{"refined_metal", 2}
}
BLUEPRINT.finish = {
	{"rebel_legs_3", 1}
}
BLUEPRINT:Register();