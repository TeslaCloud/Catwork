--- Shared definition of the `cw_book` entity, a non-spawnable `anim` entity with a networked `index` int that holds the
-- index of its book item.

DEFINE_BASECLASS('base_gmodentity')

ENT.Type = 'anim'
ENT.Author = 'kurozael'
ENT.PrintName = 'Book'
ENT.Spawnable = false
ENT.AdminSpawnable = false

--- Sets up the networked int 0 (`index`), the index of the book's item.
function ENT:SetupDataTables()
  self:DTVar('Int', 0, 'index')
end
