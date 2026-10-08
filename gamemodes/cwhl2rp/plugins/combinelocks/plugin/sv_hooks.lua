--- Server-side hooks of the Combine Locks plugin that put the saved Combine locks back on their doors once the map
-- entities exist (`ClockworkInitPostEntity`) and save them in `PostSaveData`.

local PLUGIN = PLUGIN

--- Called after Catwork has loaded the map entities; restores the saved Combine locks.
function PLUGIN:ClockworkInitPostEntity()
  self:LoadCombineLocks()
end

--- Called after data is saved; saves the Combine locks.
function PLUGIN:PostSaveData()
  self:SaveCombineLocks()
end
