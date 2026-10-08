--- Disabled `melee` skill attribute (`ATB_MELEE`), for proficiency with melee weapons and unarmed combat.
--
-- The whole file is commented out.

--[[
local ATTRIBUTE = cw.attribute:New()
  ATTRIBUTE.name = "Ближний бой"
  ATTRIBUTE.maximum = 100
  ATTRIBUTE.uniqueID = "melee"
  ATTRIBUTE.description = "Определяет, как хорошо Вы владеете холодным оружием и рукопашным боем."
  ATTRIBUTE.isOnCharScreen = false
  ATTRIBUTE.category = "#AttributeCategory_Skills"
ATB_MELEE = cw.attribute:Register(ATTRIBUTE)
--]]
