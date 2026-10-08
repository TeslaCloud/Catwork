--- Registers the Clothes making attribute (`cloth`, global `ATB_CLOTH`), a crafting skill of up to 100 that is not
-- shown on the character screen.

local ATTRIBUTE = cw.attribute:New()
  ATTRIBUTE.name = '#Attribute_Cloth'
  ATTRIBUTE.maximum = 100
  ATTRIBUTE.uniqueID = 'cloth'
  ATTRIBUTE.description = '#Attribute_Cloth_Desc'
  ATTRIBUTE.isOnCharScreen = false
  ATTRIBUTE.category = '#AttributeCategory_Skills'
ATB_CLOTH = cw.attribute:Register(ATTRIBUTE)
