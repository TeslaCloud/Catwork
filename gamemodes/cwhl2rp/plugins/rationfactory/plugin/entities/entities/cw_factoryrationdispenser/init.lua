--[[
	© 2012 Iron-Wall.org do not share, re-distribute or modify
	without permission of its author (ext@iam1337.ru).
--]]

include("shared.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

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

	self:SetDTInt(0,5)
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:Toggle()
	if (self:IsLocked()) then
		self:Unlock()
	else
		self:Lock()
	end
end

function ENT:Lock()
	self:SetDTBool(0, true)
	self:EmitRandomSound()
end

function ENT:Unlock()
	self:SetDTBool(0, false)
	self:EmitRandomSound()
end

function ENT:SetFlashDuration(duration)
	self:EmitSound("buttons/combine_button_locked.wav")
	self:SetDTFloat(1, CurTime() + duration)
end

function ENT:CreateDummyRation(model)
	local forward = self:GetForward() * 15
	local right = self:GetRight() * 0
	local up = self:GetUp() * -8

	local entity = ents.Create("prop_physics")

	entity:SetAngles(self:GetAngles())
	entity:SetModel(model)
	entity:SetPos(self:GetPos() + forward + right + up)
	entity:Spawn()

	return entity
end

function ENT:ActivateRation(activator, duration, force)
	local curTime = CurTime()

	local loyalityPoints = activator:GetCharacterData("civ_reputation") or 0

	if (loyalityPoints > 50 or Schema:PlayerIsCWU(activator)) then
		entModel = "models/weapons/w_packatp.mdl"
		rationType = "ration_high"
		duration = 8
	elseif (loyalityPoints > 25) then
		entModel = "models/weapons/w_packatl.mdl"
		rationType = "ration_medium"
		duration = 12
	elseif (loyalityPoints > 10) then
		entModel = "models/weapons/w_packatc.mdl"
		rationType = "ration_standard"
		duration = 18
	else
		entModel = "models/weapons/w_packati.mdl"
		rationType = "ration_normal"
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
							entity:Fire("SetParentAttachment", "package_attachment", 0)

							timer.Simple(frameTime, function()
								if (IsValid(self) and IsValid(entity)) then
									dispenser:Fire("SetAnimation", "dispense_package", 0)

									timer.Simple(1.75, function()
										if (IsValid(self) and IsValid(entity)) then
											local position = entity:GetPos()
											local angles = entity:GetAngles()
											
											entity:CallOnRemove("CreateRation", function()
												if (IsValid(activator)) then
													local itemTable = item.CreateInstance(rationType)
													
													if (itemTable) then
														cw.entity:CreateItem(activator, itemTable, position, angles)
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

function ENT:PhysicsUpdate(physicsObject)
	if (!self:IsPlayerHolding() and !self:IsConstrained()) then
		physicsObject:SetVelocity(Vector(0, 0, 0))
		physicsObject:Sleep()
	end
end

function ENT:Use(activator, caller)
	if (activator:IsPlayer() and activator:GetEyeTraceNoCursor().Entity == self) then
		local curTime = CurTime()
		local unixTime = os.time()

		if (!self.nextUse or curTime >= self.nextUse) then
			if (!Schema:PlayerIsCombine(activator)) then
				if (!self:IsLocked() and unixTime >= activator:GetCharacterData("nextration", 0) and self:GetDTInt(0) >= 1) then
					if (!self.nextActivateRation or curTime >= self.nextActivateRation) then
						self:ActivateRation(activator)
						self:SetDTInt(0, self:GetDTInt(0) - 1)
						activator:SetCharacterData("nextration", unixTime + config.Get("wages_interval"):Get() * 10)
					end
				else
					self:SetFlashDuration(3)
				end
			elseif (!self.nextActivateRation or curTime >= self.nextActivateRation) then

				if (activator:HasItemByID("ration_standard") and table.Count(activator:GetItemsByID("ration_standard")) >= 1) then
					local itemTable = activator:FindItemByID("ration_standard")

					activator:TakeItem(itemTable, true)
					self:SetDTInt(0, self:GetDTInt(0) + 1)
					self:EmitRandomSound()
				else
					self:Toggle()

					self.nextUse = curTime + 3
				end
			end

			self.nextUse = curTime + 3
		end
	end
end

function ENT:CanTool(player, trace, tool)
	return false
end

function ENT:SetRationCount(count)
	self:SetDTInt(0,count)
end