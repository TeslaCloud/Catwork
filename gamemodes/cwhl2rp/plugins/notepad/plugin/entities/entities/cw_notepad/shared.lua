--- Shared definition of the `cw_notepad` entity of the Notepad plugin, with the networked bool that is true once the
-- notepad has text.

DEFINE_BASECLASS('base_gmodentity')

ENT.Type = 'anim'
ENT.Author = 'RJ'
ENT.PrintName = '#Notepad_Title'
ENT.Spawnable = false
ENT.AdminSpawnable = false

--- Sets up the networked bool 0 (`note`), which is true once the notepad has text.
function ENT:SetupDataTables()
  self:DTVar('Bool', 0, 'note')
end
