--- Client side of the `cw_wood` entity, which only draws the node's model.

include('shared.lua')

--- Draws the node's model.
function ENT:Draw()
  self:DrawModel()
end

--- Does nothing on the client.
function ENT:Initialize()
end

--- Does nothing on the client.
function ENT:Think()
end
