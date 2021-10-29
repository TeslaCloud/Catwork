local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintParacetamol_Name"
BLUEPRINT.uniqueID = "blueprint_paracetamol"
BLUEPRINT.model = "models/props_junk/garbage_metalcan002a.mdl"
BLUEPRINT.category = "Медицина"
BLUEPRINT.description = "#Blueprint_BlueprintParacetamol_Description"
BLUEPRINT.craftplace = "cw_craft_chem"
BLUEPRINT.updatt = {
	{"chem", 35}
}
BLUEPRINT.reqatt = {
	{"chem", 15}
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
	{"health_vial", 1},
	{"charcoal", 1},
	{"vodka", 1}
}
BLUEPRINT.finish = {
	{"paracetamol", 1},
	{"empty_glass_bottle", 1},
}
BLUEPRINT:Register();