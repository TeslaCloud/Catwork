--- Registers the Metropolice Scanner class as `CLASS_MPS`, a `FACTION_MPF` class without wages.

local CLASS = cw.class:New('#Class_Scanner')
  CLASS.color = Color(50, 100, 150, 255)
  CLASS.factions = { FACTION_MPF }
  CLASS.description = '#Class_Scanner_Desc'
  CLASS.defaultPhysDesc = 'Making beeping sounds'
CLASS_MPS = CLASS:Register()
