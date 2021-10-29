--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

include("shared.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

-- Called when the entity initializes.
function ENT:Initialize()
	self:SetModel("models/props_combine/combine_lock01.mdl")

	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetHealth(800)
	self:SetSolid(SOLID_VPHYSICS)

	self.glow = ents.Create("env_sprite")
	self.glow:SetKeyValue("model","glow04.vmt")
	self.glow:SetKeyValue("rendercolor","0 255 0")
	self.glow:SetKeyValue("rendermode","9")
	self.glow:SetKeyValue("scale","0.25")
	self.glow:SetPos(self:GetPos() + self:GetForward() * -3.5 + self:GetUp() * -9 + self:GetRight() * -6)
	self.glow:SetParent(self)
	self.glow:Spawn()
	self.glow:Activate()

	local physicsObject = self:GetPhysicsObject()

	if (IsValid(physicsObject)) then
		physicsObject:Wake()
		physicsObject:EnableMotion(true)
	end
end

-- Called when the entity's transmit state should be updated.
function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

-- Called each frame.
function ENT:Think()
	if (IsValid(self.entity)) then
		if (config.Get("combine_lock_overrides"):Get()) then
			for k, v in ipairs(self.entities) do
				if (IsValid(v)) then
					if (self:IsLocked()) then
						v:Fire("Lock", "", 0)
						v:Fire("Close", "", 0)
					else
						v:Fire("Unlock", "", 0)
					end
				end
			end
		end
	else
		self:Explode(); self:Remove()
	end

	local smokeChargeTime = self:GetDTFloat(0)
	local r, g, b, a = self:GetColor()
	local flashTime = self:GetDTFloat(1)
	local position = self:GetPos()
	local forward = self:GetForward() * -4
	local curTime = CurTime()
	local right = self:GetRight() * -6
	local up = self:GetUp() * -9

	if (smokeChargeTime > curTime) then
		local glowColor = Color(255, 0, 0, a)
		local timeLeft = smokeChargeTime - curTime

		if (!self.nextFlash or curTime >= self.nextFlash or (self.flashUntil and self.flashUntil > curTime)) then
			self.glow:SetKeyValue("renderalpha", tostring(a))
			self.glow:SetKeyValue("rendercolor", "255 0 0")

			if (!self.flashUntil or curTime >= self.flashUntil) then
				self.nextFlash = curTime + (timeLeft / 4)
				self.flashUntil = curTime + (FrameTime() * 4)

				self:EmitSound("hl1/fvox/beep.wav")
			end
		end
	else
		local glowColor = Color(0, 255, 0, a)

		if (self:IsLocked()) then
			glowColor = Color(255, 150, 0, a)

			if (self.overrideColor) then
				glowColor = ColorAlpha(self.overrideColor, a)
			end
		end

		if (flashTime and flashTime >= curTime) then
			glowColor = Color(255, 0, 0, a)
		end

		self.glow:SetKeyValue("renderalpha", tostring(a))
		self.glow:SetKeyValue("rendercolor", glowColor.r.." "..glowColor.g.." "..glowColor.b)
	end

	if (IsValid(self:GetPhysicsObject())) then
		self:GetPhysicsObject():SetVelocity(Vector())
		self:GetPhysicsObject():EnableMotion(false)
	end

	self:NextThink(curTime + 0.1)
end

function ENT:SetOverrideColor(color)
	self.overrideColor = color
end

-- A function to set the entity's door.
function ENT:SetDoor(entity)
	local position = entity:GetPos()
	local angles = entity:GetAngles()
	local model = entity:GetModel()
	local skin = entity:GetSkin()

	self.entity = entity
	self.entity:DeleteOnRemove(self)
	self.entities = {entity}

	for k, v in ipairs(ents.FindByClass(entity:GetClass())) do
		if (self.entity != v) then
			if (v:GetModel() == model and v:GetSkin() == skin) then
				local tempPosition = v:GetPos()
				local distance = tempPosition:Distance(position)

				if (distance >= 90 and distance <= 100) then
					if (v:GetAngles() != angles) then
						if (math.floor(tempPosition.z) == math.floor(position.z)) then
							self.entities[#self.entities + 1] = v
						end
					end
				end
			end
		end
	end

	for k, v in ipairs(self.entities) do
		v.combineLock = self
	end
end

function ENT:SetAccess(int)
	self.access = int
end

function ENT:SetCPRank(str)
	self.rank = str
end

-- A function to toggle whether the entity is locked.
function ENT:Toggle()
	if (self:IsLocked()) then
		self:Unlock()
	else
		self:Lock()
	end
end

-- A function to lock the entity.
function ENT:Lock()
	self:EmitRandomSound()

	for k, v in ipairs(self.entities) do
		if (IsValid(v)) then
			v:Fire("Lock", "", 0)
			v:Fire("Close", "", 0)
		end
	end

	self:SetDTBool(0, true)
end

-- A function to unlock the entity.
function ENT:Unlock()
	self:EmitRandomSound()

	for k, v in ipairs(self.entities) do
		if (IsValid(v)) then
			v:Fire("Unlock", "", 0)
		end
	end

	self:SetDTBool(0, false)
end

-- A function to set the entity's flash duration.
function ENT:SetFlashDuration(duration)
	self:EmitSound("buttons/combine_button_locked.wav")
	self:SetDTFloat(1, CurTime() + duration)
end

-- A function to activate the entity's smoke charge.
function ENT:ActivateSmokeCharge(force)
	local curTime = CurTime()

	if (self:GetDTFloat(0) < curTime) then
		self:SetDTFloat(0, curTime + 12)

		timer.Create("smoke_charge_"..self:EntIndex(), 12, 1, function()
			if (IsValid(self)) then

				for k, v in ipairs(self.entities) do
					if (IsValid(v) and string.lower(v:GetClass()) == "prop_door_rotating") then
						Schema:BustDownDoor(nil, v, force)

						local effectData = EffectData()

						effectData:SetOrigin(self:GetPos())
						effectData:SetScale(0.75)

						util.Effect("cw_effect_smoke", effectData, true, true)
					end
				end
			end
		end)
	end
end

-- A function to emit a random sound from the entity.
function ENT:EmitRandomSound()
	local randomSounds = {
		"buttons/combine_button1.wav",
		"buttons/combine_button2.wav",
		"buttons/combine_button3.wav",
		"buttons/combine_button5.wav",
		"buttons/combine_button7.wav"
	}

	local randomSound = randomSounds[math.random(1, #randomSounds)]

	if (self.entities) then

		for k, v in ipairs(self.entities) do
			if (IsValid(v)) then
				v:EmitSound(randomSound)
			end
		end
	end

	self:EmitSound(randomSound)
end

-- A function to explode the entity.
function ENT:Explode()
	local effectData = EffectData()

	effectData:SetStart(self:GetPos())
	effectData:SetOrigin(self:GetPos())
	effectData:SetScale(1)

	util.Effect("Explosion", effectData, true, true)

	self:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav")
end

-- Called when the entity is removed.
function ENT:OnRemove()
	self:Explode(); self:Unlock()

	if (self.entities) then

		for k, v in ipairs(self.entities) do
			if (IsValid(v)) then
				v:Fire("Unlock", "", 0)
			end
		end
	end
end

-- A function to toggle the entity with checks.
function ENT:ToggleWithChecks(activator)
	local curTime = CurTime()

	if (!self.nextUse or curTime >= self.nextUse) then
		if (curTime > self:GetDTFloat(1)) then
			if (curTime > self:GetDTFloat(0)) then
				self.nextUse = curTime + 3

				if (!Schema:PlayerHasCombineLockAccess(activator,self.access,self.rank) and activator:GetFaction() != FACTION_ADMIN) then
					self:SetFlashDuration(3)
				else
					self:Toggle()
				end
			end
		end
	end
end

-- Called when the entity is used.
function ENT:Use(activator, caller)
	if (activator:IsPlayer() and activator:GetEyeTraceNoCursor().Entity == self) then
		self:ToggleWithChecks(activator)
	end
end

-- Called when the entity takes damage.
function ENT:OnTakeDamage(damageInfo)
	self:SetHealth(math.max(self:Health() - damageInfo:GetDamage(), 0))

	if (self:Health() <= 0) then
		self:ActivateSmokeCharge(damageInfo:GetDamageForce() * 8)
	end
end

-- Called when a player attempts to use a tool.
function ENT:CanTool(player, trace, tool)
	return false
end

function ENT:GetAccess()
	return self.access
end

function ENT:GetCPRank()
	return self.rank
end