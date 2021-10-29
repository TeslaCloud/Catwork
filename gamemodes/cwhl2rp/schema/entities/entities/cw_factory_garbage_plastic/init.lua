AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props/cs_militia/microwave01.mdl")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetMaterial(Material("models/props_combine/tprotato2_sheet"))
	local phys = self:GetPhysicsObject()

	if phys then
		phys:SetMass(120)
		phys:Wake()
	end

	self:SetGarbageCount(0)
	self.Garbages = {}
	self:SetIsWorking(false)
	self:SetProductPos(self:GetPos() + self:GetUp() * 20)
	self:SetEjectStorage(0)

	self.NextWorkSound = nil
	self.NextRandomSound = nil
	self.StopWorkTime = nil
end

function ENT:SpawnFunction(ply, trace)
	local ent = ents.Create("cw_factory_garbage_plastic")
	ent:SetPos(trace.HitPos + trace.HitNormal * 25)
	ent:Spawn()
	ent:Activate()
	return ent
end
function ENT:CanGarbageUsed(item)
	if (table.HasValue(self.GARBAGE_ITEMS, item("uniqueID"))) then
		return true
	end

	return false
end

function ENT:GetSearchPos()
	local up, right, forward = self:GetUp(), self:GetRight(), self:GetForward()
	local pos1 = self:GetPos() + (up * 23) + (right * 18) + (forward * 22)
	local pos2 = self:GetPos() + (up * -0.5) + (right * -18) + (forward * 6)
	return { pos1, pos2 }
end

function ENT:StartWork()
	if self:GetStopWorkTime() <= 0 then
		if self:GetGarbageCount() < self.METAL_GARBAGE_COUNT_START then
			return
		end
		self:SetStartWorkTime(CurTime())
		self:SetNextWorkTime(CurTime() + self.WORK_TIME)
	else
		local i = self.WORK_TIME - self:GetStopWorkTime()
		self:SetStartWorkTime(CurTime() - i)
		self:SetNextWorkTime((CurTime() + self.WORK_TIME) - i)
	end
	self:SetIsWorking(true)
	self:EmitSound("plats/elevator_large_start1.wav")
	self.NextWorkSound = CurTime() + 1.4

end

function ENT:Eject()
	if self:GetIsWorking() then return end
	if self:GetStopWorkTime() > 0 then return end

	local id = self:GetEjectStorage()
	local ent = nil
	for k, v in pairs(ents.GetAll()) do
		if v:GetCreationID() == id then
			ent = v
			break
		end
	end
	if !IsValid(ent) then return end

	if !ent.cwInventory then
		cwStorage.storage[ent] = ent

		ent.cwInventory = {}
	end

	for k, v in pairs(self.Garbages) do
		local itemTable = item.FindByID(v)

		local weight = itemTable.storageWeight or itemTable.weight
		local space = itemTable.storageSpace or itemTable.space

		local model = string.lower(ent:GetModel())
		if cwStorage.containerList[model] then
			local containerWeight = cwStorage.containerList[model][1]
			if (cw.inventory:CalculateWeight(ent.cwInventory) + math.max(weight, 0) > containerWeight) then
				cw.entity:CreateItem(nil, v, ent:GetPos() + ent:GetUp() * 20)
				continue
			end
		end

		cw.inventory:AddInstance(ent.cwInventory, item.CreateInstance(v))
	end

	self:SetGarbageCount(0)
	self.Garbages = {}
end

function ENT:StopWork()
	self:SetStopWorkTime(self:GetNextWorkTime() - CurTime())
	self:SetIsWorking(false)
	self.WorkSound:Stop()
	self:EmitSound("plats/elevator_large_stop1.wav")
	self.NextRandomSound = nil
	self.NextGarbageDecrease = nil
end

function ENT:EndWork()
	self:SetIsWorking(false)
	self.WorkSound:Stop()
	self:EmitSound("plats/elevator_large_stop1.wav")
	self.NextRandomSound = nil
	self.NextGarbageDecrease = nil
	self:SetStopWorkTime(0)

	cw.entity:CreateItem(nil, self.WORK_ITEM, self:GetProductPos())
end

function ENT:Use(activator)
	return
end

function ENT:OnRemove()
	if self.WorkSound then
		self.WorkSound:Stop()
	end
end