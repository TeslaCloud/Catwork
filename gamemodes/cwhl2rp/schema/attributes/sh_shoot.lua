--- Disabled `shoot` skill attribute (`ATB_SHOOT`), for proficiency with firearms.
--
-- The whole file is commented out.

--[[
local ATTRIBUTE = cw.attribute:New()
  ATTRIBUTE.name = '#Attribute_Shoot'
  ATTRIBUTE.maximum = 100
  ATTRIBUTE.uniqueID = "shoot"
  ATTRIBUTE.description = '#Attribute_Shoot_Desc'
  ATTRIBUTE.isOnCharScreen = false
  ATTRIBUTE.category = "#AttributeCategory_Skills"
ATB_SHOOT = cw.attribute:Register(ATTRIBUTE)
--]]
