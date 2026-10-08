--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

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
