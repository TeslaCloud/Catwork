local PLUGIN = PLUGIN

--- Called after Catwork has loaded the map entities; restores the saved union lights.
function PLUGIN:ClockworkInitPostEntity()
  self:LoadUnionLights()
end

--- Called after data is saved; saves the union lights.
function PLUGIN:PostSaveData()
  self:SaveUnionLights()
end
