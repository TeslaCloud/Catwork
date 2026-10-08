--[[
  © 2012 Iron-Wall.org do not share, re-distribute or modify
  without permission of its author (ext@iam1337.ru).
--]]

include('shared.lua')

--- Draws the dispenser's model.
function ENT:Draw()
  self:DrawModel()
end

--- Does nothing on the client.
function ENT:Initialize()
end

--- Does nothing on the client.
function ENT:Think()
end
