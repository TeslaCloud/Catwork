--- Shared definition of the `cw_breach` entity (print name Breach), a non-spawnable `anim` entity that cannot be moved
-- with the physgun.

DEFINE_BASECLASS('base_gmodentity')

ENT.Type = 'anim'
ENT.Author = 'kurozael'
ENT.PrintName = 'Breach'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.UsableInVehicle = true
ENT.PhysgunDisabled = true
