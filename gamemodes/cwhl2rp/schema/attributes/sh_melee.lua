--- Disabled `melee` skill attribute (`ATB_MELEE`), for proficiency with melee weapons and unarmed combat.
--
-- The whole file is commented out.

--[[
local ATTRIBUTE = cw.attribute:New()
  ATTRIBUTE.name = '#Attribute_Melee'
  ATTRIBUTE.maximum = 100
  ATTRIBUTE.uniqueID = "melee"
  ATTRIBUTE.description = '#Attribute_Melee_Desc'
  ATTRIBUTE.isOnCharScreen = false
  ATTRIBUTE.category = "#AttributeCategory_Skills"
ATB_MELEE = cw.attribute:Register(ATTRIBUTE)
--]]
