local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintScrewdriver_Name"
BLUEPRINT.uniqueID = "blueprint_screwdriver"
BLUEPRINT.model = "models/props_c17/TrapPropeller_Lever.mdl"
BLUEPRINT.category = "Инструменты"
BLUEPRINT.description = "#Blueprint_BlueprintScrewdriver_Description"
BLUEPRINT.reqatt = {
	{"rem", 10}
}
BLUEPRINT.updatt = {
	{"rem", 15}
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
	{"refined_metal", 1}
}
BLUEPRINT.finish = {
	{"screw_driver", 1}
}
BLUEPRINT:Register();