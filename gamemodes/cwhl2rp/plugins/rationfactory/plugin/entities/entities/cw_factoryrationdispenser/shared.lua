--- Shared definition of the `cw_factoryrationdispenser` entity of the Ration Factory plugin, with the networked ration
-- timer, flash timer, lock state and ration count, and `IsLocked` and `GetRationCount`.
--
-- Originally written for the Iron Wall community.

DEFINE_BASECLASS('base_gmodentity')

ENT.Type = 'anim'
ENT.Author = 'ExT and kurozael'
ENT.PrintName = 'Ration Dispenser'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.UsableInVehicle = true
ENT.PhysgunDisabled = true

--- Sets up the networked ration timer, flash timer, lock state and ration count.
function ENT:SetupDataTables()
  self:DTVar('Float', 0, 'ration')
  self:DTVar('Float', 1, 'flash')
  self:DTVar('Bool', 0, 'locked')
  self:DTVar('Int', 0, 'rations')
end

--- Returns whether the dispenser is locked.
-- @return [Boolean Whether the dispenser is locked]
function ENT:IsLocked()
  return self:GetDTBool(0)
end

--- Returns how many rations the dispenser has left.
-- @return [Number The ration count]
function ENT:GetRationCount()
  return self:GetDTInt(0)
end
