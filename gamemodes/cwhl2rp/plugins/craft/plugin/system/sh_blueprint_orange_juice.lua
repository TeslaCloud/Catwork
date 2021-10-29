local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintOrangeJuice_Name"
BLUEPRINT.uniqueID = "blueprint_orange_juice"
BLUEPRINT.model = "models/props_nunk/popcan01a.mdl"
BLUEPRINT.category = "Напитки"
BLUEPRINT.description = "#Blueprint_BlueprintOrangeJuice_Description"
BLUEPRINT.craftplace = "cw_craft_cook"
BLUEPRINT.reqatt = {}
BLUEPRINT.updatt = {
	{"cook", 10}
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
	{"orange_cleaned", 2},
	{"empty_soda_can", 1}
}
BLUEPRINT.finish = {
	{"orange_juice", 1}
}
BLUEPRINT:Register();