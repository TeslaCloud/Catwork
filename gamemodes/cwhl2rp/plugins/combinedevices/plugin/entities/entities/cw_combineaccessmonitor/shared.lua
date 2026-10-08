--- Shared definition of the `cw_combineaccessmonitor` entity of the Combine Devices plugin, an admin-only spawnable
-- entity named `Combine Monitor s2120`.
--
-- Sets up the networked strings for the three text lines and the access level. The status is declared here as int 4
-- but is read and written as int 5 by the rest of the entity.

DEFINE_BASECLASS('base_gmodentity')

ENT.Type = 'anim'
ENT.Author = 'SchwarzKruppzo'
ENT.PrintName = 'Combine Monitor s2120'
ENT.Category = 'HL2RP'
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.UsableInVehicle = false
ENT.PhysgunDisabled = false

--- Sets up the networked strings 0 to 2 (the three text lines), 3 (the access level) and int 4 (`status`).
--
-- The status is read and written as int 5 everywhere else: 0 is normal, 1 destroyed and
-- 2 error.
function ENT:SetupDataTables()
  self:DTVar('String', 0, 'text1')
  self:DTVar('String', 1, 'text2')
  self:DTVar('String', 2, 'text3')
  self:DTVar('String', 3, 'level')
  self:DTVar('Int', 4, 'status') // 0 - normal; 1 - destroyed; 2 - error
end
