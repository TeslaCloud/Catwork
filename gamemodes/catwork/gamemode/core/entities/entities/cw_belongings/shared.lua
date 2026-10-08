--- Shared definition of the `cw_belongings` entity: a non-spawnable `anim` entity named Belongings that can be used
-- from inside a vehicle.

DEFINE_BASECLASS('base_gmodentity')

ENT.Type = 'anim'
ENT.Author = 'kurozael'
ENT.PrintName = 'Belongings'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.UsableInVehicle = true
