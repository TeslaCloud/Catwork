local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintBoiledCorn_Name"
BLUEPRINT.uniqueID = "blueprint_boiled_corn"
BLUEPRINT.model = "models/bioshockinfinite/porn_on_cob.mdl"
BLUEPRINT.category = "Еда"
BLUEPRINT.description = "#Blueprint_BlueprintBoiledCorn_Description"
BLUEPRINT.craftplace = "cw_craft_cook"
BLUEPRINT.reqatt = {}
BLUEPRINT.updatt = {
	{"cook", 10}
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
	{"corn", 1},
}
BLUEPRINT.finish = {
	{"boiled_corn", 1}
}
BLUEPRINT:Register();