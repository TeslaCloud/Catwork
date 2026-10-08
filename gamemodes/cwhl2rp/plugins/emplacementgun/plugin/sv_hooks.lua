--- Server-side hooks of the Emplacement Gun plugin that spawn the saved emplacement guns once the map entities are
-- loaded and save them whenever data is saved.
--
-- Both hooks, `ClockworkInitPostEntity` and `PostSaveData`, are defined again in `sv_plugin.lua`, which is included
-- after this file and overrides them.

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
