local PLUGIN = PLUGIN

--- Called after Catwork has loaded the map entities; restores the saved Combine devices.
function PLUGIN:ClockworkInitPostEntity()
  self:LoadCombineDevices()
end

--- Called after data is saved; saves the Combine devices.
function PLUGIN:PostSaveData()
  self:SaveCombineDevices()
end
