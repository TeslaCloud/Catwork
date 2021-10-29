local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintBeer_Name"
BLUEPRINT.uniqueID = "blueprint_beer"
BLUEPRINT.model = "models/props_junk/garbage_glassbottle002a.mdl"
BLUEPRINT.category = "Алкоголь"
BLUEPRINT.description = "#Blueprint_BlueprintBeer_Description"
BLUEPRINT.craftplace = "cw_craft_chem"
BLUEPRINT.updatt = {
	{"chem", 25}
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
	{"corn", 2},
	{"empty_glass_bottle", 1},
	{"breens_water", 1}
}
BLUEPRINT.finish = {
	{"beer", 1},
	{"empty_soda_can", 1}
}
BLUEPRINT:Register();