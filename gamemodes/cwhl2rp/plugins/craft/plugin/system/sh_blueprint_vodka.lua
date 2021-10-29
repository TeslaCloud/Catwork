local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintVodka_Name"
BLUEPRINT.uniqueID = "blueprint_vodka"
BLUEPRINT.model = "models/props_junk/garbage_glassbottle002a.mdl"
BLUEPRINT.category = "Алкоголь"
BLUEPRINT.description = "#Blueprint_BlueprintVodka_Description"
BLUEPRINT.craftplace = "cw_craft_chem"
BLUEPRINT.updatt = {
	{"chem", 25}
}
BLUEPRINT.reqatt = {
	{"chem", 5}
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
	{"empty_glass_bottle", 1},
	{"breens_water", 1},
	{"potato", 2}
}
BLUEPRINT.finish = {
	{"vodka", 1},
	{"empty_soda_can", 1}
}
BLUEPRINT:Register();