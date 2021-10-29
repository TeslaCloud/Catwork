local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintTakeout_Name"
BLUEPRINT.uniqueID = "blueprint_takeout"
BLUEPRINT.model = "models/props_junk/garbage_takeoutcarton001a.mdl"
BLUEPRINT.category = "Еда"
BLUEPRINT.description = "#Blueprint_BlueprintTakeout_Description"
BLUEPRINT.craftplace = "cw_craft_cook"
BLUEPRINT.reqatt = {}
BLUEPRINT.updatt = {
	{"cook", 15}
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
	{"flour", 1},
	{"breens_water", 1}
}
BLUEPRINT.finish = {
	{"chinese_takeout", 1},
	{"empty_soda_can", 1}
}
BLUEPRINT:Register();