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
	self:SetModel("models/props_junk/watermelon01.mdl")

	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetSolid(SOLID_VPHYSICS)

	self.dispenser = ents.Create("prop_dynamic")
	self.dispenser:DrawShadow(false)
	self.dispenser:SetAngles(self:GetAngles())
	self.dispenser:SetParent(self)
	self.dispenser:SetModel("models/props_combine/combine_dispenser.mdl")
	self.dispenser:SetPos(self:GetPos())
	self.dispenser:Spawn()

	self:DeleteOnRemove(self.dispenser)

	local minimum = Vector(-8, -8, -8)
	local maximum = Vector(8, 8, 64)

	self:SetCollisionBounds(minimum, maximum)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:PhysicsInitBox(minimum, maximum)
	self:DrawShadow(false)
end

-- Called when the entity's transmit state should be updated.
function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
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
	self:SetDTBool(0, true)
	self:EmitRandomSound()
end

-- A function to unlock the entity.
function ENT:Unlock()
	self:SetDTBool(0, false)
	self:EmitRandomSound()
end

-- A function to set the entity's flash duration.
function ENT:SetFlashDuration(duration)
	self:EmitSound("buttons/combine_button_locked.wav")
	self:SetDTFloat(1, CurTime() + duration)
end

-- A function to create a dummy ration.
function ENT:CreateDummyRation(customModel)
	local forward = self:GetForward() * 15
	local right = self:GetRight() * 0
	local up = self:GetUp() * -8

	local entity = ents.Create("prop_physics")

	entity:SetAngles(self:GetAngles())
	entity:SetModel(customModel or "models/weapons/w_packati.mdl")
	entity:SetPos(self:GetPos() + forward + right + up)
	entity:Spawn()

	return entity
end

-- A function to activate the entity's ration.
function ENT:ActivateRation(activator, duration, force)
	local curTime = CurTime()
	local entModel
	local rationType

	if (Schema:PlayerIsLoyalistTier(activator, "red")) then
		entModel = "models/weapons/w_packatp.mdl"
		rationType = "ration_highest"
		duration = 4
	elseif (Schema:PlayerIsLoyalistTier(activator, "orange") or Schema:PlayerIsCWU(activator)) then
		entModel = "models/weapons/w_packatp.mdl"
		rationType = "ration_high"
		duration = 8
	elseif (Schema:PlayerIsLoyalistTier(activator, "blue")) then
		entModel = "models/weapons/w_packatl.mdl"
		rationType = "ration_medium"
		duration = 12
	elseif (Schema:PlayerIsLoyalistTier(activator, "green")) then
		entModel = "models/weapons/w_packatc.mdl"
		rationType = "ration_standard"
		duration = 15
	elseif (Schema:PlayerIsLoyalistTier(activator, "white")) then
		entModel = "models/weapons/w_packatc.mdl"
		rationType = "ration_normal"
		duration = 18
	else
		entModel = "models/weapons/w_packati.mdl"
		rationType = "ration_minimal"
		duration = 26
	end

	if (!duration) then duration = 24; end

	if (force or !self.nextActivateRation or curTime >= self.nextActivateRation) then
		self.nextActivateRation = curTime + duration + 2
		self:SetDTFloat(0, curTime + duration)

		timer.Create("ration_"..self:EntIndex(), duration, 1, function()
			if (IsValid(self)) then
				local frameTime = FrameTime() * 0.5
				local dispenser = self.dispenser
				local entity = self:CreateDummyRation(entModel)

				if (IsValid(entity)) then
					dispenser:EmitSound("ambient/machines/combine_terminal_idle4.wav")

					entity:SetNotSolid(true)
					entity:SetParent(dispenser)

					timer.Simple(frameTime, function()
						if (IsValid(self) and IsValid(entity)) then
							entity:Fire("setparentattachment", "package_attachment", 0)

							timer.Simple(frameTime, function()
								if (IsValid(self) and IsValid(entity)) then
									dispenser:Fire("setanimation", "dispense_package", 0)

									timer.Simple(1.75, function()
										if (IsValid(self) and IsValid(entity)) then
											local position = entity:GetPos()
											local angles = entity:GetAngles()

											entity:CallOnRemove("CreateRation", function()
												if (IsValid(activator)) then
													local itemTable = item.CreateInstance(rationType or "ration_normal")

													if (itemTable) then
														local entity = cw.entity:CreateItem(activator, itemTable, position, angles)
														local physObj = entity:GetPhysicsObject()
														
														if (physObj) then
															physObj:EnableMotion(false)
														end
													end
												end
											end)

											entity:SetNoDraw(true)
											entity:Remove()
										end
									end)
								end
							end)
						end
					end)
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

	self:EmitSound(randomSounds[math.random(1, #randomSounds)])
end

-- Called when the entity's physics should be updated.
function ENT:PhysicsUpdate(physicsObject)
	if (!self:IsPlayerHolding() and !self:IsConstrained()) then
		physicsObject:SetVelocity(Vector(0, 0, 0))
		physicsObject:Sleep()
	end
end

-- Called when the entity is used.
function ENT:Use(activator, caller)
	if (activator:IsPlayer() and activator:GetEyeTraceNoCursor().Entity == self) then
		local curTime = CurTime()
		local unixTime = os.time()

		if (!self.nextUse or curTime >= self.nextUse) then
			if (!Schema:PlayerIsCombine(activator)) then
				if (!self:IsLocked() and unixTime >= activator:GetCharacterData("nextration", 0)) then
					if (!self.nextActivateRation or curTime >= self.nextActivateRation) then
						self:ActivateRation(activator)

						activator:SetCharacterData("nextration", unixTime + 3600)
					end
				else
					self:SetFlashDuration(3)
				end
			elseif (!self.nextActivateRation or curTime >= self.nextActivateRation) then
				self:Toggle()
			end

			self.nextUse = curTime + 3
		end
	end
end

-- Called when a player attempts to use a tool.
function ENT:CanTool(player, trace, tool)
	return false
end
