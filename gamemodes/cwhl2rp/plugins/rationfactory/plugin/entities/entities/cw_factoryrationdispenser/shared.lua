--[[
	© 2012 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (ext@iam1337.ru).
--]]

DEFINE_BASECLASS("base_gmodentity")

ENT.Type = "anim"
ENT.Author = "ExT and kurozael"
ENT.PrintName = "Ration Dispenser"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.UsableInVehicle = true
ENT.PhysgunDisabled = true

function ENT:SetupDataTables()
	self:DTVar("Float", 0, "ration")
	self:DTVar("Float", 1, "flash")
	self:DTVar("Bool", 0, "locked")
	self:DTVar("Int", 0, "rations")
end

function ENT:IsLocked()
	return self:GetDTBool(0)
end

function ENT:GetRationCount()
	return self:GetDTInt(0)
end