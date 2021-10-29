local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintPlastic2_Name"
BLUEPRINT.uniqueID = "blueprint_plastic_2"
BLUEPRINT.model = "models/props_debris/metal_panelshard01b.mdl"
BLUEPRINT.category = "Переработка мусора"
BLUEPRINT.description = "#Blueprint_BlueprintPlastic2_Description"
BLUEPRINT.craftplace = "cw_craft_furnace"
BLUEPRINT.updatt = {
	{"rem", 5}
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
	{"empty_tin_can", 1},
	{"empty_plastic_bottle", 2},
}
BLUEPRINT.finish = {
	{"plastic", 1}
}
BLUEPRINT:Register();