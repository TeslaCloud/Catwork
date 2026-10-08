--- Shared definition of the `cw_shipment` entity: a non-spawnable `anim` entity named Shipment with a networked item
-- `Index` and an `ENT:GetItemTable` accessor.

DEFINE_BASECLASS('base_gmodentity')

ENT.Type = 'anim'
ENT.Author = 'kurozael'
ENT.PrintName = 'Shipment'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.UsableInVehicle = true

--- Sets up the networked `Index` integer holding the shipped item's index.
function ENT:SetupDataTables()
  self:DTVar('Int', 0, 'Index')
end

--- Returns the item the shipment contains.
--
-- On the client it looks the item up by the networked index.
-- @return [Item The shipped item, or `nil` if it is not set]
function ENT:GetItemTable()
  if CLIENT then
    local index = self:GetDTInt(0)

    if index != 0 then
      return item.FindByID(index)
    end
  end

  return self.cwItemTable
end
