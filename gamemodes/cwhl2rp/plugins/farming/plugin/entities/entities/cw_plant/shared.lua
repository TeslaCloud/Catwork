--- Shared definition of the `cw_plant` entity: its entity fields and the getters for the time it was planted, the time
-- it ripens and the unique ID of the seed item it grew from.

DEFINE_BASECLASS('base_gmodentity')

ENT.Type = 'anim'
ENT.Author = 'AleXXX_007'
ENT.PrintName = '#Farming_Plant_Default'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.PhysgunDisabled = false

--- Sets up the networked plant time, grow time and seed item ID.
function ENT:SetupDataTables()
  self:NetworkVar('Float', 0, 'PlantTime')
  self:NetworkVar('Float', 1, 'GrowTime')
  self:NetworkVar('String', 0, 'Item')
end

--- Returns when the plant was planted.
-- @return [Number The `CurTime` the seeds were planted at]
function ENT:GetSpawnTime()
  return self:GetNWFloat(0)
end

--- Returns when the plant is ripe.
-- @return [Number The `CurTime` the plant ripens at]
function ENT:GetGrowTime()
  return self:GetNWFloat(1)
end

--- Returns the unique ID of the seed item the plant grew from.
-- @return [String The seed item's unique ID]
function ENT:GetItem()
  return self:GetNWString(0)
end
