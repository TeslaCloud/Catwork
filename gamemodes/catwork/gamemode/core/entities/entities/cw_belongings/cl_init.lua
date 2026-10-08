--- Client side of the `cw_belongings` entity: draws the suitcase model and, when it is looked at, its title and the
-- hint for opening it.

include('shared.lua')

--- Draws the belongings title and the hint for opening them when the entity is looked at.
function ENT:HUDPaintTargetID(x, y, alpha)
  local colorTargetID = cw.option:GetColor('target_id')
  local colorWhite = cw.option:GetColor('white')

  y = cw.core:DrawInfo('#Storage_Belongings', x, y, colorTargetID, alpha)
  y = cw.core:DrawInfo('#Belongings_TargetHint', x, y, colorWhite, alpha)
end

--- Draws the belongings model.
function ENT:Draw()
  self:DrawModel()
end
