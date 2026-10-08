--- Client side of the `cw_shipment` entity: draws the crate model, unless the `ShipmentEntityDraw` hook returns
-- `false`, and the shipment title and the name of the item inside when it is looked at.

include('shared.lua')

--- Draws the shipment title and the name of the item it contains when looked at.
function ENT:HUDPaintTargetID(x, y, alpha)
  local colorTargetID = cw.option:GetColor('target_id')
  local colorWhite = cw.option:GetColor('white')
  local itemTable = self:GetItemTable()

  if itemTable then
    y = cw.core:DrawInfo('#ShipmentWithRations', x, y, colorTargetID, alpha)
    y = cw.core:DrawInfo(itemTable.PrintName, x, y, colorWhite, alpha)
  end
end

--- Draws the shipment model unless the `ShipmentEntityDraw` hook returns `false`.
function ENT:Draw()
  if hook.Run('ShipmentEntityDraw', self) != false then
    self:DrawModel()
  end
end
