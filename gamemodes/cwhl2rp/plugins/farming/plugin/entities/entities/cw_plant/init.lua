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
	self:SetModel("models/props/de_inferno/claypot03_damage_01.mdl")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)

	local phys = self:GetPhysicsObject()

	if (IsValid(physObj)) then
		physObj:EnableMotion(false)
		physObj:Sleep()
		--physObj:SetMass(500)
	end
end

function ENT:Think()
	if self:GetSpawnTime() and self:GetGrowTime() and self:GetGrowTime() > CurTime() then
		local GrowthPercent = (CurTime() - self:GetSpawnTime()) / (self:GetGrowTime() - self:GetSpawnTime())

		if GrowthPercent <= 1 then
			self:SetModelScale(math.max(1 * GrowthPercent, 0.25))
		end
	end
end

function ENT:OnTakeDamage(dmg)
	local player = dmg:GetAttacker()

	if(player:IsPlayer()) then self:Remove() end
end

function ENT:Use(activator)	
	if self:GetGrowTime() <= CurTime() and !self.isGathering then
		if (activator:GetNetVar("tied") == 0 and activator:Crouching()) then
			local gathertime = math.random(11, 25) - math.Round(cw.attributes:Fraction(activator, ATB_FARM, 10))

			self.isGathering = true

			cw.player:SetAction(activator, "farming", gathertime)
			cw.player:EntityConditionTimer(activator, self, self, gathertime, 192, function()
				return activator:Alive() and !activator:IsRagdolled() and activator:GetNetVar("tied") == 0 and activator:Crouching()
			end,
			function(success)
				if (success) then
					hook.Run("PlayerHarvest", activator, self:GetItem())

					self.isGathering = false
					activator:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav")
					activator:FakePickup(self)
					self:Remove()
				else
					self.isGathering = false
				end

				cw.player:SetAction(activator, "farming", false)
			end)
		else
			cw.player:Notify(activator, "Вы должны присесть, чтобы собрать урожай.")
		end
	else
		cw.player:Notify(activator, "Растение еще не созрело. Нужно подождать еще немного.")
	end
end

function ENT:SetSpawnTime(time)
	self:SetNetworkedFloat(0, time)
end

function ENT:SetGrowTime(time)
	self:SetNetworkedFloat(1, time)
end

function ENT:SetItem(uniqueID)
	self:SetNWString(0, uniqueID)
end
