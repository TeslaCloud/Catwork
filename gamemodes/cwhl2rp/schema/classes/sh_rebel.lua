--- Registers the Rebel class as `CLASS_REBEL`, the default class of `FACTION_REBEL`.

local CLASS = cw.class:New('#Class_Rebel')
  CLASS.color = Color(150, 125, 100, 255)
  CLASS.factions = { FACTION_REBEL }
  CLASS.isDefault = true
  CLASS.wagesName = '#Class_Rebel_Wages'
  CLASS.description = '#Class_Rebel_Desc'
  CLASS.defaultPhysDesc = 'Wearing clothes.'
CLASS_REBEL = CLASS:Register()
