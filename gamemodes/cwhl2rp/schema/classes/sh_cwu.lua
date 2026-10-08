--- Registers the Civil Worker's Union class as `CLASS_CWU`, the default class of `FACTION_CWU`, with wages of 8.

local CLASS = cw.class:New('#Class_CWU')
  CLASS.color = Color(240, 220, 100, 255)
  CLASS.factions = { FACTION_CWU }
  CLASS.wages = 8
  CLASS.isDefault = true
  CLASS.wagesName = '#Class_CWU_Wages'
  CLASS.description = '#Class_CWU_Desc'
  CLASS.defaultPhysDesc = 'Wearing clothes. wow.'
CLASS_CWU = CLASS:Register()
