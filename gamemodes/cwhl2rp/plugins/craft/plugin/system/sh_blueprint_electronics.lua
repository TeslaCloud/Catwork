local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintElectronics_Name"
BLUEPRINT.uniqueID = "blueprint_electronics"
BLUEPRINT.model = "models/props_lab/reciever01d.mdl"
BLUEPRINT.category = "Материалы"
BLUEPRINT.description = "#Blueprint_BlueprintElectronics_Description"
BLUEPRINT.reqatt = {}
BLUEPRINT.updatt = {
	{"rem", 15}
}
BLUEPRINT.required = {
	{"screw_driver", 1}
}
BLUEPRINT.recipe = {
	{"scrap_electronics", 2}
}
BLUEPRINT.finish = {
	{"refined_electronics", 1}
}
BLUEPRINT:Register();