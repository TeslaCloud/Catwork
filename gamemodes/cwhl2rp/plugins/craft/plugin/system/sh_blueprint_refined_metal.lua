local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintRefinedMetal_Name"
BLUEPRINT.uniqueID = "blueprint_refined_metal"
BLUEPRINT.model = "models/gibs/metal_gib2.mdl"
BLUEPRINT.category = "Обработка металла"
BLUEPRINT.description = "#Blueprint_BlueprintRefinedMetal_Description"
BLUEPRINT.craftplace = "cw_craft_furnace"
BLUEPRINT.required = {}
BLUEPRINT.updatt = {
	{"rem", 5}
}
BLUEPRINT.recipe = {
	{"reclaimed_metal", 5},
	{"charcoal", 3}
}
BLUEPRINT.finish = {
	{"refined_metal", 2}
}
BLUEPRINT:Register();