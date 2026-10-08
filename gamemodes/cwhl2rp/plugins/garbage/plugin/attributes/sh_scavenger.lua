--- Registers the Scavenger attribute (`scv`, global `ATB_SCAVENGER`, maximum 75), a skill that speeds up searching
-- garbage and improves what is found.

local ATTRIBUTE = cw.attribute:New()
  ATTRIBUTE.name = '#Attribute_Scavenger'
  ATTRIBUTE.maximum = 75
  ATTRIBUTE.uniqueID = 'scv'
  ATTRIBUTE.description = '#Attribute_Scavenger_Desc'
  ATTRIBUTE.isOnCharScreen = false
  ATTRIBUTE.category = '#AttributeCategory_Skills'
ATB_SCAVENGER = cw.attribute:Register(ATTRIBUTE)
