--- Server-side hooks of the Emplacement Gun plugin that spawn the saved emplacement guns once the map entities are
-- loaded and save them whenever data is saved.

local PLUGIN = PLUGIN

--- Called after Catwork has loaded the map entities; spawns the saved emplacement guns.
function PLUGIN:ClockworkInitPostEntity()
  PLUGIN:LoadEmplacementGuns()
end

--- Called after data is saved; saves the emplacement guns.
function PLUGIN:PostSaveData()
  PLUGIN:SaveEmplacementGuns()
end
