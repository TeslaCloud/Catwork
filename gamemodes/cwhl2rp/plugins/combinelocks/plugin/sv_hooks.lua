local PLUGIN = PLUGIN

--- Called after Catwork has loaded the map entities; restores the saved Combine locks.
function PLUGIN:ClockworkInitPostEntity()
  self:LoadCombineLocks()
end

--- Called after data is saved; saves the Combine locks.
function PLUGIN:PostSaveData()
  self:SaveCombineLocks()
end
