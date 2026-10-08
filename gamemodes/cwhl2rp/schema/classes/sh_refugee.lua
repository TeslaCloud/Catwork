--- Registers the Refugee class as `CLASS_REFUGE`, the default class of `FACTION_REFUGEE`.

local CLASS = cw.class:New('#Class_Refugee')
  CLASS.color = Color(150, 125, 100, 255)
  CLASS.factions = { FACTION_REFUGEE }
  CLASS.isDefault = true
  CLASS.wagesName = '#Class_Refugee_Wages'
  CLASS.description = '#Class_Refugee_Desc'
  CLASS.defaultPhysDesc = 'Wearing clothes.'
CLASS_REFUGE = CLASS:Register()
