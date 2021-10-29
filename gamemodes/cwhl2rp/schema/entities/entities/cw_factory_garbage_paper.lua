--models/props/de_train/processor_nobase.mdl
--models/props/de_train/biohazardtank.mdl
if SERVER then AddCSLuaFile() end

ENT.PrintName = "Garbage Recycler - Paper"
ENT.Type = "anim"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.IsFactory = true

local WORK_ITEM = "paper"
local WORK_TIME = 15
local METAL_GARBAGE_COUNT_START = 4
local GARBAGE_ITEMS = {
	["empty_carton"] = 2,
	["empty_takeout_carton"] = 1,
	["empty_jug"] = 1
}

function ENT:Initialize()
	if SERVER then
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
	else
		self.RT = GetRenderTargetEx("_cmb_FIndicatorRT"..self:EntIndex()..CurTime(), 128, 85, RT_SIZE_DEFAULT, MATERIAL_RT_DEPTH_SHARED, 0x0001, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_DEFAULT)
		self.RTMat = CreateMaterial("_cmb_FIndicatorRTMAT" .. self:EntIndex() .. CurTime(), "UnlitTwoTexture", {
			["$selfilium"] = "1",
			["$texture2"] = "dev/dev_scanline",
			["Proxies"] =
			{

				["TextureScroll"] =
				{
					["texturescrollvar"] = "$texture2transform",
					["texturescrollrate"] = "3",
					["texturescrollangle"] = "90"
				}
			}
		})
	end
end

function ENT:SetupDataTables()
	self:NetworkVar("Vector", "0", "ProductPos")
	self:NetworkVar("Float", "2", "GarbageCount")
	self:NetworkVar("Bool", "0", "IsWorking")
	self:NetworkVar("Float", "0", "StartWorkTime")
	self:NetworkVar("Float", "1", "NextWorkTime")
	self:NetworkVar("Int", "0", "EjectStorage")
	self:NetworkVar("Float", "3","StopWorkTime")
end

if SERVER then
	function ENT:SpawnFunction(ply, trace)
		local ent = ents.Create("cw_factory_garbage_paper")
		ent:SetPos(trace.HitPos + trace.HitNormal * 25)
		ent:Spawn()
		ent:Activate()
		return ent
	end
	function ENT:CanGarbageUsed(item)
		if GARBAGE_ITEMS[item("uniqueID")] then
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
			if self:GetGarbageCount() != METAL_GARBAGE_COUNT_START then
				return
			end
			self:SetStartWorkTime(CurTime())
			self:SetNextWorkTime(CurTime() + WORK_TIME)
		else
			local i = WORK_TIME - self:GetStopWorkTime()
			self:SetStartWorkTime(CurTime() - i)
			self:SetNextWorkTime((CurTime() + WORK_TIME) - i)
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

		cw.entity:CreateItem(nil, WORK_ITEM, self:GetProductPos())
	end

	function ENT:Use(activator)
		return
	end

	function ENT:OnRemove()
		if self.WorkSound then
			self.WorkSound:Stop()
		end
	end
end

function ENT:Think()
	if SERVER then
		if !self:GetIsWorking() then
			if self:GetStopWorkTime() <= 0 then
				local pos = self:GetSearchPos()
				for k, v in pairs(ents.FindInBox(pos[1], pos[2])) do
					if self:GetGarbageCount() != METAL_GARBAGE_COUNT_START then
						if v:GetClass() != "cw_item" then continue end
						if !self:CanGarbageUsed(v:GetItemTable()) then continue end

						v:Remove()
						self:SetGarbageCount(self:GetGarbageCount() + (GARBAGE_ITEMS[v:GetItemTable()("uniqueID")] or 1))
						self.Garbages[#self.Garbages + 1] = v:GetItemTable()("uniqueID")
					end
				end
			end
		end

		if self.NextWorkSound and CurTime() > self.NextWorkSound then
			self.WorkSound = CreateSound(self, "plats/rackmove1.wav")
			self.WorkSound:Play()
			self.NextRandomSound = CurTime() + 0.65
			self.NextWorkSound = nil
		end
		if self.NextRandomSound and CurTime() > self.NextRandomSound then
			if math.Rand(0,1) > 0.8 then
				self:EmitSound("plats/hall_elev_stop.wav")
			end
			self.NextRandomSound = CurTime() + 0.65
		end
		if self:GetIsWorking() then
			if !self.NextGarbageDecrease then
				self.NextGarbageDecrease = CurTime() + ((self:GetNextWorkTime() - self:GetStartWorkTime()) - 5) / METAL_GARBAGE_COUNT_START
			elseif self.NextGarbageDecrease and CurTime() > self.NextGarbageDecrease then
				self:SetGarbageCount(math.Clamp(self:GetGarbageCount() - 1, 0, METAL_GARBAGE_COUNT_START))
				table.remove(self.Garbages)
				self.NextGarbageDecrease = nil
			end
			if CurTime() > self:GetNextWorkTime() then
				self:EndWork()
			end
		else
			if self.WorkSound and self.WorkSound:IsPlaying() then
				self.WorkSound:Stop()
			end
			if self:GetStopWorkTime() > 0 then
				local i = WORK_TIME - self:GetStopWorkTime()
				self:SetStartWorkTime(CurTime() - i)
				self:SetNextWorkTime((CurTime() + WORK_TIME) - i)
				self.NextGarbageDecrease = CurTime() + ((self:GetNextWorkTime() - (self:GetStartWorkTime() + i)) - 5) / METAL_GARBAGE_COUNT_START
			end
		end
	end

	self:NextThink(CurTime())
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()

		if IsValid(LocalPlayer():GetActiveWeapon()) then
			if LocalPlayer():GetActiveWeapon():GetClass() == "gmod_tool" then
				render.DrawLine(self:GetProductPos() - self:GetForward() * 12, self:GetProductPos() + self:GetForward() * 12, Color(255,255,255), true)
				render.DrawLine(self:GetProductPos() - self:GetRight() * 12, self:GetProductPos() + self:GetRight() * 12, Color(255,255,255), true)
				render.DrawLine(self:GetProductPos() - self:GetUp() * 12, self:GetProductPos() + self:GetUp() * 12, Color(255,255,255), true)
				render.DrawLine(self:GetProductPos(), self:GetPos(), Color(255,255,255), true)
			end
		end

		local pos = self:GetPos()
		local ang = self:GetAngles()

		ang:RotateAroundAxis(ang:Forward(), 90)
		ang:RotateAroundAxis(ang:Right(), -90)

		pos = pos + self:GetForward() * 10.2 + self:GetUp() * 18.85 + self:GetRight() * 17

		render.PushRenderTarget(self.RT)
			render.Clear(0, 0, 0, 255)
			cam.Start2D()
				surface.SetDrawColor(50, 50, 50, 255)
				surface.DrawRect(0, 0, 385, 256)
				surface.SetTextColor(255, 255, 255)
				surface.SetFont("_GR_CMB_FONT_1")
				surface.SetTextPos(8, 5)
				surface.DrawText("Garbage Recycler")
				surface.SetFont("_GR_CMB_FONT_2")
				surface.SetTextPos(8, 20)
				surface.DrawText("PAPER")

				local isWorking = self:GetIsWorking()
				local stopped = self:GetStopWorkTime() > 0
				local hasMaterial = self:GetGarbageCount() != METAL_GARBAGE_COUNT_START

				local text = isWorking and "RECYCLING..." or (stopped and "STOPPED" or (hasMaterial and "NOT ENOUGH GARBAGE" or "READY"))
				local red = isWorking and 0 or (stopped and 255 or (hasMaterial and 255 or 0))
				local green = isWorking and 255 or (stopped and 0 or (hasMaterial and 0 or 255))
				surface.SetTextColor(red, green, 0, math.abs(math.cos(RealTime() * 2) * 255))
				surface.SetFont("_GR_CMB_FONT_3")
				local w, h = surface.GetTextSize(text)
				surface.SetTextPos(6, 31)
				surface.DrawText(text)

				local var = self:GetGarbageCount() / METAL_GARBAGE_COUNT_START
				local _cur = CurTime() - self:GetStartWorkTime()
				local _end = self:GetNextWorkTime() - self:GetStartWorkTime()
				local var2 = math.Clamp((_cur / _end), 0, 1)
				if !self:GetIsWorking() then
					if self:GetStopWorkTime() > 0 then
						local i = WORK_TIME - self:GetStopWorkTime()
						_cur = 0 - (0 - i)
						_end = ((0 + WORK_TIME) - i) - (0 - i)
						var2 = math.Clamp((_cur / _end), 0, 1)
					else
						var2 = 0
					end
				end

				surface.SetDrawColor(Color(65, 65, 65, 255))
				surface.DrawRect(128 / 2 - 114 / 2, 100 / 2 - 16 / 2, 114, 16)
				surface.SetDrawColor(Color(50, 120, 230, 255))
				local bar = math.Clamp((var * 114) - 2, 0, 114)
				surface.DrawRect(128 / 2 - 114 / 2 + 1, 100 / 2 - 16 / 2 + 1, bar, 16 - 2)

				local text = self:GetGarbageCount() .. "/" .. METAL_GARBAGE_COUNT_START
				surface.SetTextColor(255, 255, 255, 150)
				surface.SetFont("_GR_CMB_FONT_1")
				local w, h = surface.GetTextSize(text)
				surface.SetTextPos(128 / 2 - w / 2, 100 / 2 - h / 2)
				surface.DrawText(text)

				surface.SetDrawColor(Color(65, 65, 65, 255))
				surface.DrawRect(128 / 2 - 114 / 2, 100 / 2 - 16 / 2 + 20, 114, 16)
				surface.SetDrawColor(Color(50, 240, 50, 255))
				local bar = math.Clamp((var2 * 114) - 2, 0, 114)
				surface.DrawRect(128 / 2 - 114 / 2 + 1, 100 / 2 - 16 / 2 + 1 + 20, bar, 16 - 2)

				local text = math.Round((var2 * 100))  .. "%"
				surface.SetTextColor(255, 255, 255, 150)
				surface.SetFont("_GR_CMB_FONT_1")
				local w, h = surface.GetTextSize(text)
				surface.SetTextPos(128 / 2 - w / 2, 100 / 2 - h / 2 + 20)
				surface.DrawText(text)
			cam.End2D()
		render.PopRenderTarget()

		self.RTMat:SetTexture("$basetexture", self.RT)

		cam.Start3D2D(pos, ang, 0.064)
			render.PushFilterMin(TEXFILTER.NONE)
			render.PushFilterMag(TEXFILTER.NONE)

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(self.RTMat)
			surface.DrawTexturedRect(0, 0, 385, 269)

			render.PopFilterMin()
			render.PopFilterMag()
		cam.End3D2D()
	end
end