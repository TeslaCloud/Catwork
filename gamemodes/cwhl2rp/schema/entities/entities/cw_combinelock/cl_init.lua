--[[
  © 2013 CloudSixteen.com do not share, re-distribute or modify
  without permission of its author (kurozael@gmail.com).
--]]

include('shared.lua')

local glowMaterial = Material('sprites/glow04_noz')

--- Draws the lock model.
function ENT:Draw()
  self:DrawModel()
end
