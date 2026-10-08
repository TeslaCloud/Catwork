--- Client side of the `cw_radio` entity: draws the radio with a green status light, red while it is off, and shows its
-- frequency as the target ID.

include('shared.lua')

local glowMaterial = Material('sprites/glow04_noz')

--- Draws the radio name and its frequency (or a no frequency note) as the target ID.
function ENT:HUDPaintTargetID(x, y, alpha)
  local colorTargetID = cw.option:GetColor('target_id')
  local colorWhite = cw.option:GetColor('white')
  local frequency = self:GetFrequency()

  y = cw.core:DrawInfo('#Radio_TargetID_Name', x, y, colorTargetID, alpha)

  if frequency == '' then
    y = cw.core:DrawInfo('#Radio_TargetID_NoFrequency', x, y, colorWhite, alpha)
  else
    y = cw.core:DrawInfo(frequency, x, y, colorWhite, alpha)
  end
end

--- Draws the radio with a green status light, or a red one while it is off.
function ENT:Draw()
  self:DrawModel()

  local a = self:GetColor().a
  local glowColor = Color(0, 255, 0, a)
  local position = self:GetPos()
  local forward = self:GetForward() * 9
  local right = self:GetRight() * 5
  local up = self:GetUp() * 8

  if self:IsOff() then
    glowColor = Color(255, 0, 0, a)
  end

  cam.Start3D(EyePos(), EyeAngles())
    render.SetMaterial(glowMaterial)
    render.DrawSprite(position + forward + right + up, 16, 16, glowColor)
  cam.End3D()
end
