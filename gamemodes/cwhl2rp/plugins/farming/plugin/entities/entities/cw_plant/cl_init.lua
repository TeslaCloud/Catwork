--- Client side of the `cw_plant` entity, which draws the plant and its target ID.
--
-- The target ID shows the plant's name from its seed item and, for players with enough of the Farming attribute, its
-- maturity as a percentage.

--- Draws the plant's name and, for players with over 25 farming, its maturity percentage.
function ENT:HUDPaintTargetID(x, y, alpha)
  local colorTargetID = cw.option:GetColor('target_id')
  local colorWhite = cw.option:GetColor('white')
  local itemTable = item.FindByID(self:GetItem())

  -- The seed item is unknown until the plant's networked variables have arrived.
  if !itemTable or !itemTable.PlantName then return end

  y = cw.core:DrawInfo(itemTable.PlantName, x, y, colorTargetID, alpha)

  if (cw.attributes:Fraction(ATB_FARM, 100) or 0) > 25 then
    local spawnTime = self:GetSpawnTime()
    local growTime = self:GetGrowTime()
    local growthPercent = 100

    if growTime > spawnTime then
      growthPercent = math.Clamp(math.Round((CurTime() - spawnTime) / (growTime - spawnTime) * 100), 0, 100)
    end

    y = cw.core:DrawInfo(L('#Farming_Maturity:'..growthPercent..';'), x, y, colorWhite, alpha)
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
