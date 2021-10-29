local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintGasmask_Name"
BLUEPRINT.uniqueID = "blueprint_gasmask"
BLUEPRINT.model = "models/tnb/items/gasmask.mdl"
BLUEPRINT.category = "Одежда"
BLUEPRINT.description = "#Blueprint_BlueprintGasmask_Description"
BLUEPRINT.required = {}
BLUEPRINT.updatt = {
	{"rem", 35}
}
BLUEPRINT.reqatt = {
	{"rem", 20}
}
BLUEPRINT.recipe = {
	{"plastic", 2},
	{"charcoal", 2}
}
BLUEPRINT.finish = {
	{"gasmask", 1}
}
BLUEPRINT:Register();