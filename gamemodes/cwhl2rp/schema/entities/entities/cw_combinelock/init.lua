--- Server side of the `cw_combinelock` entity, the Combine lock that is attached to a door and keeps it locked.
--
-- `ENT:SetDoor` binds it to a door and its double door partner, and using it toggles the lock for players who pass
-- `Schema:PlayerHasCombineLockAccess` (see `ENT:SetAccess` and `ENT:SetCPRank`) and flashes red for everyone else. The
-- lock has 800 health; when that reaches 0 a 12 second smoke charge busts its doors open.

include('shared.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

--- Sets up the lock model, physics, 800 health and the status light sprite.
function ENT:Initialize()
  self:SetModel('models/props_combine/combine_lock01.mdl')

  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetUseType(SIMPLE_USE)
  self:SetHealth(800)
  self:SetSolid(SOLID_VPHYSICS)

  self.glow = ents.Create('env_sprite')
  self.glow:SetKeyValue('model', 'glow04.vmt')
  self.glow:SetKeyValue('rendercolor', '0 255 0')
  self.glow:SetKeyValue('rendermode', '9')
  self.glow:SetKeyValue('scale', '0.25')
  self.glow:SetPos(self:GetPos() + self:GetForward() * -3.5 + self:GetUp() * -9 + self:GetRight() * -6)
  self.glow:SetParent(self)
  self.glow:Spawn()
  self.glow:Activate()

  local physicsObject = self:GetPhysicsObject()

  if IsValid(physicsObject) then
    physicsObject:Wake()
    physicsObject:EnableMotion(true)
  end
end

--- Always transmits the lock to every client.
function ENT:UpdateTransmitState()
  return TRANSMIT_ALWAYS
end

--- Keeps the doors locked or unlocked, updates the status light and keeps the lock frozen.
--
-- Removes the lock with an explosion when its door is gone. With the `combine_lock_overrides` config
-- enabled, the lock state is forced onto its doors every think. The light flashes red with a beep while a
-- smoke charge counts down, is red during an access denied flash, orange (or the override color) when
-- locked and green when unlocked.
function ENT:Think()
  if IsValid(self.entity) then
    if config.Get('combine_lock_overrides'):Get() then
      for k, v in ipairs(self.entities) do
        if IsValid(v) then
          if self:IsLocked() then
            v:Fire('Lock', '', 0)
            v:Fire('Close', '', 0)
          else
            v:Fire('Unlock', '', 0)
          end
        end
      end
    end
  else
    self:Explode() self:Remove()
  end

  local smokeChargeTime = self:GetDTFloat(0)
  local a = self:GetColor().a
  local flashTime = self:GetDTFloat(1)
  local position = self:GetPos()
  local forward = self:GetForward() * -4
  local curTime = CurTime()
  local right = self:GetRight() * -6
  local up = self:GetUp() * -9

  if smokeChargeTime > curTime then
    local glowColor = Color(255, 0, 0, a)
    local timeLeft = smokeChargeTime - curTime

    if !self.nextFlash or curTime >= self.nextFlash or (self.flashUntil and self.flashUntil > curTime) then
      self.glow:SetKeyValue('renderalpha', tostring(a))
      self.glow:SetKeyValue('rendercolor', '255 0 0')

      if !self.flashUntil or curTime >= self.flashUntil then
        self.nextFlash = curTime + (timeLeft / 4)
        self.flashUntil = curTime + (FrameTime() * 4)

        self:EmitSound('hl1/fvox/beep.wav')
      end
    end
  else
    local glowColor = Color(0, 255, 0, a)

    if self:IsLocked() then
      glowColor = Color(255, 150, 0, a)

      if self.overrideColor then
        glowColor = ColorAlpha(self.overrideColor, a)
      end
    end

    if flashTime and flashTime >= curTime then
      glowColor = Color(255, 0, 0, a)
    end

    self.glow:SetKeyValue('renderalpha', tostring(a))
    self.glow:SetKeyValue('rendercolor', glowColor.r..' '..glowColor.g..' '..glowColor.b)
  end

  if IsValid(self:GetPhysicsObject()) then
    self:GetPhysicsObject():SetVelocity(Vector())
    self:GetPhysicsObject():EnableMotion(false)
  end

  self:NextThink(curTime + 0.1)
end

--- Sets the color the status light shows while the lock is locked.
-- @param color [Color Light color, or `nil` for the default orange]
function ENT:SetOverrideColor(color)
  self.overrideColor = color
end

--- Attaches the lock to a door, together with its double door partner if it has one.
--
-- A partner is a door of the same class, model and skin 90 to 100 units away at the same height with a
-- different angle. The lock is removed with the door, and each locked door's `combineLock` field is set
-- to the lock.
--
-- @param entity [Entity The door to lock]
function ENT:SetDoor(entity)
  local position = entity:GetPos()
  local angles = entity:GetAngles()
  local model = entity:GetModel()
  local skin = entity:GetSkin()

  self.entity = entity
  self.entity:DeleteOnRemove(self)
  self.entities = { entity }

  for k, v in ipairs(ents.FindByClass(entity:GetClass())) do
    if self.entity != v then
      if v:GetModel() == model and v:GetSkin() == skin then
        local tempPosition = v:GetPos()
        local distance = tempPosition:Distance(position)

        if distance >= 90 and distance <= 100 then
          if v:GetAngles() != angles then
            if math.floor(tempPosition.z) == math.floor(position.z) then
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

--- Sets the access level a non-Combine player needs a matching `combine_lock_access_*` item for.
-- @param int [Number The access level]
function ENT:SetAccess(int)
  self.access = int
end

--- Sets the Combine rank that `Schema:PlayerHasCombineLockAccess` checks for this lock.
-- @param str [String The rank, or `nil` to let every Combine use the lock]
function ENT:SetCPRank(str)
  self.rank = str
end

--- Locks the lock when it is unlocked and unlocks it when it is locked.
function ENT:Toggle()
  if self:IsLocked() then
    self:Unlock()
  else
    self:Lock()
  end
end

--- Locks and closes the lock's doors and plays a random button sound.
function ENT:Lock()
  self:EmitRandomSound()

  for k, v in ipairs(self.entities) do
    if IsValid(v) then
      v:Fire('Lock', '', 0)
      v:Fire('Close', '', 0)
    end
  end

  self:SetDTBool(0, true)
end

--- Unlocks the lock's doors and plays a random button sound.
function ENT:Unlock()
  self:EmitRandomSound()

  for k, v in ipairs(self.entities) do
    if IsValid(v) then
      v:Fire('Unlock', '', 0)
    end
  end

  self:SetDTBool(0, false)
end

--- Flashes the status light red and plays the denied sound.
-- @param duration [Number How long the light flashes, in seconds]
function ENT:SetFlashDuration(duration)
  self:EmitSound('buttons/combine_button_locked.wav')
  self:SetDTFloat(1, CurTime() + duration)
end

--- Starts the 12 second smoke charge that busts the lock's rotating doors open.
--
-- Does nothing while a charge is already counting down. When the timer ends, each `prop_door_rotating`
-- is busted down with `Schema:BustDownDoor` and a smoke effect plays at the lock.
--
-- @param force [Vector Force applied to the busted doors]
function ENT:ActivateSmokeCharge(force)
  local curTime = CurTime()

  if self:GetDTFloat(0) < curTime then
    self:SetDTFloat(0, curTime + 12)

    timer.Create('smoke_charge_'..self:EntIndex(), 12, 1, function()
      if IsValid(self) then
        for k, v in ipairs(self.entities) do
          if IsValid(v) and string.lower(v:GetClass()) == 'prop_door_rotating' then
            Schema:BustDownDoor(nil, v, force)

            local effectData = EffectData()

            effectData:SetOrigin(self:GetPos())
            effectData:SetScale(0.75)

            util.Effect('cw_effect_smoke', effectData, true, true)
          end
        end
      end
    end)
  end
end

--- Plays one random Combine button sound from the lock and each of its doors.
function ENT:EmitRandomSound()
  local randomSounds = {
    'buttons/combine_button1.wav',
    'buttons/combine_button2.wav',
    'buttons/combine_button3.wav',
    'buttons/combine_button5.wav',
    'buttons/combine_button7.wav'
  }

  local randomSound = randomSounds[math.random(1, #randomSounds)]

  if self.entities then
    for k, v in ipairs(self.entities) do
      if IsValid(v) then
        v:EmitSound(randomSound)
      end
    end
  end

  self:EmitSound(randomSound)
end

--- Plays an explosion effect and impact sound at the lock.
function ENT:Explode()
  local effectData = EffectData()

  effectData:SetStart(self:GetPos())
  effectData:SetOrigin(self:GetPos())
  effectData:SetScale(1)

  util.Effect('Explosion', effectData, true, true)

  self:EmitSound('physics/body/body_medium_impact_soft'..math.random(1, 7)..'.wav')
end

--- Plays the explosion and unlocks the lock's doors.
function ENT:OnRemove()
  self:Explode() self:Unlock()

  if self.entities then
    for k, v in ipairs(self.entities) do
      if IsValid(v) then
        v:Fire('Unlock', '', 0)
      end
    end
  end
end

--- Toggles the lock if the player has access, or flashes it red if they do not.
--
-- Does nothing within 3 seconds of the last use, during a flash or while a smoke charge is counting down.
-- Access is checked with `Schema:PlayerHasCombineLockAccess`; admin faction players always have it.
--
-- @param activator [Player The player using the lock]
function ENT:ToggleWithChecks(activator)
  local curTime = CurTime()

  if !self.nextUse or curTime >= self.nextUse then
    if curTime > self:GetDTFloat(1) then
      if curTime > self:GetDTFloat(0) then
        self.nextUse = curTime + 3

        if !Schema:PlayerHasCombineLockAccess(activator, self.access, self.rank)
        and activator:GetFaction() != FACTION_ADMIN then
          self:SetFlashDuration(3)
        else
          self:Toggle()
        end
      end
    end
  end
end

--- Toggles the lock with access checks when a player uses it while looking at it.
function ENT:Use(activator, caller)
  if activator:IsPlayer() and activator:GetEyeTraceNoCursor().Entity == self then
    self:ToggleWithChecks(activator)
  end
end

--- Subtracts the damage from the lock's health and starts the smoke charge when it reaches 0.
function ENT:OnTakeDamage(damageInfo)
  self:SetHealth(math.max(self:Health() - damageInfo:GetDamage(), 0))

  if self:Health() <= 0 then
    self:ActivateSmokeCharge(damageInfo:GetDamageForce() * 8)
  end
end

--- Blocks every toolgun action on the lock.
-- @return [Boolean Always `false`]
function ENT:CanTool(player, trace, tool)
  return false
end

--- Returns the lock's access level.
-- @return [Number The access level set with `ENT:SetAccess`]
function ENT:GetAccess()
  return self.access
end

--- Returns the Combine rank required by the lock.
-- @return [String The rank, or `nil`]
function ENT:GetCPRank()
  return self.rank
end
