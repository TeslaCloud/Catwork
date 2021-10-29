--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

DEFINE_BASECLASS("base_gmodentity")

ENT.Type = "anim"
ENT.Author = "AleXXX_007"
ENT.PrintName = "Растение"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.PhysgunDisabled = false

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "PlantTime")
	self:NetworkVar("Float", 1, "GrowTime")
	self:NetworkVar("String", 0, "Item")
end

function ENT:GetSpawnTime()
	return self:GetNetworkedFloat(0)
end

function ENT:GetGrowTime()
	return self:GetNetworkedFloat(1)
end

function ENT:GetItem()
	return self:GetNWString(0)
end
