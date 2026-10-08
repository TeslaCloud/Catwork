--- Registers the Free Vortigaunt class as `CLASS_VORT`, the non-default class of `FACTION_VORT`.

local CLASS = cw.class:New('#Class_Vortigaunt')
  CLASS.color = Color(150, 125, 100, 255)
  CLASS.factions = { FACTION_VORT }
  CLASS.description = '#Class_Vortigaunt_Desc'
  CLASS.defaultPhysDesc = "Doesn't wear clothes."
CLASS_VORT = CLASS:Register()
