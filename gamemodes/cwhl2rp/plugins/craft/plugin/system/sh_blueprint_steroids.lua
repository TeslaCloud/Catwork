local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintSteroids_Name"
BLUEPRINT.uniqueID = "blueprint_steroids"
BLUEPRINT.model = "models/props_junk/garbage_metalcan002a.mdl"
BLUEPRINT.category = "Медицина"
BLUEPRINT.description = "#Blueprint_BlueprintSteroids_Description"
BLUEPRINT.craftplace = "cw_craft_chem"
BLUEPRINT.updatt = {
	{"chem", 45}
}
BLUEPRINT.reqatt = {
	{"chem", 25}
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
	{"health_vial", 1},
	{"antidepressants", 1}
}
BLUEPRINT.finish = {
	{"steroids", 1}
}
BLUEPRINT:Register();