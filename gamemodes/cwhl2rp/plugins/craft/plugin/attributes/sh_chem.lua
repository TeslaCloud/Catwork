--- Registers the Chemistry attribute (`chem`, global `ATB_CHEM`), a crafting skill of up to 100 that is not shown on
-- the character screen.

local ATTRIBUTE = cw.attribute:New()
  ATTRIBUTE.name = '#Attribute_Chem'
  ATTRIBUTE.maximum = 100
  ATTRIBUTE.uniqueID = 'chem'
  ATTRIBUTE.description = '#Attribute_Chem_Desc'
  ATTRIBUTE.isOnCharScreen = false
  ATTRIBUTE.category = '#AttributeCategory_Skills'
ATB_CHEM = cw.attribute:Register(ATTRIBUTE)
