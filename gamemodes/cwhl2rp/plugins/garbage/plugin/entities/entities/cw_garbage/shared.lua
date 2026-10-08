--- Shared definition of the `cw_garbage` entity: its entity fields and its networked `index` variable.

DEFINE_BASECLASS('base_gmodentity')

ENT.Type = 'anim'
ENT.Author = 'Mr. Meow'
ENT.PrintName = 'Garbage Spawnpoint'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.PhysgunDisabled = true

--- Sets up the networked int 0 (`index`).
function ENT:SetupDataTables()
  self:DTVar('Int', 0, 'index')
end
