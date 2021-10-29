include("shared.lua");

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");

function ENT:SpawnFunction( player, trace )
	if (!trace.Hit) then return end

	local entity = ents.Create("cw_forcefield");

	entity:SetPos(trace.HitPos + Vector(0, 0, 40));
	entity:SetAngles(Angle(0, trace.HitNormal:Angle().y - 90, 0));
	entity:Spawn();
	entity.owner = player;

	return entity;
end;

function ENT:SetupDataTables()
	self:DTVar("Int", 0, "Mode");
	self:DTVar("Entity", 0, "Dummy");
end;

function ENT:Initialize()
	self:SetModel("models/props_combine/combine_fence01b.mdl");
	self:SetSolid(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:DrawShadow(false);
	
	if (!isbool(self.on)) then
		self.on = true
	end

	self.mode = self.mode or 1
	self:SetDTInt(0, self.mode)

	if (!self.noCorrect) then
		local data = {};
		data.start = self:GetPos();
		data.endpos = self:GetPos() - Vector(0, 0, 300);
		data.filter = self;
		local trace = util.TraceLine(data);

		if trace.Hit and util.IsInWorld(trace.HitPos) and self:IsInWorld() then
			self:SetPos(trace.HitPos + Vector(0, 0, 39.9));
		end;

		data = {};
		data.start = self:GetPos();
		data.endpos = self:GetPos() + Vector(0, 0, 150);
		data.filter = self;
		trace = util.TraceLine(data);

		if trace.Hit then
			self:SetPos(self:GetPos() - Vector(0, 0, trace.HitPos:Distance(self:GetPos() + Vector(0, 0, 151))));
		end;
	end

	data = {};
	data.start = self:GetPos() + Vector(0, 0, 50) + self:GetRight() * -16;
	data.endpos = self:GetPos() + Vector(0, 0, 50) + self:GetRight() * -600;
	data.filter = self;
	trace = util.TraceLine(data);

	self.post = ents.Create("prop_physics")
	self.post:SetModel("models/props_combine/combine_fence01a.mdl")
	self.post:SetPos(self.forcePos or trace.HitPos - Vector(0, 0, 50))
	self.post:SetAngles(Angle(0, self:GetAngles().y, 0));
	self.post:Spawn();
	self.post.PhysgunDisabled = true;
	self.post:SetCollisionGroup(COLLISION_GROUP_WORLD);
	self.post:DrawShadow(false);
	self.post:DeleteOnRemove(self);
	self.post:MakePhysicsObjectAShadow(false, false);
	self:DeleteOnRemove(self.post);

	local verts = {
		{pos = Vector(0, 0, -35)},
		{pos = Vector(0, 0, 150)},
		{pos = self:WorldToLocal(self.post:GetPos()) + Vector(0, 0, 150)},
		{pos = self:WorldToLocal(self.post:GetPos()) + Vector(0, 0, 150)},
		{pos = self:WorldToLocal(self.post:GetPos()) - Vector(0, 0, 35)},
		{pos = Vector(0, 0, -35)},
	}

	self:PhysicsFromMesh(verts);
	local physObj = self:GetPhysicsObject();

	if (IsValid(physObj)) then
		physObj:SetMaterial("default_silent");
		physObj:EnableMotion(false);
	end;

	self:SetCustomCollisionCheck(true);
	self:EnableCustomCollisions(true);

	physObj = self.post:GetPhysicsObject();

	if (IsValid(physObj)) then
		physObj:EnableMotion(false);
	end;

	self:SetDTEntity(0, self.post);

	self.ShieldLoop = CreateSound(self, "ambient/machines/combine_shield_loop3.wav");

	if (self.mode == 4) then
		self.on = false;
		self:SetSkin(1);
		self.post:SetSkin(1);
		self:EmitSound("shield/deactivate.wav");
		self:SetCollisionGroup(COLLISION_GROUP_WORLD);
	end

	plugin.Call("SaveForceFields")
end;

function ENT:StartTouch( ent )
	if !(self.on) then return; end;

	if (ent:IsPlayer()) then
		if (!ent:IsCombine()) then
			if (!ent.ShieldTouch) then
				ent.ShieldTouch = CreateSound(ent, "ambient/machines/combine_shield_touch_loop1.wav");
				ent.ShieldTouch:Play();
				ent.ShieldTouch:ChangeVolume(0.25, 0);
			else
				ent.ShieldTouch:Play();
				ent.ShieldTouch:ChangeVolume(0.25, 0.5);
			end
		end;
	end;
end;

function ENT:Touch(ent)
	if !(self.on) then return; end;

	if (ent:IsPlayer()) then
		if (!ent:IsCombine()) then
			if ent.ShieldTouch then
				ent.ShieldTouch:ChangeVolume(0.3, 0);
			end;
		end;
	end;
end;

function ENT:EndTouch( ent )
	if !(self.on) then return; end;

	if (ent:IsPlayer()) then
		if (!ent:IsCombine()) then
			if (ent.ShieldTouch) then
				ent.ShieldTouch:FadeOut(0.5);
			end;
		end;
	end;
end;

function ENT:Think()
	if (IsValid(self) and self.on) then
		self.ShieldLoop:Play();
		self.ShieldLoop:ChangeVolume(0.4, 0);
	else
		self.ShieldLoop:Stop();
	end;

	local physObj = self:GetPhysicsObject()

	if (IsValid(physObj)) then
		physObj:EnableMotion(false);
	end;
end;

function ENT:OnRemove()
	if self.ShieldLoop then
		self.ShieldLoop:Stop();
	end;
end;

function ENT:RestoreMode(mode, bIsOn)
	self.on = bIsOn
	self.mode = mode
end

function ENT:Use(act, call, type, val)
	local curTime = CurTime()

	if ((self.nextUse or 0) < curTime) then
		self.nextUse = curTime + 1;
	else
		return;
	end;

	if (act:IsCombine()) then
		self.mode = (self.mode or 1) + 1;
		self:SetDTInt(0, self.mode);

		if (self.mode > #cwForceField.modes) then
			self.mode = 1;
			self:SetDTInt(0, self.mode);
		end;

		if (self.mode == 4) then
			self.on = false;
			self:SetSkin(1);
			self.post:SetSkin(1);
			self:EmitSound("shield/deactivate.wav");
			self:SetCollisionGroup(COLLISION_GROUP_WORLD);
		else
			self.on = true;
			self:SetSkin(0);
			self.post:SetSkin(0);
			self:EmitSound("shield/activate.wav");
			self:SetCollisionGroup(COLLISION_GROUP_NONE);
		end;

		self:EmitSound("buttons/combine_button5.wav", 140, 100 + (self.mode - 1) * 15);
		cw.player:Notify(act, "Changed force field mode to: "..cwForceField.modes[self.mode]);

		plugin.Call("SaveForceFields")
	end
end

function ENT:OnRemove()
	if (self.ShieldLoop) then
		self.ShieldLoop:Stop()
		self.ShieldLoop = nil
	end

	if self.ShieldTouch then
		self.ShieldTouch:Stop()
		self.ShieldTouch = nil
	end
end