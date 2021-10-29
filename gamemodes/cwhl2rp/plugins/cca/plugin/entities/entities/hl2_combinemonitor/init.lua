AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetHealth(1)
	self:SetSolid(SOLID_VPHYSICS)

	self:SetNetVar("monitor_activated", false)

	self.timeGen = CurTime()

	local physicsObject = self:GetPhysicsObject()

	if (IsValid(physicsObject)) then
		physicsObject:Sleep()
		physicsObject:EnableMotion(false)
	end
end

function ENT:SpawnFunction(client, trace)
	local entity = ents.Create(self.ClassName)
	entity:SetPos(trace.HitPos)
	entity:SetAngles(trace.HitNormal:Angle())
	entity:Spawn()
	entity:Activate()

	return entity
end

function ENT:TurnOff()
	self:SetNetVar("monitor_activated", false)
	self:EmitSound("buttons/blip1.wav")
end

function ENT:TurnOn(player)	
	if (player:GetCharacterData("cit_cid", 0)) then
		self:SetNetVar("monitor_activated", true)
		self:EmitSound("buttons/blip1.wav")
		self.timeGen = CurTime() + 6
	end
end

function ENT:Think()
	local curTime = CurTime()

	if (self:GetNetVar("monitor_activated")) then
		if (self.timeGen < curTime) then
			self:TurnOff()
			self:SetNetVar("users", {})
		end
	else
		self.activator = nil
	end

	self:NextThink(curTime + 1)
end

-- (c) [s]AleXXX_007[/s] ИДИ НАХУЙ СУКА СО СВОИМ ГОВНОКОДОМ БЛЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯ
-- ~mew
function ENT:SetPlayer(player)
	local data = {}
	local workPoints = Schema:GetWorkPoints(player)
	local wplevel = 0

	if (workPoints >= 220) then
		wplevel = 10
	elseif (workPoints >= 170) then
		wplevel = 9
	elseif (workPoints >= 130) then
		wplevel = 8
	elseif (workPoints >= 90) then
		wplevel = 7
	elseif (workPoints >= 60) then
		wplevel = 6
	elseif (workPoints >= 35) then
		wplevel = 5
	elseif (workPoints >= 20) then
		wplevel = 4
	elseif (workPoints >= 10) then
		wplevel = 3
	elseif (workPoints >= 5) then
		wplevel = 2
	elseif (workPoints >= 0) then
		wplevel = 1
	end

	data = {
		name = player:Name(),
		citizenID = player:GetCharacterData("citizenid", "ERROR"),
		lp = Schema:GetLP(player),
		cp = Schema:GetCP(player),
		status = "#Status_"..Schema:GetCitizenStatus(player),
		wp = Schema:GetWorkPoints(player),
		workLevel = wplevel,
		residence = Schema:GetResidence(player),
		job = Schema:GetJob(player)
	}

	self:SetNetVar("userData", data)
end

function ENT:Use(player)
	if (!self:GetNetVar("monitor_activated") && !player:IsCombine()) then
		self.activator = player
		self:TurnOn(player)
		self:SetPlayer(player)

		return
	end
end