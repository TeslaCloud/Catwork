--- Shared definition of the `cw_vendingmachine` entity (print name Vending Machine), with its stock, flash action and
-- flash time data table variables and `ENT:GetStock`.

DEFINE_BASECLASS('base_gmodentity')

ENT.Type = 'anim'
ENT.Author = 'kurozael'
ENT.PrintName = 'Vending Machine'
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.UsableInVehicle = true
ENT.PhysgunDisabled = true

--- Returns how many cans the machine has left.
-- @return [Number The current stock]
function ENT:GetStock()
  return self:GetDTInt(0)
end

--- Declares the stock, flash action and flash time data table variables.
function ENT:SetupDataTables()
  self:DTVar('Int', 0, 'stock')
  self:DTVar('Bool', 0, 'action')
  self:DTVar('Float', 0, 'flash')
end
