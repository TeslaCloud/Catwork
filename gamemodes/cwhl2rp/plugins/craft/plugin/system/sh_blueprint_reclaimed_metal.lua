local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintReclaimedMetal_Name"
BLUEPRINT.uniqueID = "blueprint_reclaimed_metal"
BLUEPRINT.model = "models/props_lab/pipesystem03a.mdl"
BLUEPRINT.category = "Обработка металла"
BLUEPRINT.description = "#Blueprint_BlueprintReclaimedMetal_Description"
BLUEPRINT.craftplace = "cw_craft_furnace"
BLUEPRINT.updatt = {
	{"rem", 5}
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
	{"scrap_metal", 5},
	{"charcoal", 2}
}
BLUEPRINT.finish = {
	{"reclaimed_metal", 1}
}
BLUEPRINT:Register();