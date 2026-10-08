--- Client side of the `cw_book` entity, which draws the book's model and shows its item name and weight as the target
-- ID.

include('shared.lua')

--- Draws the book's name and weight when looked at.
function ENT:HUDPaintTargetID(x, y, alpha)
  local colorTargetID = cw.option:GetColor('target_id')
  local colorWhite = cw.option:GetColor('white')
  local index = self:GetDTInt(0)

  if index != 0 then
    local itemTable = item.FindByID(index)

    if itemTable then
      y = cw.core:DrawInfo(itemTable.PrintName, x, y, itemTable.color or colorTargetID, alpha)

      if itemTable.weightText then
        y = cw.core:DrawInfo(itemTable.weightText, x, y, colorWhite, alpha)
      else
        y = cw.core:DrawInfo(itemTable.weight..'kg', x, y, colorWhite, alpha)
      end
    end
  end
end

--- Draws the book's model.
function ENT:Draw()
  self:DrawModel()
end
