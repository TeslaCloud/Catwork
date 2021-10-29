local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintCharcoal_Name"
BLUEPRINT.uniqueID = "blueprint_charcoal"
BLUEPRINT.model = "models/gibs/furniture_gibs/furnituredrawer002a_gib03.mdl"
BLUEPRINT.category = "Переработка мусора"
BLUEPRINT.description = "#Blueprint_BlueprintCharcoal_Description"
BLUEPRINT.craftplace = "cw_craft_furnace"
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
	{"wooden_parts", 3},
}
BLUEPRINT.finish = {
	{"charcoal", 1}
}
BLUEPRINT:Register();