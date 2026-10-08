--- Registers the Endurance attribute (`end`, maximum 75) as `ATB_ENDURANCE`, a characteristic that can be set on the
-- character creation screen.

local ATTRIBUTE = cw.attribute:New()
  ATTRIBUTE.name = '#Attribute_Endurance'
  ATTRIBUTE.maximum = 75
  ATTRIBUTE.uniqueID = 'end'
  ATTRIBUTE.description = '#Attribute_Endurance_Desc'
  ATTRIBUTE.isOnCharScreen = true
  ATTRIBUTE.category = '#AttributeCategory_Stats'
ATB_ENDURANCE = cw.attribute:Register(ATTRIBUTE)
