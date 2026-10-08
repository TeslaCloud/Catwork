--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

DEFINE_BASECLASS('base_gmodentity')

ENT.Type = 'anim'
ENT.Author = 'kurozael'
ENT.PrintName = 'Item'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.UsableInVehicle = true

--- Sets up the networked `Index` integer holding the item's instance index.
function ENT:SetupDataTables()
  self:DTVar('Int', 0, 'Index')
end

--- Returns the item instance fetched for this entity through `cw.entity:FetchItemTable`.
--
-- On the server this is overridden by the version in `init.lua`.
-- @return [Item The item instance, or `nil` if it has not been fetched yet]
function ENT:GetItemTable()
  return cw.entity:FetchItemTable(self)
end
