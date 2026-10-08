--- Shared definition of the `cw_rationdispenser` entity (print name Ration Dispenser), with its ration time, flash time
-- and locked data table variables and `ENT:IsLocked`.

DEFINE_BASECLASS('base_gmodentity')

ENT.Type = 'anim'
ENT.Author = 'kurozael'
ENT.PrintName = 'Ration Dispenser'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.UsableInVehicle = true
ENT.PhysgunDisabled = true

--- Declares the ration ready time, flash time and locked state data table variables.
function ENT:SetupDataTables()
  self:DTVar('Float', 0, 'ration')
  self:DTVar('Float', 1, 'flash')
  self:DTVar('Bool', 0, 'locked')
end

--- Returns whether the dispenser is locked.
-- @return [Boolean Whether the dispenser is locked]
function ENT:IsLocked()
  return self:GetDTBool(0)
end
