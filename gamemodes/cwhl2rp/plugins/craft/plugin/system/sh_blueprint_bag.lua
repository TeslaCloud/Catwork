local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintBag_Name"
BLUEPRINT.uniqueID = "blueprint_bag"
BLUEPRINT.model = "models/props_junk/cardboard_box004a.mdl"
BLUEPRINT.category = "Хранилища"
BLUEPRINT.description = "#Blueprint_BlueprintBag_Description"
BLUEPRINT.reqatt = {
	{"cloth", 15}
}
BLUEPRINT.updatt = {
	{"cloth", 15}
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
	{"cloth", 1},
	{"cables", 1}
}
BLUEPRINT.finish = {
	{"boxed_bag", 1}
}
BLUEPRINT:Register();