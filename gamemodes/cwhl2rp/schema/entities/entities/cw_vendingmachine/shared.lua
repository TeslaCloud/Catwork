--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

DEFINE_BASECLASS("base_gmodentity")

ENT.Type = "anim"
ENT.Author = "kurozael"
ENT.PrintName = "Vending Machine"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.UsableInVehicle = true
ENT.PhysgunDisabled = true

-- A function to get the entity's stock.
function ENT:GetStock()
	return self:GetDTInt(0)
end

-- Called when the datatables are setup.
function ENT:SetupDataTables()
	self:DTVar("Int", 0, "stock")
	self:DTVar("Bool", 0, "action")
	self:DTVar("Float", 0, "flash")
end
