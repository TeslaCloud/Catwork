if SERVER then AddCSLuaFile() end

ENT.PrintName = "Mortal Shell"
ENT.Type = "anim"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/props_phx/amraam.mdl")
		self:SetMoveType(MOVETYPE_FLY)
		self:SetSolid(SOLID_NONE)
		self:SetCollisionBounds(Vector(-1,-10,-64),Vector(16,10,64))

		self:SetAngles(Angle(90,0,0))
		self:SetModelScale(0.8,0)

		self.SmokeTrail = ents.Create("env_spritetrail")
		self.SmokeTrail:SetParent(self)	
		self.SmokeTrail:SetPos(self:GetPos() + Vector(7,0,60))
		self.SmokeTrail:SetAngles(self:GetAngles())
		self.SmokeTrail:SetKeyValue("lifetime", 2)
		self.SmokeTrail:SetKeyValue("startwidth", 32)
		self.SmokeTrail:SetKeyValue("endwidth", 256)
		self.SmokeTrail:SetKeyValue("spritename", "trails/smoke.vmt")
		self.SmokeTrail:SetKeyValue("renderamt", 235)
		self.SmokeTrail:SetKeyValue("rendercolor", "230 230 230")
		self.SmokeTrail:SetKeyValue("rendermode", 5)
		self.SmokeTrail:SetKeyValue("HDRColorScale", .75)
		self.SmokeTrail:Spawn()

		self:Think()
	end
end

if SERVER then
	function ENT:SpawnFunction(ply, trace)
		local ent = ents.Create("combine_mortar_shell")
		local tr = util.TraceLine({
			start = trace.HitPos,
			endpos = trace.HitPos + Vector(0,0,1) * (10^14),
			mask = MASK_PLAYERSOLID,
			filter = ent
		})
		ent:Spawn()
		ent:SetPos(tr.HitPos - ent:OBBMaxs() - Vector(0,0,1))
		ent:Activate()
		return ent
	end

	function ENT:OnRemove()
		if IsValid(self.SmokeTrail) then
			SafeRemoveEntity(self.SmokeTrail)
		end
	end
end
function ENT:HitThink()
	local tr = util.TraceHull({
		start = self:GetPos(),
		endpos = self:GetPos() - Vector(-7,0,60),
		filter = self,
		mins = Vector(-16, -16, -16),
		maxs = Vector(16, 16, 16),
		mask = MASK_SOLID
	})	

	if (tr.Hit or tr.HitWorld) and tr.Entity:GetClass() != "sammyservers_textscreen" then
		local exp = ents.Create("env_explosion")
		exp:SetPos(tr.HitPos)

		exp:Spawn()
		exp:SetKeyValue("iMagnitude", "200")
		exp:SetKeyValue("iRadiusOverride", 460)
		exp:Fire("Explode", 0, 0)
		util.ScreenShake(tr.HitPos, 64, 100, 1, 3256)
		SafeRemoveEntity(self)
	end
end
function ENT:Think()
	if SERVER then
		self:SetVelocity(Vector(0,0,-1) * 10^1.5)

		self:HitThink()
	end

	self:NextThink(CurTime())
	return true
end

if CLIENT then
	function ENT:DrawTranslucent()
		local pos = self:GetPos() + Vector(7,0,60)

		local ViewNormal = pos - EyePos()
		local Distance = ViewNormal:Length()
		ViewNormal:Normalize()
		local ViewDot = 1
		local LightPos = pos
		if (ViewDot >= 0) then
			local Visibile	= util.PixelVisible(LightPos, 8, self.PixVis)	
			if (!Visibile) then return end

			local Size = math.Clamp(Distance * Visibile * ViewDot * 2, 64, 800)
			local Size2 = math.Clamp(Distance * Visibile * ViewDot * 2, 0, 150)
			local Size3 = math.Clamp(Distance * Visibile * ViewDot * 2, 0, 128)
			local Size4 = math.Clamp(Distance * Visibile * ViewDot * 2, 0, 1512)
			local Size5 = math.Clamp(Distance * Visibile * ViewDot * 2, 0, 1024)
			Distance = math.Clamp(Distance, 32, 800)
			local Alpha = math.Clamp((1000 - Distance) * Visibile * ViewDot, 0, 255)
			local Alpha2 = math.Clamp((1000 - Distance) * Visibile * ViewDot, 0, 200)
			local Alpha3 = math.Clamp((1000 - Distance) * Visibile * ViewDot, 0, 70)

			render.SetMaterial(Material("sprites/light_ignorez"))

			render.DrawSprite(LightPos, Size*3,Size*3, Color(200, 225, 255, Alpha3/3), Visibile * ViewDot)
			render.DrawSprite(LightPos, Size,Size, Color(180, 200, 255, Alpha3), Visibile * ViewDot)
			render.DrawSprite(LightPos, Size*2,Size*0.5, Color(180, 200, 255, Alpha3), Visibile * ViewDot)
			render.DrawSprite(LightPos, Size2,Size2, Color(255,255,255,Alpha2))
			render.DrawSprite(LightPos, Size3,Size3, Color(255,0,0,Alpha2))
			render.DrawSprite(LightPos, Size3,Size3, Color(255,255,255,Alpha))
			render.DrawSprite(LightPos, Size2,Size2, Color(255,255,255,Alpha))
			render.DrawSprite(LightPos, Size4,Size2, Color(100,100,100,Alpha))
			render.DrawSprite(LightPos, Size5,Size5, Color(0,20,30,Alpha))
		end
	end

	function ENT:Initialize()
		self.PixVis = util.GetPixelVisibleHandle()
	end
	function ENT:Draw()
		self:DrawModel()
	end
end