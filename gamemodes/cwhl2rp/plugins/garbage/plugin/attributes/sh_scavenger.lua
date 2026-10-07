--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local ATTRIBUTE = cw.attribute:New()
  ATTRIBUTE.name = '#Attribute_Scavenger'
  ATTRIBUTE.maximum = 75
  ATTRIBUTE.uniqueID = 'scv'
  ATTRIBUTE.description = '#Attribute_Scavenger_Desc'
  ATTRIBUTE.isOnCharScreen = false
  ATTRIBUTE.category = '#AttributeCategory_Skills'
ATB_SCAVENGER = cw.attribute:Register(ATTRIBUTE)
