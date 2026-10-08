--- Client side of the `cw_combinelock` entity: draws the lock model.

include('shared.lua')

--- Draws the lock model.
function ENT:Draw()
  self:DrawModel()
end
