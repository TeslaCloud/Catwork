--[[
  © 2012 Iron-Wall.org do not share, re-distribute or modify
  without permission of its author (ext@iam1337.ru).
--]]

DEFINE_BASECLASS('base_gmodentity')

ENT.Type = 'anim'
ENT.Author = 'ExT'
ENT.PrintName = 'Ration'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.PhysgunDisabled = true

--- Sets up the networked ration count and full flag.
function ENT:SetupDataTables()
  self:DTVar('Int', 0, 'index')
  self:DTVar('Int', 1, 'count')
  self:DTVar('Bool', 2, 'full')
end

--- Returns whether the crate has been flagged full.
-- @return [Boolean Whether the crate is full]
function ENT:IsFull()
  return self:GetDTBool(2)
end
