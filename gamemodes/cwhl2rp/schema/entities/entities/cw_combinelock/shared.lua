--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

DEFINE_BASECLASS("base_gmodentity")

ENT.Type = "anim"
ENT.Author = "kurozael"
ENT.PrintName = "Combine Lock"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.UsableInVehicle = true
ENT.PhysgunDisabled = true
ENT.IsCombineLock = true

-- Called when the datatables are setup.
function ENT:SetupDataTables()
	self:DTVar("Float", 0, "smokeCharge")
	self:DTVar("Float", 1, "flash")
	self:DTVar("Bool", 0, "locked")
end

-- A function to get whether the entity is locked.
function ENT:IsLocked()
	return self:GetDTBool(0)
end