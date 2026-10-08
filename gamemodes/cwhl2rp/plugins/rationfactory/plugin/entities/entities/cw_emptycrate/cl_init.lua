--[[
  © 2012 Iron-Wall.org do not share, re-distribute or modify
  without permission of its author (ext@iam1337.ru).
--]]

include('shared.lua')

--- Draws how many of the ten rations the crate holds when the player looks at it.
function ENT:HUDPaintTargetID(x, y, alpha)
  y = cw.core:DrawInfo('#Factory_RationsFinished', x, y, cw.option:GetColor('target_id'), alpha)
  y = cw.core:DrawInfo('#Factory_FillState '..self:GetDTInt(1)..' / 10', x, y, Color(255, 255, 255), alpha)
end

--- Draws the crate's model.
function ENT:Draw()
  self:DrawModel()
end
