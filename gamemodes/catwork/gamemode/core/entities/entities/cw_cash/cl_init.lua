--- Client side of the `cw_cash` entity: draws the cash model, unless the `CashEntityDraw` hook returns `false`, and the
-- cash name and formatted amount when it is looked at.

include('shared.lua')

--- Draws the cash name and the formatted amount when the cash is looked at.
function ENT:HUDPaintTargetID(x, y, alpha)
  local colorTargetID = cw.option:GetColor('target_id')
  local colorWhite = cw.option:GetColor('white')
  local amount = self:GetDTInt(0)

  y = cw.core:DrawInfo(cw.option:GetKey('name_cash'), x, y, colorTargetID, alpha)
  y = cw.core:DrawInfo(cw.core:FormatCash(amount), x, y, colorWhite, alpha)
end

--- Draws the cash model unless the `CashEntityDraw` hook returns `false`.
function ENT:Draw()
  if hook.Run('CashEntityDraw', self) != false then
    self:DrawModel()
  end
end
