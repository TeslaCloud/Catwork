local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintBakedPotato_Name"
BLUEPRINT.uniqueID = "blueprint_baked_potato"
BLUEPRINT.model = "models/bioshockinfinite/hext_potato.mdl"
BLUEPRINT.category = "Еда"
BLUEPRINT.description = "#Blueprint_BlueprintBakedPotato_Description"
BLUEPRINT.craftplace = "cw_craft_cook"
BLUEPRINT.reqatt = {}
BLUEPRINT.updatt = {
	{"cook", 10}
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
	{"potato", 1},
}
BLUEPRINT.finish = {
	{"baked_potato", 1}
}
BLUEPRINT:Register();