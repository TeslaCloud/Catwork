local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintLoyalistLegs_Name"
BLUEPRINT.uniqueID = "blueprint_loyalist_legs"
BLUEPRINT.skin = 3
BLUEPRINT.model = "models/tnb/items/pants_citizen.mdl"
BLUEPRINT.category = "Одежда"
BLUEPRINT.description = "#Blueprint_BlueprintLoyalistLegs_Description"
BLUEPRINT.required = {}
BLUEPRINT.updatt = {
	{"cloth", 35}
}
BLUEPRINT.reqatt = {
	{"cloth", 25}
}
BLUEPRINT.recipe = {
	{"cloth", 4},
}
BLUEPRINT.finish = {
	{"loyalist_legs", 1}
}
BLUEPRINT:Register();