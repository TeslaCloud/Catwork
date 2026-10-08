--- Client side of the `cw_bigfactorydispenser` entity of the Ration Factory plugin, which only draws the model.
--
-- Originally written for the Iron Wall community.

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
