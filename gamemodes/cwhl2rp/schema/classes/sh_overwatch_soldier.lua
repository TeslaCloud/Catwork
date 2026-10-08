--- Registers the Overwatch Soldier class as `CLASS_OWS`, the default class of `FACTION_OTA`, with wages of 20.

local CLASS = cw.class:New('#Class_OverwatchSoldier')
  CLASS.color = Color(150, 50, 50, 255)
  CLASS.wages = 20
  CLASS.factions = { FACTION_OTA }
  CLASS.isDefault = true
  CLASS.wagesName = '#Class_OverwatchSoldier_Wages'
  CLASS.description = '#Class_OverwatchSoldier_Desc'
  CLASS.defaultPhysDesc = 'Wearing dirty Overwatch gear'
CLASS_OWS = CLASS:Register()
