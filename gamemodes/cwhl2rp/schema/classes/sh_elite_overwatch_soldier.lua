--- Registers the Elite Overwatch Soldier class as `CLASS_EOW`, a `FACTION_OTA` class with wages of 25 that uses the
-- Combine super soldier model.

local CLASS = cw.class:New('#Class_OverwatchSoldierElite')
  CLASS.color = Color(150, 50, 50, 255)
  CLASS.wages = 25
  CLASS.factions = { FACTION_OTA }
  CLASS.wagesName = '#Class_OverwatchSoldierElite_Wages'
  CLASS.maleModel = 'models/combine_super_soldier.mdl'
  CLASS.description = '#Class_OverwatchSoldierElite_Desc'
  CLASS.defaultPhysDesc = 'Wearing shiny Overwatch gear'
CLASS_EOW = CLASS:Register()
