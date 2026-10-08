--- Shared definition of the `cw_combineaccessmonitor` entity of the Combine Devices plugin, an admin-only spawnable
-- entity named `Combine Monitor s2120`.
--
-- Sets up the networked strings for the three text lines and the access level, and the status int.

DEFINE_BASECLASS('base_gmodentity')

ENT.Type = 'anim'
ENT.Author = 'SchwarzKruppzo'
ENT.PrintName = 'Combine Monitor s2120'
ENT.Category = 'HL2RP'
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.UsableInVehicle = false
ENT.PhysgunDisabled = false

--- Sets up the networked strings 0 to 2 (the three text lines), 3 (the access level) and int 5 (`status`).
--
-- The status is 0 for normal, 1 for destroyed and 2 for error.
function ENT:SetupDataTables()
  self:DTVar('String', 0, 'text1')
  self:DTVar('String', 1, 'text2')
  self:DTVar('String', 2, 'text3')
  self:DTVar('String', 3, 'level')
  self:DTVar('Int', 5, 'status')
end
