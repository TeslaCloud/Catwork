local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = "#Blueprint_BlueprintBandage_Name"
BLUEPRINT.uniqueID = "blueprint_bandage"
BLUEPRINT.model = "models/props_wasteland/prison_toiletchunk01f.mdl"
BLUEPRINT.category = "#Craft_Category_Misc"
BLUEPRINT.description = "#Blueprint_BlueprintBandage_Description"
BLUEPRINT.updatt = {
	{ "med", 15 }
}
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
	{ "cloth", 1 }
}
BLUEPRINT.finish = {
	{ "bandage", 1 }
}
BLUEPRINT:Register()
