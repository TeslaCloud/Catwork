--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

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
