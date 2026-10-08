--- Client side of the `cw_garbage` entity, which only draws the garbage pile's model.

include('shared.lua')

--- Draws the pile's model.
function ENT:Draw()
  self:DrawModel()
end

--- Does nothing on the client.
function ENT:Initialize()
end

--- Does nothing on the client.
function ENT:Think()
end
