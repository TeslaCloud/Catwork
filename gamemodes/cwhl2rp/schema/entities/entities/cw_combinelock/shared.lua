--- Shared definition of the `cw_combinelock` entity (print name Combine Lock), a spawnable `anim` entity with its smoke
-- charge, flash and locked data table variables and the `ENT:IsLocked` getter.

DEFINE_BASECLASS('base_gmodentity')

ENT.Type = 'anim'
ENT.Author = 'kurozael'
ENT.PrintName = 'Combine Lock'
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.UsableInVehicle = true
ENT.PhysgunDisabled = true
ENT.IsCombineLock = true

--- Declares the smoke charge time, flash time and locked state data table variables.
function ENT:SetupDataTables()
  self:DTVar('Float', 0, 'smokeCharge')
  self:DTVar('Float', 1, 'flash')
  self:DTVar('Bool', 0, 'locked')
end

--- Returns whether the lock is locked.
-- @return [Boolean Whether the lock is locked]
function ENT:IsLocked()
  return self:GetDTBool(0)
end
