local PLUGIN = PLUGIN

--- Called after Catwork has loaded the map entities; spawns the saved emplacement guns.
--
-- Overridden by the identical hook in `sv_plugin.lua`, which is included after this file.
function PLUGIN:ClockworkInitPostEntity()
  PLUGIN:LoadEmplacementGuns()
end

--- Called after data is saved; saves the emplacement guns.
--
-- Overridden by the identical hook in `sv_plugin.lua`, which is included after this file.
function PLUGIN:PostSaveData()
  PLUGIN:SaveEmplacementGuns()
end
