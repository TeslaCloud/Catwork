--[[
	Catwork � 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

DEFINE_BASECLASS("base_gmodentity")

TYPE_WATERCAN = 0
TYPE_SUPPLIES = 1

ENT.Type = "anim"
ENT.Author = "Mr. Meow"
ENT.PrintName = "Garbage Spawnpoint"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.PhysgunDisabled = true

function ENT:SetupDataTables()
	self:DTVar("Int", 0, "index")
end
