--- Client side of the `cw_crafttable` entity of the Craft plugin, which draws the crafting station's model and shows
-- its name when the player looks at it.

include('shared.lua')

--- Draws the station's name when the player looks at it.
function ENT:HUDPaintTargetID(x, y, alpha)
  local colorTargetID = cw.option:GetColor('target_id')

  y = cw.core:DrawInfo(self.PrintName, x, y, colorTargetID, alpha)
end

--- Draws the station's model.
function ENT:Draw()
  self:DrawModel()
end
