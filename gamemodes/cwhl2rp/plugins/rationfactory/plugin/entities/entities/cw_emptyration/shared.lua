--- Shared definition of the `cw_emptyration` entity of the Ration Factory plugin, with the networked water, supplements
-- and full flags and `IsFull`.
--
-- Originally written for the Iron Wall community.

DEFINE_BASECLASS('base_gmodentity')

ENT.Type = 'anim'
ENT.Author = 'ExT'
ENT.PrintName = 'Ration'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.PhysgunDisabled = true

--- Sets up the networked flags for the water, the supplements and the full state.
function ENT:SetupDataTables()
  self:DTVar('Int', 0, 'index')
  self:DTVar('Bool', 1, 'breens_water')
  self:DTVar('Bool', 2, 'citizen_supplements')
  self:DTVar('Bool', 3, 'full')
end

--- Returns whether the packet holds both water and supplements.
-- @return [Boolean Whether the packet is full]
function ENT:IsFull()
  return self:GetDTBool(3)
end
