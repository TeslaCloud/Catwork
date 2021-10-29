local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintHealVial_Name"
BLUEPRINT.uniqueID = "blueprint_heal_vial"
BLUEPRINT.model = "models/healthvial.mdl"
BLUEPRINT.category = "Медицина"
BLUEPRINT.description = "#Blueprint_BlueprintHealVial_Description"
BLUEPRINT.craftplace = "cw_craft_chem"
BLUEPRINT.updatt = {
	{"chem", 35}
}
BLUEPRINT.reqatt = {
	{"chem", 10}
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
	{"plastic", 1},
	{"citizen_supplements", 1},
	{"vodka", 1}
}
BLUEPRINT.finish = {
	{"health_vial", 1},
	{"empty_glass_bottle", 1},
}
BLUEPRINT:Register();