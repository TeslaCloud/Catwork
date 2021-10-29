local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintBreach_Name"
BLUEPRINT.uniqueID = "blueprint_breach"
BLUEPRINT.model = "models/props_wasteland/prison_padlock001a.mdl"
BLUEPRINT.category = "Взрывчатка"
BLUEPRINT.description = "#Blueprint_BlueprintBreach_Description"
BLUEPRINT.craftplace = "cw_craft_chem"
BLUEPRINT.reqatt = {
	{"chem", 40}
}
BLUEPRINT.updatt = {
	{"chem", 20}
}
BLUEPRINT.required = {
	{"screw_driver", 1}
}
BLUEPRINT.recipe = {
	{"gunpowder", 3},
	{"cables", 1},
	{"refined_electronics", 1},
	{"energy_cell", 1},
}
BLUEPRINT.finish = {
	{"breach", 2}
}
BLUEPRINT:Register();