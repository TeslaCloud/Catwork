--- Registers the Strength attribute (`str`, maximum 75) as `ATB_STRENGTH`, a characteristic that can be set on the
-- character creation screen.

local ATTRIBUTE = cw.attribute:New()
  ATTRIBUTE.name = '#Attribute_Strength'
  ATTRIBUTE.maximum = 75
  ATTRIBUTE.uniqueID = 'str'
  ATTRIBUTE.description = '#Attribute_Strength_Desc'
  ATTRIBUTE.isOnCharScreen = true
  ATTRIBUTE.category = '#AttributeCategory_Stats'
ATB_STRENGTH = cw.attribute:Register(ATTRIBUTE)
