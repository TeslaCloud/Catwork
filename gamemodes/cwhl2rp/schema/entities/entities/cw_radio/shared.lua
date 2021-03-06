--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

DEFINE_BASECLASS("base_gmodentity")

ENT.Type = "anim"
ENT.Author = "kurozael"
ENT.PrintName = "Radio"
ENT.Spawnable = false
ENT.AdminSpawnable = false

-- Called when the data tables are setup.
function ENT:SetupDataTables()
	self:DTVar("Bool", 0, "off")
end

-- A function to get the frequency.
function ENT:GetFrequency()
	return self:GetNWString("frequency")
end

-- A function to get whether the entity is off.
function ENT:IsOff()
	return self:GetDTBool(0)
end
