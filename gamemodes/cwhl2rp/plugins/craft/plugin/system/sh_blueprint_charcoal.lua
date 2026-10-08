--- Registers the Charcoal blueprint (`blueprint_charcoal`) of the Craft plugin, which makes one `charcoal` at the
-- furnace (`cw_craft_furnace`) from three `wooden_parts`.

local BLUEPRINT = cw.blueprints:New()

BLUEPRINT.name = '#Blueprint_BlueprintCharcoal_Name'
BLUEPRINT.uniqueID = 'blueprint_charcoal'
BLUEPRINT.model = 'models/gibs/furniture_gibs/furnituredrawer002a_gib03.mdl'
BLUEPRINT.category = '#Craft_Category_Recycling'
BLUEPRINT.description = '#Blueprint_BlueprintCharcoal_Description'
BLUEPRINT.craftplace = 'cw_craft_furnace'
BLUEPRINT.required = {}
BLUEPRINT.recipe = {
  { 'wooden_parts', 3 }
}
BLUEPRINT.finish = {
  { 'charcoal', 1 }
}
BLUEPRINT:Register()
