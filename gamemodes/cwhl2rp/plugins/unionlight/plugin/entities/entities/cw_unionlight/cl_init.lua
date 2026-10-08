--- Client side of the `cw_unionlight` entity: draws the model and keeps a pale blue dynamic light with an 800 unit
-- radius at its position.

include('shared.lua')

--- Does nothing on the client.
function ENT:Initialize()
end

--- Draws the light's model.
function ENT:Draw()
  self.Entity:DrawModel()
end

--- Keeps a pale blue dynamic light with an 800 unit radius at the light's position.
function ENT:Think()
  local dlight = DynamicLight(self:EntIndex())

  if dlight then
    local r, g, b, a = self:GetColor()
    dlight.Pos = self:GetPos()
    dlight.r = 125
    dlight.g = 200
    dlight.b = 255
    dlight.Brightness = 0
    dlight.Size = 800
    dlight.Decay = 5
    dlight.DieTime = CurTime() + 0.1
  end
end
