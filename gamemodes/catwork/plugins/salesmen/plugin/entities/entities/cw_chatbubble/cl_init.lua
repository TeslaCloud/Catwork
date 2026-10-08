--- Client-side code of the `cw_chatbubble` entity, which draws the speech bubble at reduced scale and bobs and spins it
-- above its salesman.

util.Include('shared.lua')

--- Draws the chat bubble at 60% of its model's size.
function ENT:Draw()
  self:SetModelScale(0.6, 0)
  self:DrawModel()
end

--- Bobs the chat bubble above its salesman and slowly spins it.
function ENT:Think()
  local salesman = self:GetNWEntity('salesman')

  if IsValid(salesman) and salesman:IsValid() then
    self:SetPos(salesman:GetPos() + Vector(0, 0, 90) + Vector(0, 0, math.sin(UnPredictedCurTime()) * 2.5))

    if self.cwNextChangeAngle <= UnPredictedCurTime() then
      self:SetAngles(self:GetAngles() + Angle(0, 0.25, 0))
      self.cwNextChangeAngle = self.cwNextChangeAngle + (1 / 60)
    end
  end
end

--- Starts the chat bubble's rotation timer.
function ENT:Initialize()
  self.cwNextChangeAngle = UnPredictedCurTime()
end
