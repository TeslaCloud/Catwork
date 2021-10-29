--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

include("shared.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

-- Called when the entity initializes.
function ENT:Initialize()
	local garbageModels = {
		"models/props_junk/garbage128_composite001a.mdl",
		"models/props_junk/garbage128_composite001b.mdl",
		"models/props_junk/TrashCluster01a.mdl",
		"models/props_junk/garbage128_composite001d.mdl",
		"models/props_junk/garbage256_composite001b.mdl"
	}

	self:SetModel(table.Random(garbageModels))

	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetSolid(SOLID_VPHYSICS)

	self:SetCollisionGroup(COLLISION_GROUP_WORLD)

	local phys = self:GetPhysicsObject()
	phys:SetMass(120)

	self:SetSpawnType(1)
end

function ENT:SetSpawnType(entType)
	if (entType == TYPE_WATERCAN or entType == TYPE_SUPPLIES) then
		self:SetDTInt(1,entType)
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:PhysicsUpdate(physicsObject)
	if (!self:IsPlayerHolding() and !self:IsConstrained()) then
		physicsObject:SetVelocity(Vector(0, 0, 0))
		physicsObject:Sleep()
	end
end

function ENT:Use(activator, caller)

	if (activator:IsPlayer() and activator:GetEyeTraceNoCursor().Entity == self) then

	local weapon = activator:GetActiveWeapon()

		if ((activator:GetNetVar("tied") == 0 and activator:Crouching()) or (weapon:GetClass() == "cw_pushbroom")) then
			local time = hook.Run("GetGarbageTime", activator)

			cw.player:SetAction(activator, "cleanup", time)
			cw.player:EntityConditionTimer(activator, self, self, time, 192, function()
				return activator:Alive() and !activator:IsRagdolled() and activator:GetNetVar("tied") == 0 and (activator:Crouching() or weapon:GetClass() == "cw_pushbroom")
			end, function(success)
				if (success) then
					hook.Run("PlayerTakeGarbage", activator, self)

					activator:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav")
					activator:FakePickup(self)
					self:Remove()
				end

				cw.player:SetAction(activator, "cleanup", false)
			end)
		elseif activator:GetNetVar("tied") == 0 and (!activator:Crouching() or weapon:GetClass() != "cw_pushbroom") then
			cw.player:Notify(activator, "Вы должны присесть, чтобы начать сбор мусора.")
		end
	end
end

function ENT:CanTool(player, trace, tool)
	return false
end
