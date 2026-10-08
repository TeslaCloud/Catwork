--- Registers the Cooking attribute (`cook`, global `ATB_COOK`), a crafting skill of up to 100 that is not shown on the
-- character screen.

local ATTRIBUTE = cw.attribute:New()
  ATTRIBUTE.name = '#Attribute_Cook'
  ATTRIBUTE.maximum = 100
  ATTRIBUTE.uniqueID = 'cook'
  ATTRIBUTE.description = '#Attribute_Cook_Desc'
  ATTRIBUTE.isOnCharScreen = false
  ATTRIBUTE.category = '#AttributeCategory_Skills'
ATB_COOK = cw.attribute:Register(ATTRIBUTE)
