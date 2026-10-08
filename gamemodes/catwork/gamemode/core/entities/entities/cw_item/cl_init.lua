--- Client side of the `cw_item` entity: fetches the item data from the server, draws the model and shows the item's
-- name, weight and space when it is looked at.
--
-- The `PaintItemTargetID`, `ItemEntityDraw` and `ItemEntityThink` hooks and the item's `OnHUDPaintTargetID`,
-- `OnDrawModel` and `OnEntityThink` callbacks can change this.

include('shared.lua')

--- Draws the item name, weight and space when the item entity is looked at.
--
-- `PaintItemTargetID` must return `true` for anything to be drawn. The item's `OnHUDPaintTargetID` can draw
-- extra lines and returns the new `y`, or `false` to stop drawing.
function ENT:HUDPaintTargetID(x, y, alpha)
  if cw.entity:HasFetchedItemData(self) then
    local itemTable = cw.entity:FetchItemTable(self)

    if hook.Run('PaintItemTargetID', x, y, alpha, itemTable) then
      local colorTargetID = cw.option:GetColor('target_id')
      local colorWhite = cw.option:GetColor('white')
      local color = itemTable.color or colorTargetID

      y = cw.core:DrawInfo(cw.lang:TranslateText(itemTable.PrintName), x, y, color, alpha)

      if itemTable.OnHUDPaintTargetID then
        local newY = itemTable:OnHUDPaintTargetID(self, x, y, alpha)

        if newY == false then
          return
        end

        if isnumber(newY) then
          y = newY
        end
      end

      y = cw.core:DrawInfo((itemTable.weightText or itemTable.weight..'#Unit_Kilograms'), x, y, colorWhite, alpha)

      local spaceUsed = itemTable.space

      if cw.inventory:UseSpaceSystem() and spaceUsed > 0 then
        y = cw.core:DrawInfo((itemTable.spaceText or spaceUsed..'#Unit_Litres'), x, y, colorWhite, alpha)
      end
    end
  end
end

--- Requests the item data from the server until it arrives, then runs the item's `OnEntityThink` and the
-- `ItemEntityThink` hook.
function ENT:Think()
  if !cw.entity:HasFetchedItemData(self) then
    cw.entity:FetchItemData(self)
    return
  end

  local itemTable = cw.entity:FetchItemTable(self)

  if itemTable.OnEntityThink then
    local nextThink = itemTable:OnEntityThink(self)

    if isnumber(nextThink) then
      self:NextThink(CurTime() + nextThink)
    end
  end

  hook.Run('ItemEntityThink', itemTable, self)
end

--- Draws the item model unless the `ItemEntityDraw` hook or the item's `OnDrawModel` returns `false`.
function ENT:Draw()
  if !cw.entity:HasFetchedItemData(self) then
    return
  end

  local drawModel = true
  local itemTable = cw.entity:FetchItemTable(self)
  local shouldDrawItemEntity = hook.Run('ItemEntityDraw', itemTable, self)

  if shouldDrawItemEntity == false
  or (itemTable.OnDrawModel and itemTable:OnDrawModel(self) == false) then
    drawModel = false
  end

  if drawModel then
    self:DrawModel()
  end
end
