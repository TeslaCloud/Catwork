--- Registers the Loyalist class as `CLASS_LOYAL`, the default class of `FACTION_LOYAL`.

local CLASS = cw.class:New('#Class_Loyalist')
  CLASS.color = Color(50, 150, 150, 255)
  CLASS.factions = { FACTION_LOYAL }
  CLASS.isDefault = true
  CLASS.description = '#Class_Loyalist_Desc'
  CLASS.defaultPhysDesc = 'Wearing clothes.'
CLASS_LOYAL = CLASS:Register()
