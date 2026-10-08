--- Server side of the `cw_forcefield` entity of the Force Fields plugin, a Combine force field between two posts whose
-- mode a Combine player cycles with the use key.
--
-- `ENT:Initialize` spawns the far post at the nearest wall and builds the collision mesh between the posts; the
-- networked int 0 holds the mode and the networked entity 0 the far post. The field hums while powered, plays a sound
-- on non-Combine players who touch it and saves all forcefields when its mode changes.

include('shared.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

--- Spawns a forcefield where the player is looking, facing along the hit surface.
--
-- @return [Entity The new forcefield, or `nil` when the trace hit nothing]
function ENT:SpawnFunction(player, trace)
  if !trace.Hit then return end

  local entity = ents.Create('cw_forcefield')

  entity:SetPos(trace.HitPos + Vector(0, 0, 40))
  entity:SetAngles(Angle(0, trace.HitNormal:Angle().y - 90, 0))
  entity:Spawn()
  entity.owner = player

  return entity
end

--- Sets up the networked int 0 (`Mode`) and entity 0 (`Dummy`, the far post).
function ENT:SetupDataTables()
  self:DTVar('Int', 0, 'Mode')
  self:DTVar('Entity', 0, 'Dummy')
end

--- Sets up the post, spawns the far post at the nearest wall and builds the field's collision mesh.
--
-- Unless `noCorrect` is set, snaps the post to the floor first. Starts in mode 1 and switched
-- on unless `ENT:RestoreMode` set otherwise; mode 4 starts switched off. Saves the
-- forcefields afterwards, unless the field is one being restored from that save.
function ENT:Initialize()
  self:SetModel('models/props_combine/combine_fence01b.mdl')
  self:SetSolid(SOLID_VPHYSICS)
  self:SetUseType(SIMPLE_USE)
  self:PhysicsInit(SOLID_VPHYSICS)
  self:DrawShadow(false)

  if !isbool(self.on) then
    self.on = true
  end

  self.mode = self.mode or 1
  self:SetDTInt(0, self.mode)

  if !self.noCorrect then
    local data = {}
    data.start = self:GetPos()
    data.endpos = self:GetPos() - Vector(0, 0, 300)
    data.filter = self
    local trace = util.TraceLine(data)

    if trace.Hit and util.IsInWorld(trace.HitPos) and self:IsInWorld() then
      self:SetPos(trace.HitPos + Vector(0, 0, 39.9))
    end

    data = {}
    data.start = self:GetPos()
    data.endpos = self:GetPos() + Vector(0, 0, 150)
    data.filter = self
    trace = util.TraceLine(data)

    if trace.Hit then
      self:SetPos(self:GetPos() - Vector(0, 0, trace.HitPos:Distance(self:GetPos() + Vector(0, 0, 151))))
    end
  end

  local data = {}
  data.start = self:GetPos() + Vector(0, 0, 50) + self:GetRight() * -16
  data.endpos = self:GetPos() + Vector(0, 0, 50) + self:GetRight() * -600
  data.filter = self
  local trace = util.TraceLine(data)

  self.post = ents.Create('prop_physics')
  self.post:SetModel('models/props_combine/combine_fence01a.mdl')
  self.post:SetPos(self.forcePos or trace.HitPos - Vector(0, 0, 50))
  self.post:SetAngles(Angle(0, self:GetAngles().y, 0))
  self.post:Spawn()
  self.post.PhysgunDisabled = true
  self.post:SetCollisionGroup(COLLISION_GROUP_WORLD)
  self.post:DrawShadow(false)
  self.post:DeleteOnRemove(self)
  self.post:MakePhysicsObjectAShadow(false, false)
  self:DeleteOnRemove(self.post)

  local verts = {
    { pos = Vector(0, 0, -35) },
    { pos = Vector(0, 0, 150) },
    { pos = self:WorldToLocal(self.post:GetPos()) + Vector(0, 0, 150) },
    { pos = self:WorldToLocal(self.post:GetPos()) + Vector(0, 0, 150) },
    { pos = self:WorldToLocal(self.post:GetPos()) - Vector(0, 0, 35) },
    { pos = Vector(0, 0, -35) }
  }

  self:PhysicsFromMesh(verts)
  local physObj = self:GetPhysicsObject()

  if IsValid(physObj) then
    physObj:SetMaterial('default_silent')
    physObj:EnableMotion(false)
  end

  self:SetCustomCollisionCheck(true)
  self:EnableCustomCollisions(true)

  physObj = self.post:GetPhysicsObject()

  if IsValid(physObj) then
    physObj:EnableMotion(false)
  end

  self:SetDTEntity(0, self.post)

  self.ShieldLoop = CreateSound(self, 'ambient/machines/combine_shield_loop3.wav')

  if self.mode == 4 then
    self.on = false
    self:SetSkin(1)
    self.post:SetSkin(1)
    self:EmitSound('shield/deactivate.wav')
    self:SetCollisionGroup(COLLISION_GROUP_WORLD)
  end

  -- Saving while the saved fields are still being spawned would write an incomplete list.
  if !self.noCorrect then
    plugin.Call('SaveForceFields')
  end
end

--- Starts the shield touch sound on a non-Combine player touching the powered field.
function ENT:StartTouch(ent)
  if !(self.on) then return end

  if ent:IsPlayer() then
    if !ent:IsCombine() then
      if !ent.ShieldTouch then
        ent.ShieldTouch = CreateSound(ent, 'ambient/machines/combine_shield_touch_loop1.wav')
        ent.ShieldTouch:Play()
        ent.ShieldTouch:ChangeVolume(0.25, 0)
      else
        ent.ShieldTouch:Play()
        ent.ShieldTouch:ChangeVolume(0.25, 0.5)
      end
    end
  end
end

--- Keeps the touch sound's volume up while a non-Combine player touches the powered field.
function ENT:Touch(ent)
  if !(self.on) then return end

  if ent:IsPlayer() then
    if !ent:IsCombine() then
      if ent.ShieldTouch then
        ent.ShieldTouch:ChangeVolume(0.3, 0)
      end
    end
  end
end

--- Fades the touch sound out when a player stops touching the field.
--
-- Also when the field has been switched off in the meantime, or the sound would play on.
function ENT:EndTouch(ent)
  if ent:IsPlayer() and ent.ShieldTouch then
    ent.ShieldTouch:FadeOut(0.5)
  end
end

--- Plays the shield's humming loop while it is powered and keeps the field frozen, once a second.
--
-- @return [Boolean `true`, so the next think time is used]
function ENT:Think()
  if self.on then
    self.ShieldLoop:Play()
    self.ShieldLoop:ChangeVolume(0.4, 0)
  else
    self.ShieldLoop:Stop()
  end

  local physObj = self:GetPhysicsObject()

  if IsValid(physObj) then
    physObj:EnableMotion(false)
  end

  self:NextThink(CurTime() + 1)

  return true
end

--- Sets the field's mode and power state before it spawns, when restoring saved fields.
--
-- @param mode [Number The mode, 1 to 4, as in `cwForceField.modes`]
-- @param bIsOn [Boolean Whether the field is powered]
function ENT:RestoreMode(mode, bIsOn)
  self.on = bIsOn
  self.mode = mode
end

--- Cycles a Combine player's forcefield to the next mode, at most once a second.
--
-- Mode 4 switches the field off and lets everything through. Tells the player the new
-- mode and saves the forcefields.
function ENT:Use(act, call, type, val)
  if !IsValid(act) or !act:IsPlayer() then return end

  local curTime = CurTime()

  if (self.nextUse or 0) >= curTime then return end

  if act:IsCombine() then
    -- Only a use that changes the mode starts the delay; anyone could hold the field busy otherwise.
    self.nextUse = curTime + 1
    self.mode = (self.mode or 1) + 1
    self:SetDTInt(0, self.mode)

    if self.mode > #cwForceField.modes then
      self.mode = 1
      self:SetDTInt(0, self.mode)
    end

    if self.mode == 4 then
      self.on = false
      self:SetSkin(1)
      self.post:SetSkin(1)
      self:EmitSound('shield/deactivate.wav')
      self:SetCollisionGroup(COLLISION_GROUP_WORLD)
    else
      self.on = true
      self:SetSkin(0)
      self.post:SetSkin(0)
      self:EmitSound('shield/activate.wav')
      self:SetCollisionGroup(COLLISION_GROUP_NONE)
    end

    -- The hum follows the new power state on the next tick instead of up to a second later.
    self:NextThink(curTime)

    self:EmitSound('buttons/combine_button5.wav', 140, 100 + (self.mode - 1) * 15)
    cw.player:Notify(act, L('ForceField_ModeChanged')..' '..cwForceField.modes[self.mode])

    plugin.Call('SaveForceFields')
  end
end

--- Stops and clears the humming loop and the field's `ShieldTouch` sound.
--
-- Touch sounds are stored on the touching players, so the field's own `ShieldTouch` is
-- normally `nil`.
function ENT:OnRemove()
  if self.ShieldLoop then
    self.ShieldLoop:Stop()
    self.ShieldLoop = nil
  end

  if self.ShieldTouch then
    self.ShieldTouch:Stop()
    self.ShieldTouch = nil
  end
end
