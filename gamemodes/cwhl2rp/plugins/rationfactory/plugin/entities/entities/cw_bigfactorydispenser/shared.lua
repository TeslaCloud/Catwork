--- Shared definition of the `cw_bigfactorydispenser` entity of the Ration Factory plugin, with the networked spawn type
-- and `GetSpawnType`.
--
-- Also sets the global `TYPE_WATERCAN` (0) and `TYPE_SUPPLIES` (1) constants, which for this entity stand for empty
-- ration packets and empty crates.
--
-- Originally written for the Iron Wall community.

DEFINE_BASECLASS('base_gmodentity')

TYPE_WATERCAN = 0
TYPE_SUPPLIES = 1

ENT.Type = 'anim'
ENT.Author = 'ExT'
ENT.PrintName = 'Factory Dispenser'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.PhysgunDisabled = true

--- Sets up the dispenser's networked index and spawn type.
function ENT:SetupDataTables()
  self:DTVar('Int', 0, 'index')
  self:DTVar('Int', 1, 'Type')
end

--- Returns what the dispenser spawns.
-- @return [Number `TYPE_WATERCAN` (0) or `TYPE_SUPPLIES` (1)]
function ENT:GetSpawnType()
  return self:GetDTInt(1)
end
