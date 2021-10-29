local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintAntidepressants_Name"
BLUEPRINT.uniqueID = "blueprint_antidepressants"
BLUEPRINT.model = "models/props_junk/garbage_metalcan001a.mdl"
BLUEPRINT.category = "Медицина"
BLUEPRINT.description = "#Blueprint_BlueprintAntidepressants_Description"
BLUEPRINT.craftplace = "cw_craft_chem"
BLUEPRINT.updatt = {
	{"chem", 15}
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
	{"weed", 3}
}
BLUEPRINT.finish = {
	{"antidepressants", 1}
}
BLUEPRINT:Register();