--- Registers the Vortigaunt Slave class as `CLASS_VORT_SLAVE`, the default class of `FACTION_VORT`.

local CLASS = cw.class:New('#Class_Vortigaunt_Slave')
  CLASS.color = Color(150, 125, 100, 255)
  CLASS.factions = { FACTION_VORT }
  CLASS.isDefault = true
  CLASS.description = '#Class_Vortigaunt_Slave_Desc'
  CLASS.defaultPhysDesc = "Doesn't wear clothes."
CLASS_VORT_SLAVE = CLASS:Register()
