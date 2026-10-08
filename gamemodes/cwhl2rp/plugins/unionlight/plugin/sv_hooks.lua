--- Server-side hooks of the Union Light plugin that restore the saved union lights once the map entities are loaded and
-- save them whenever data is saved.

local PLUGIN = PLUGIN

--- Called after Catwork has loaded the map entities; restores the saved union lights.
function PLUGIN:ClockworkInitPostEntity()
  self:LoadUnionLights()
end

--- Called after data is saved; saves the union lights.
function PLUGIN:PostSaveData()
  self:SaveUnionLights()
end
