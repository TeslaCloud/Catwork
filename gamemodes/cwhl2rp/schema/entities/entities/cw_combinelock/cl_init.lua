--- Client side of the `cw_combinelock` entity: draws the lock model.

include('shared.lua')

local glowMaterial = Material('sprites/glow04_noz')

--- Draws the lock model.
function ENT:Draw()
  self:DrawModel()
end
