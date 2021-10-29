--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

include("shared.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

-- Called when the entity initializes.
function ENT:Initialize()
	self:SetModel("models/props_combine/combine_smallmonitor001.mdl")

	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetHealth(1)
	self:SetSolid(SOLID_VPHYSICS)

	/*
	self.glow = ents.Create("env_sprite")
	self.glow:SetKeyValue("model","glow06.vmt")
	self.glow:SetKeyValue("rendermode","9")
	self.glow:SetKeyValue("renderalpha","0")
	self.glow:SetKeyValue("scale","0.8")
	self.glow:SetPos(self:GetPos() + self:GetForward() * 12 + self:GetUp() * 10)
	self.glow:SetParent(self)
	self.glow:Spawn()
	self.glow:Activate()
	*/

	local physicsObject = self:GetPhysicsObject()

	if (IsValid(physicsObject)) then
		physicsObject:Wake()
		physicsObject:EnableMotion(true)
	end

	self:SetStatus(0)
end

-- Called when the entity's transmit state should be updated.
function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:SetStatus(int)
	//if int == 0 then
	//	self.glow:SetKeyValue("rendercolor","96 190 255")
	//elseif int == 1 then
	//	self.glow:SetKeyValue("rendercolor","0 0 0")
	//elseif int == 2 then
	//	self.glow:SetKeyValue("rendercolor","255 0 0")
	//end
	//self.glow:SetKeyValue("renderalpha","0")

	self:SetDTInt(5, int)
end
-- Called each frame.
function ENT:Think()
	self:NextThink(CurTime() + 0.1)
end

-- Called when a player attempts to use a tool.
function ENT:CanTool(player, trace, tool)
	return true
end

function ENT:OnTakeDamage(damageInfo)
	if self:GetDTInt(5) == 1 then return end

	self:SetHealth(math.max(self:Health() - damageInfo:GetDamage(), 0))

	if self:Health() <= 0 then
		self:SetStatus(1)

		sound.Play("ambient/energy/zap"..math.random(1,3)..".wav", self:GetPos(), 70, 100, 1)
		sound.Play("physics/glass/glass_impact_bullet"..math.random(1,4)..".wav", self:GetPos(), 70, 100, 1)

		local effect = EffectData()
		effect:SetOrigin(self:GetPos() + self:GetForward() * 16 + self:GetUp() * 10)
		util.Effect("GlassImpact",effect)

		local effect = EffectData()
		effect:SetOrigin(self:GetPos() + self:GetForward() * 13 + self:GetUp() * 10)
		effect:SetNormal(self:GetForward())
		effect:SetRadius(10)
		effect:SetMagnitude(0)
		effect:SetScale(1)
		util.Effect("cball_bounce",effect)
	end
end

function ENT:OnRemove()
	//self.glow:Remove()
end
