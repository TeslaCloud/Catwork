--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

--- Draws the plant's name and, for players with over 25 farming, its maturity percentage.
function ENT:HUDPaintTargetID(x, y, alpha)
  local colorTargetID = cw.option:GetColor('target_id')
  local colorWhite = cw.option:GetColor('white')
  local itemTable = item.FindByID(self:GetItem())

  y = cw.core:DrawInfo(itemTable.PlantName, x, y, colorTargetID, alpha)

  if cw.attributes:Fraction(ATB_FARM, 100) > 25 then
    local GrowthPercent =
      math.Clamp(
        math.Round((CurTime() - self:GetSpawnTime()) / (self:GetGrowTime() - self:GetSpawnTime()) * 100),
        0,
        100
      )
    y = cw.core:DrawInfo(L('#Farming_Maturity:'..GrowthPercent..';'), x, y, Color(255, 255, 255), alpha)
  end
end

include('shared.lua')

--- Draws the plant's model.
function ENT:Draw()
  self:DrawModel()
end

--- Does nothing on the client.
function ENT:Initialize()
end

--- Does nothing on the client.
function ENT:Think()
end
