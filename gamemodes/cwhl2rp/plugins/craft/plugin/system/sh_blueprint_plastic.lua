local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintPlastic_Name"
BLUEPRINT.uniqueID = "blueprint_plastic"
BLUEPRINT.model = "models/props_debris/metal_panelshard01b.mdl"
BLUEPRINT.category = "Переработка мусора"
BLUEPRINT.description = "#Blueprint_BlueprintPlastic_Description"
BLUEPRINT.craftplace = "cw_craft_furnace"
BLUEPRINT.required = {}
BLUEPRINT.updatt = {
	{"rem", 5}
}
BLUEPRINT.recipe = {
	{"empty_tin_can", 3},
}
BLUEPRINT.finish = {
	{"plastic", 1}
}
BLUEPRINT:Register();