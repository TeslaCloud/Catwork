--- Registers the Metropolice Unit class as `CLASS_MPU`, the default class of `FACTION_MPF`, with wages of 10.

local CLASS = cw.class:New('#Class_MPF')
  CLASS.color = Color(50, 100, 150, 255)
  CLASS.wages = 10
  CLASS.factions = { FACTION_MPF }
  CLASS.isDefault = true
  CLASS.wagesName = '#Class_MPF_Wages'
  CLASS.description = '#Class_MPF_Desc'
  CLASS.defaultPhysDesc = 'Wearing a metrocop jacket with a radio'
CLASS_MPU = CLASS:Register()
