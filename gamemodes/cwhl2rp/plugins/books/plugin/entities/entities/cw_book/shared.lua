--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

DEFINE_BASECLASS("base_gmodentity")

ENT.Type = "anim"
ENT.Author = "kurozael"
ENT.PrintName = "Book"
ENT.Spawnable = false
ENT.AdminSpawnable = false

-- Called when the datatables are setup.
function ENT:SetupDataTables()
	self:DTVar("Int", 0, "index")
end
