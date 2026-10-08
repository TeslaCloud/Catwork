--- Registers the Repair attribute (`rem`, global `ATB_REPAIR`), a crafting skill of up to 100 that is not shown on the
-- character screen.

local ATTRIBUTE = cw.attribute:New()
  ATTRIBUTE.name = '#Attribute_Repair'
  ATTRIBUTE.maximum = 100
  ATTRIBUTE.uniqueID = 'rem'
  ATTRIBUTE.description = '#Attribute_Repair_Desc'
  ATTRIBUTE.isOnCharScreen = false
  ATTRIBUTE.category = '#AttributeCategory_Skills'
ATB_REPAIR = cw.attribute:Register(ATTRIBUTE)
