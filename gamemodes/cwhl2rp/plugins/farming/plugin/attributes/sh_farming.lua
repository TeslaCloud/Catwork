--- Registers the Farming attribute (`farm`, global `ATB_FARM`, maximum 100), a skill that speeds up growing and
-- harvesting plants and improves the harvest.

local ATTRIBUTE = cw.attribute:New()
  ATTRIBUTE.name = '#Attribute_Farm'
  ATTRIBUTE.maximum = 100
  ATTRIBUTE.uniqueID = 'farm'
  ATTRIBUTE.description = '#Attribute_Farm_Desc'
  ATTRIBUTE.isOnCharScreen = false
  ATTRIBUTE.category = '#AttributeCategory_Skills'
ATB_FARM = cw.attribute:Register(ATTRIBUTE)
