--- Registers the Elite Metropolice class as `CLASS_EMP`, a `FACTION_MPF` class with wages of 30.

local CLASS = cw.class:New('#Class_MPFElite')
  CLASS.color = Color(50, 100, 150, 255)
  CLASS.wages = 30
  CLASS.factions = { FACTION_MPF }
  CLASS.wagesName = '#Class_MPFElite_Wages'
  CLASS.description = '#Class_MPFElite_Desc'
  CLASS.defaultPhysDesc = 'Wearing a metrocop jacket with a radio'
CLASS_EMP = CLASS:Register()
