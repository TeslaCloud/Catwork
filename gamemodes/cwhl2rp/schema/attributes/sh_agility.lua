--- Registers the Agility attribute (`agt`, maximum 75) as `ATB_AGILITY`, a characteristic that can be set on the
-- character creation screen.

local ATTRIBUTE = cw.attribute:New()
  ATTRIBUTE.name = '#Attribute_Agility'
  ATTRIBUTE.maximum = 75
  ATTRIBUTE.uniqueID = 'agt'
  ATTRIBUTE.description = '#Attribute_Agility_Desc'
  ATTRIBUTE.isOnCharScreen = true
  ATTRIBUTE.category = '#AttributeCategory_Stats'
ATB_AGILITY = cw.attribute:Register(ATTRIBUTE)
