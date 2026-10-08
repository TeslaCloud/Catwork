--- Shared definition of the `cw_wood` entity, a copy of `cw_garbage` that keeps its `Garbage Spawnpoint` name, the
-- `TYPE_WATERCAN` and `TYPE_SUPPLIES` globals and the networked `index` variable.

DEFINE_BASECLASS('base_gmodentity')

TYPE_WATERCAN = 0
TYPE_SUPPLIES = 1

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
