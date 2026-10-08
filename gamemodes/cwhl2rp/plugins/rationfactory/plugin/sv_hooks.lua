--- Server-side hooks of the Ration Factory plugin that spawn the saved factory dispensers once the map entities exist
-- and save them whenever data is saved.
--
-- Originally written for the Iron Wall community.

local PLUGIN = PLUGIN

--- Called after all map entities have been initialized; spawns the saved factory dispensers.
function PLUGIN:ClockworkInitPostEntity()
  self:LoadFactoryDispensers()
  self:LoadFactoryRationDispensers()
  self:LoadBigFactoryDispensers()
end

--- Called after Catwork saves its data; saves the factory dispensers.
function PLUGIN:PostSaveData()
  self:SaveFactoryDispensers()
  self:SaveFactoryRationDispensers()
  self:SaveBigFactoryDispensers()
end
