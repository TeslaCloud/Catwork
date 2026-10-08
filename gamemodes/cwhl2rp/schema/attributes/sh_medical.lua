--- Registers the Medical attribute (`med`, maximum 100) as `ATB_MEDICAL`, a skill that is not shown on the character
-- creation screen.

local ATTRIBUTE = cw.attribute:New()
  ATTRIBUTE.name = '#Attribute_Medical'
  ATTRIBUTE.maximum = 100
  ATTRIBUTE.uniqueID = 'med'
  ATTRIBUTE.description = '#Attribute_Medical_Desc'
  ATTRIBUTE.isOnCharScreen = false
  ATTRIBUTE.category = '#AttributeCategory_Skills'
ATB_MEDICAL = cw.attribute:Register(ATTRIBUTE)
