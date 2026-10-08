--- Shared definition of the `cw_forcefield` entity of the Force Fields plugin, an admin-only spawnable `anim` entity
-- named `Force Field` that cannot be physgunned.

ENT.Type 			= 'anim'
ENT.Base 			= 'base_anim'
ENT.PrintName = 'Force Field'
ENT.Category = 'HL2RP'
ENT.Spawnable		= true
ENT.AdminOnly		= true
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.PhysgunDisabled = true
