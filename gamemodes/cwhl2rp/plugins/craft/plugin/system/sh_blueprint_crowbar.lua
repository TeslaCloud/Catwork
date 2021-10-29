local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintCrowbar_Name"
BLUEPRINT.uniqueID = "blueprint_crowbar"
BLUEPRINT.model = "models/weapons/w_crowbar.mdl"
BLUEPRINT.category = "Чертежи оружия"
BLUEPRINT.description = "#Blueprint_BlueprintCrowbar_Description"
BLUEPRINT.reqatt = {
	{"rem", 20}
}
BLUEPRINT.updatt = {
	{"rem", 20}
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
	{"refined_metal", 2},
}
BLUEPRINT.finish = {
	{"weapon_crowbar", 1}
}
BLUEPRINT:Register();