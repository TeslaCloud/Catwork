--- Shared definition of the `cw_cash` entity: a non-spawnable `anim` entity named Cash with a networked `Amount`
-- integer.

DEFINE_BASECLASS('base_gmodentity')

ENT.Type = 'anim'
ENT.Author = 'kurozael'
ENT.PrintName = 'Cash'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.UsableInVehicle = true

--- Sets up the networked `Amount` integer holding the cash amount.
function ENT:SetupDataTables()
  self:DTVar('Int', 0, 'Amount')
end
