--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

util.Include("shared.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

-- Called when the entity initializes.
function ENT:Initialize()
	self:SetModel("models/weapons/w_bugbait.mdl")
	self:SetSolid(SOLID_NONE)
	self:PhysicsInit(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_VPHYSICS)

	self.cwComputePos = Vector(0, 0, 0)
	self._player = NULL

	local physicsObject = self:GetPhysicsObject()

	if (IsValid(physicsObject)) then
		physicsObject:SetMass(2048)
		physicsObject:Wake()
	end
end

-- Called when the entity is used.
function ENT:Use(activator, caller) end

local think_rate = 1 / 20

-- Called each frame.
function ENT:Think()
	if (IsValid(self._player) and IsValid(self.cwTargetEnt) and cwPickupObjects) then
		if (!cwPickupObjects:CalculatePosition(self._player)) then
			cwPickupObjects:ForceDropEntity(self._player)
		end
	else
		self:Remove()
	end

	self:NextThink(CurTime() + think_rate)

	return true
end

-- A function to set the entity's compute position.
function ENT:SetComputePosition(position)
	self.cwComputePos = position
end

-- A function to set the entity's player.
function ENT:SetPlayer(player)
	self._player = player
end

-- A function to set the entity's target.
function ENT:SetTarget(target)
	self.cwTargetEnt = target
end

-- Called when the physics should be simulated.
function ENT:PhysicsSimulate(physicsObject, deltaTime)
	if (IsValid(self.cwTargetEnt)) then
		local targetPhysicsObject = self.cwTargetEnt:GetPhysicsObject()

		if (IsValid(targetPhysicsObject)) then
			targetPhysicsObject:Wake()
		end
	end

	physicsObject:Wake()
	physicsObject:ComputeShadowControl({
		secondstoarrive = 0.01,
		teleportdistance = 128,
		maxangulardamp = 10000,
		maxspeeddamp = 10000,
		dampfactor = 0.8,
		deltatime = deltaTime,
		maxangular = 512,
		maxspeed = 256,
		angle = self:GetAngles(),
		pos = self.cwComputePos
	})
end
