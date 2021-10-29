ENT.Base = "base_gmodentity"
ENT.Type = "anim"

ENT.PrintName = "Переработка: Металл"
ENT.Category = "HL2RP: Переработка"
ENT.Author = "AleXXX_007"

ENT.Contact			= ""
ENT.Purpose 		= ""
ENT.Instructions 	= ""

ENT.Spawnable			= true
ENT.AdminSpawnable		= true
ENT.IsFactory = true

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Model = "models/props_combine/combine_smallmonitor001.mdl"

ENT.WORK_ITEM = "scrap_metal"
ENT.WORK_TIME = 30
ENT.METAL_GARBAGE_COUNT_START = 10
ENT.GARBAGE_ITEMS = {
	"empty_can",
	"empty_soda_can",
	"weapon_hl2axe",
	"weapon_crowbar",
	"cw_stunstick",
	"weapon_hl2shovel",
	"weapon_hl2pot",
	"weapon_hl2pipe",
	"weapon_hl2pickaxe",
	"weapon_hl2pan",
	"weapon_hl2hook",
}

function ENT:SetupDataTables()
	self:NetworkVar("Vector", "0", "ProductPos")
	self:NetworkVar("Float", "2", "GarbageCount")
	self:NetworkVar("Bool", "0", "IsWorking")
	self:NetworkVar("Float", "0", "StartWorkTime")
	self:NetworkVar("Float", "1", "NextWorkTime")
	self:NetworkVar("Int", "0", "EjectStorage")
	self:NetworkVar("Float", "3","StopWorkTime")
end

function ENT:Think()
	if SERVER then
		if !self:GetIsWorking() then
			if self:GetStopWorkTime() <= 0 then
				local pos = self:GetSearchPos()
				for k, v in pairs(ents.FindInBox(pos[1], pos[2])) do

					if self:GetGarbageCount() < self.METAL_GARBAGE_COUNT_START then
						if v:GetClass() != "cw_item" then continue end
						if !self:CanGarbageUsed(v:GetItemTable()) then continue end

						v:Remove()
						self:SetGarbageCount(self:GetGarbageCount() + (v:GetItemTable()("weight") * 2 or 1))
						self.Garbages[#self.Garbages + 1] = v:GetItemTable()("uniqueID")
						self:EmitSound("items/ammocrate_close.wav")
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
				self.NextGarbageDecrease = CurTime() + ((self:GetNextWorkTime() - self:GetStartWorkTime()) - 5) / self.METAL_GARBAGE_COUNT_START
			elseif self.NextGarbageDecrease and CurTime() > self.NextGarbageDecrease then
				self:SetGarbageCount(math.Clamp(self:GetGarbageCount() - 1, 0, self.METAL_GARBAGE_COUNT_START))
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
				local i = self.WORK_TIME - self:GetStopWorkTime()
				self:SetStartWorkTime(CurTime() - i)
				self:SetNextWorkTime((CurTime() + self.WORK_TIME) - i)
				self.NextGarbageDecrease = CurTime() + ((self:GetNextWorkTime() - (self:GetStartWorkTime() + i)) - 5) / self.METAL_GARBAGE_COUNT_START
			end
		end
	end

	self:NextThink(CurTime())
end

hook.Add("PostDrawOpaqueRenderables", "Factories", function()
	if IsValid(LocalPlayer():GetActiveWeapon()) then
		if LocalPlayer():GetActiveWeapon():GetClass() == "gmod_tool" then
			for k, self in pairs(ents.GetAll()) do
				if (self:GetClass() != "cw_factory_garbage_metal" or
				   self:GetClass() != "cw_factory_garbage_paper" or
				   self:GetClass() != "cw_factory_garbage_plastic") then continue end

				render.DrawLine(self:GetProductPos() - self:GetForward() * 12, self:GetProductPos() + self:GetForward() * 12, Color(255,255,255), true)
				render.DrawLine(self:GetProductPos() - self:GetRight() * 12, self:GetProductPos() + self:GetRight() * 12, Color(255,255,255), true)
				render.DrawLine(self:GetProductPos() - self:GetUp() * 12, self:GetProductPos() + self:GetUp() * 12, Color(255,255,255), true)
				render.DrawLine(self:GetProductPos(), self:GetPos(), Color(255,255,255), true)
			end
		end
	end
end)