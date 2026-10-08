--- Disabled `shoot` skill attribute (`ATB_SHOOT`), for proficiency with firearms.
--
-- The whole file is commented out.

--[[
local ATTRIBUTE = cw.attribute:New()
  ATTRIBUTE.name = "Стрельба"
  ATTRIBUTE.maximum = 100
  ATTRIBUTE.uniqueID = "shoot"
  ATTRIBUTE.description = "Определяет, как хорошо Вы управляетесь с огнестрельным оружием."
  ATTRIBUTE.isOnCharScreen = false
  ATTRIBUTE.category = "#AttributeCategory_Skills"
ATB_SHOOT = cw.attribute:Register(ATTRIBUTE)
--]]
