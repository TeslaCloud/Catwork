--[[
  © 2012 Iron-Wall.org do not share, re-distribute or modify
  without permission of its author (ext@iam1337.ru).
--]]

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
