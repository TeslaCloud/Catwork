--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

include('shared.lua')

--- Draws the breach name and usage hint as the target ID.
function ENT:HUDPaintTargetID(x, y, alpha)
  local colorTargetID = cw.option:GetColor('target_id')
  local colorWhite = cw.option:GetColor('white')

  y = cw.core:DrawInfo('#ITEM_Breach', x, y, colorTargetID, alpha)
  y = cw.core:DrawInfo('#Breach_TargetID_Hint', x, y, colorWhite, alpha)
end

--- Draws the breach model.
function ENT:Draw() self:DrawModel() end
