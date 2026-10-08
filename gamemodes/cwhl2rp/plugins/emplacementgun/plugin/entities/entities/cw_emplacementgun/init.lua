-- All credit for the emplacement gun entity goes to Zaubermuffin and his/her affiliates.
-- His/her steam profile: http://steamcommunity.com/id/zaubermuffin

-- ZAR3
-- Copyright (c) 2012 Zaubermuffin
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
-- documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
-- rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
-- Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
-- WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
-- COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--
-- Based on the original Bouncy Ball.
--
-- Note: Here's a lot of code commented out - for a reason.
-- The whole "aiming at crosshair position" is horribly broken and I'm not in a mood to do mathematical thinking what
-- would be correct - I ported the C++ code from func_tank and
-- used the data from the sdk_d2_coast12.vmf that also features one of these AR3s - however, it was horribly broken even
-- afterwards with little to zero improvement.
-- In addition, the flashlight is kind-of-buggy - but a certain someone just wanted me to release this, so take it.

--- Server side of the `cw_emplacementgun` entity of the Emplacement Gun plugin, a mounted pulse gun on a Combine
-- barricade that a Combine player takes over with the use key, aims with their view and fires.
--
-- `ENT:SpawnFunction` and `ENT:SpawnProp` mount the gun on a barricade prop, `ENT:TakeOver` and `ENT:Abandon` set and
-- release the controller, and `ENT:Think` fires bullets while the `zar3_attack` console command holds attack. The
-- controller's flashlight key toggles the gun's spotlight instead. A gun has one operator at a time: the controller, or
-- the player it is still starting up for (`PendingController`).

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

util.AddNetworkString('ZAR3_S')

-- square of the maximum distance we can move away from the AR3 before we leave it automatically.
local MAX_DISTANCE = 6000
local SPREAD = Vector(0.025, 0.025, 0)
local SHOT_INTERVAL = 0.05
-- Seconds between two toggles of the spotlight, which creates and removes entities.
local FLASHLIGHT_INTERVAL = 0.5

-- Import the function and remove the global.
local FindAR3At, AR3Position = ZAR3_FindAR3At, ZAR3_AR3Position
ZAR3_FindAR3At, ZAR3_AR3Position = nil, nil

--- Spawns a frozen Combine barricade under the gun and parents the gun to it.
--
-- Removing the barricade removes the gun. Used when restoring saved guns.
function ENT:SpawnProp()
  local ent = ents.Create('prop_physics')
  ent:SetModel('models/props_combine/combine_barricade_short01a.mdl')
  -- The reverse of AR3Position, so that the gun sits where it does on a barricade it was spawned on.
  ent:SetPos(self:GetPos() - self:GetUp() * 10 + self:GetForward() * 4)
  ent:SetAngles(self:GetAngles())
  self:SetParent(ent)
  ent:Spawn()
  ent:DropToFloor()
  ent:DeleteOnRemove(self)

  if IsValid(ent:GetPhysicsObject()) then
    ent:GetPhysicsObject():EnableMotion(false)
  end
end

--- Spawns a gun on the barricade the player is looking at, or on a new frozen barricade.
--
-- Refuses, with a chat message, when the barricade already has a gun.
--
-- @param ply [Player The player spawning the gun]
-- @param tr [Map The player's eye trace; `tr.Entity` is replaced by a new barricade if needed]
-- @return [Entity The new barricade when one was created, otherwise the gun; `nil` on failure]
function ENT:SpawnFunction(ply, tr)
  -- Whenever THAT can happen...
  if !tr.Hit then
    return
  end

  -- What we have to return (i.e. for the undo)
  local clamped = false

  -- If we weren't spawned "on a clamp", create one.
  if !IsValid(tr.Entity) or tr.Entity:GetModel() != 'models/props_combine/combine_barricade_short01a.mdl' then
    -- Spawn the clamp.
    local ent = ents.Create('prop_physics')
    ent:SetModel('models/props_combine/combine_barricade_short01a.mdl')
    ent:SetPos(tr.HitPos + Vector(0, 0, 48))
    ent:SetAngles(Angle(0, math.NormalizeAngle(ply:EyeAngles().yaw - 180), 0))
    ent:Spawn()
    ent:DropToFloor()

    -- Freeze it.
    if IsValid(ent:GetPhysicsObject()) then
      ent:GetPhysicsObject():EnableMotion(false)
    end

    tr.Entity = ent

    clamped = true
  end

  -- :lazy:
  local clamp = tr.Entity

  if FindAR3At(clamp) then
    ply:PrintMessage(bit.bor(HUD_PRINTCONSOLE, HUD_PRINTTALK), "Cannot spawn AR3 (there's already one).")
    return
  end

  -- Create the AR3.
  local ent = ents.Create('cw_emplacementgun')
  ent:SetPos(AR3Position(clamp))
  ent:SetAngles(clamp:GetAngles())
  ent:SetParent(clamp) -- parent it to the clamp.
  ent:Spawn()
  ent:Activate()

  clamp:DeleteOnRemove(ent)
  return clamped and clamp or ent
end

--- Sets the bunker gun model and shadow physics, centres the barrel and starts the motion controller.
function ENT:Initialize()
  self:SetModel('models/props_combine/bunker_gun01.mdl')
  self:SetMoveType(MOVETYPE_NONE)
  self:SetSolid(SOLID_VPHYSICS)
  self:PhysicsInitShadow(false, false)
  self.NextShot = 0 -- when we can fire our next bullet - used in Think.
  self:SetUseType(SIMPLE_USE)

  local phys = self:GetPhysicsObject()

  if phys:IsValid() then
    phys:Wake()
  end

-- ~ 	self.LocPos = Vector(0, 0, 0)
  self.LocAng = Angle(0, 0, 0)
  self.LocAngVel = Angle(0, 0, 0)

-- ~ 	local attach = self:GetAttachment(self:LookupAttachment('aimrotation'))
-- ~ 	self.LocPos = attach.Pos
-- ~ 	self.LocAng = attach.Ang

  self:SetPoseParameter('aim_yaw', 0)
  self:SetPoseParameter('aim_pitch', 0)

-- ~ 	local localAngles = Angle(7.5, 0, 0)
-- ~ 	self.LocAng = localAngles
-- ~
-- ~ 	self.m_yawCenter = self.LocAng.yaw
-- ~ 	self.m_pitchCenter = self.LocAng.pitch

  self:ResetSequence('idle_inactive')
  self:StartMotionController()
end

--- Fires the gun while its controller holds attack and releases it when they die, fall over, walk away or leave.
--
-- Shoots an AR2 tracer bullet for 26 damage every 0.05 seconds, credited to the controller.
-- Thinks every frame.
--
-- @return [Boolean `true`, so the next think time is used]
function ENT:Think()
  local controller = self.Controller

  if controller != nil and !IsValid(controller) then
    -- The controller disconnected; without this the gun would keep its state for the next player.
    self:Abandon()
  elseif controller != nil then
-- ~ 		self:TrackTarget()
    local phys = self:GetPhysicsObject()

    if IsValid(phys) then
      phys:Wake()
    end

    if !controller:Alive() or controller:IsRagdolled()
    or (controller:GetPos() - self:GetPos()):LengthSqr() > MAX_DISTANCE then
      self:Abandon()
    elseif CurTime() > self.NextShot and self.Shooting then
      local muzzleTach = self:LookupAttachment('muzzle')
      local attach = self:GetAttachment(muzzleTach)
      local bullet = {}
        bullet.Num = 1
        bullet.Src = attach.Pos
        bullet.Dir = attach.Ang:Forward()
        bullet.Spread = SPREAD
        bullet.Tracer = 1
        bullet.TracerName = 'AR2Tracer'
        bullet.Force = 20
        bullet.Damage = 26
        bullet.Attacker = self.Controller
      self:FireBullets(bullet)

      local effd = EffectData()
        effd:SetEntity(self)
        effd:SetAngles(attach.Ang)
        effd:SetOrigin(attach.Pos + attach.Ang:Forward() * 5)
        effd:SetScale(1)
        effd:SetAttachment(muzzleTach)
        effd:SetFlags(5) -- MUZZLEFLASH_COMBINE or so.
      util.Effect('MuzzleFlash', effd)

      self:EmitSound('Weapon_FuncTank.Single')
      self.NextShot = CurTime() + SHOT_INTERVAL
      self:ResetSequence('fire')
    end
  end

  self:NextThink(CurTime())
  return true
end

--- Makes a player the gun's controller.
--
-- Plays the activate sequence, turns the player's flashlight off and tells their client with
-- the `ZAR3_S` net message to hide the view model and send attacks to the gun. The player
-- becomes the controller once the sequence ends, and is the gun's `PendingController` until
-- then. Does nothing when the gun is in use or starting up, or the player already controls a gun.
--
-- @param ply [Player The player taking over]
function ENT:TakeOver(ply)
  -- If we already control one or the new player does, abort.
  if IsValid(self.Controller) or IsValid(self.PendingController) or IsValid(ply.ZAR3) then
    return
  end

  self:EmitSound('Func_Tank.BeginUse')

-- ~ 	-- Enable our flashlight if his is enabled.
-- ~ 	if ply:FlashlightIsOn() and not self.FlashlightOn then
-- ~ 		self[ply:FlashlightIsOn() and 'EnableFlashlight' or 'DisableFlashlight'](self)
-- ~ 	end

  -- Disable his flashlight.
  ply:Flashlight(false)

  -- Get the sequence.
  local seq, dur = self:LookupSequence('activate')
  -- Play it.
  self:ResetSequence(seq)

  -- As soon as the sequence is over, set our controller - if he's still here.
  timer.Simple(dur, function()
    if !IsValid(self) or self.PendingController != ply then
      return
    end

    self.PendingController = nil

    if IsValid(ply) and ply.ZAR3 == self then
      self.Controller = ply
    else
      self:Abandon()
    end
  end)

  -- Avoid shooting during boot.
  self.NextShot = CurTime() + dur
  self.Shooting = false
  self.PendingController = ply

  -- Inform the client.
  net.Start('ZAR3_S')
    net.WriteEntity(self)
  net.Send(ply)

  -- Wake us up afterwards - might be necessary.
  timer.Simple(
    dur,
    function() if IsValid(self) and IsValid(self:GetPhysicsObject()) then self:GetPhysicsObject():Wake() end end
  )
  ply.ZAR3 = self
end

--- Lets a Combine player take over the gun, or leave it when they already control it.
--
-- Non-Combine players are told the gun will not move.
function ENT:Use(activator, caller)
  if !IsValid(activator) or !activator:IsPlayer() then
    return
  end

  -- Too far away? We don't care.
  if (activator:GetPos() - self:GetPos()):LengthSqr() > MAX_DISTANCE then
    return
  end

  if !Schema:PlayerIsCombine(activator) then
    cw.player:Notify(activator, L('Emplacement_WontMove'))
    return
  end

  -- If we have a controller...
  if IsValid(self.Controller) then
    -- and the same controller tried to activate us...
    if self.Controller == activator then
      -- o7
      self:Abandon()
    end

    return
  end

  self:TakeOver(activator)
end

--- Releases the gun's controller, or the player it is starting up for, and retracts the gun.
--
-- Tells the player's client with `ZAR3_S` to restore their controls, stops shooting and
-- centres the barrel.
function ENT:Abandon()
  local ply = IsValid(self.Controller) and self.Controller or self.PendingController

  self:ResetSequence('retract')
  -- Send the net message to the player to reset his controls.
  if IsValid(ply) then
    net.Start('ZAR3_S')
      net.WriteEntity(NULL)
    net.Send(ply)

    ply.ZAR3 = nil
  end

  self.Controller = nil
  self.PendingController = nil
  self.Shooting = false

  self:SetPoseParameter('aim_yaw', 0)
  self:SetPoseParameter('aim_pitch', 0)
  self.LocAng = Angle(0, 0, 0)

  local phys = self:GetPhysicsObject()

  if IsValid(phys) then
    phys:Sleep()
  end
end

--- Turns the gun's spotlight on, creating it and its projected texture if needed.
function ENT:EnableFlashlight()
  if !IsValid(self.Flashlight) then
    self:CreateFlashlight()
  end

  if !IsValid(self.FlashlightFocus) then
    local lightAttach = self:LookupAttachment('light')
    local attach = self:GetAttachment(lightAttach)

    local flashlight = ents.Create('env_projectedtexture')
      flashlight:SetPos(attach.Pos)
      flashlight:SetAngles(attach.Ang)
      flashlight:SetKeyValue('enableshadows', '1')
      flashlight:SetKeyValue('farz', '2048')
      flashlight:SetKeyValue('nearz', '8')
      flashlight:SetKeyValue('lightfov', '23')
      flashlight:SetKeyValue('lightcolor', '147 226 240')
    flashlight:Spawn()
    flashlight:Fire('SpotlightTexture', 'effects/flashlight001')
    flashlight:SetParent(self)
    flashlight:Fire('SetParentAttachment', 'light')

    self.FlashlightFocus = flashlight
  end

  self.Flashlight:Fire('LightOn')
  self.FlashlightOn = true
end

local function FindCone(ent, retry)
  if !IsValid(ent) or !IsValid(ent.Flashlight) then
    if retry < 10 then
      timer.Simple(1, function() FindCone(ent, retry + 1) end)
    end

    return
  end

  for k, v in pairs(ents.FindByClass('spotlight_end')) do
    if v:GetOwner() == ent.Flashlight then
      ent.FlashlightCone = v
      return
    end
  end

  if retry < 10 then
    timer.Simple(1, function() FindCone(ent, retry + 1) end)
  end
end

--- Creates the gun's spotlight, switched off, if it does not exist.
--
-- Searches for the spotlight's cone entity afterwards so it can be removed with the gun.
function ENT:CreateFlashlight()
  if !IsValid(self.Flashlight) then
    local lightAttach = self:LookupAttachment('light')
    local attach = self:GetAttachment(lightAttach)

    -- point_spotlight:
    local flashlight = ents.Create('point_spotlight')
      flashlight:SetPos(attach.Pos)
      flashlight:SetAngles(attach.Ang)
      flashlight:SetKeyValue('maxdxlevel', '0')
      flashlight:SetKeyValue('mindxlevel', '0')
      flashlight:SetKeyValue('rendermode', '0')
      flashlight:SetKeyValue('disablereceivershadows', '0')
      flashlight:SetKeyValue('renderfx', '0')
-- ~ 			flashlight:SetKeyValue('targetname', self:GetName() .. '_spotlight')
      flashlight:SetKeyValue('HDRColorScale', '1.0')
      flashlight:SetKeyValue('spotlightwidth', '70')
      flashlight:SetKeyValue('renderamt', '255')
      flashlight:SetKeyValue('spotlightlength', '2048')
      flashlight:SetKeyValue('rendercolor', '147 226 240')
      flashlight:SetKeyValue('spawnflags', '0')
    flashlight:Spawn()

    flashlight:SetParent(self)
    flashlight:Fire('SetParentAttachment', 'light')

    -- Search for our cone later.
    timer.Simple(0, function() FindCone(self, 0) end)
    self.Flashlight = flashlight
    self.FlashlightOn = false
  end
end

--- Turns the gun's spotlight off and removes its projected texture.
function ENT:DisableFlashlight()
  if IsValid(self.Flashlight) then
    self.Flashlight:Fire('LightOff')
    self.FlashlightOn = false
  end

  if IsValid(self.FlashlightFocus) then
    self.FlashlightFocus:Remove()
  end
end

--- Turns the stored barrel angles up to 5 degrees towards the controller's crosshair.
--
-- A port of `CFuncTank::TrackTarget` from the Source SDK. Unused: its call in `ENT:Think`
-- is commented out because the crosshair aiming does not work.
function ENT:TrackTarget()
  local angles = self:AimBarrelAtPlayerCrosshair()

  -- Approach!
  local currentAngles = self.LocAng -- Angle(self:GetPoseParameter('aim_yaw'), self:GetPoseParameter('aim_pitch'), 0)

-- ~ 	self.LocAng.yaw = (angles.yaw + currentAngles.yaw)/2
-- ~ 	self.LocAng.pitch = (angles.pitch + currentAngles.pitch)/2
  local yawDiff = math.Clamp(math.AngleDifference(angles.yaw, currentAngles.yaw), -5, 5)
  local pitchDiff = math.Clamp(math.AngleDifference(angles.pitch, currentAngles.pitch), -5, 5)

  self.LocAng.yaw = math.NormalizeAngle(currentAngles.yaw + yawDiff)
  self.LocAng.pitch = math.NormalizeAngle(currentAngles.pitch + pitchDiff)

-- ~ 	self.Controller:PrintMessage(HUD_PRINTCENTER, string.format('%3.f - %.3f => %.3f; set to %.3f == %.3f',
-- ~ 	currentAngles.yaw, angles.yaw, yawDiff, math.NormalizeAngle(currentAngles.yaw + yawDiff), self.LocAng.yaw))

  --[["Official" way.
  self:RotateTankToAngles(angles)
  -- Half-official - we're not a real rotating thing, so
  self.LocAng.pitch = self.LocAng.pitch + self.LocAngVel.pitch/100
  self.LocAng.yaw = self.LocAng.yaw + self.LocAngVel.yaw/100
  --]]
end

--- Returns the position the controller's crosshair points at, up to 8192 units away.
--
-- A port of `CFuncTank::CalcPlayerCrosshairTarget` from the Source SDK.
--
-- @return [Vector The hit position]
function ENT:CalcPlayerCrosshairTarget()
  -- // Get the player.
  -- CBasePlayer *pPlayer = static_cast<CBasePlayer*>(m_hController.Get())
  local player = self.Controller

  -- // Tank aims at player's crosshair.
  -- Vector vecStart, vecDir
  local vecStart, vecDir

  -- trace_t	tr
  local tr

  -- vecStart = pPlayer->EyePosition()
  vecStart = player:EyePos()

  -- if (!IsXbox())
  -- (assumed to be true)
  -- vecDir = pPlayer->EyeDirection3D()
  vecDir = player:GetAimVector()

  -- // Make sure to start the trace outside of the player's bbox!
  -- UTIL_TraceLine(vecStart + vecDir * 24, vecStart + vecDir * 8192, MASK_OPAQUE_AND_NPCS, this, COLLISION_GROUP_NONE,
  -- &tr)
  tr = util.TraceLine({
    start = vecStart + vecDir * 24,
    endpos = vecStart + vecDir * 8192,
    mask = MASK_OPAQUE_AND_NPCS,
    filter = { self, player, self:GetParent() }
  })

  -- *pVecTarget = tr.endpos
  return tr.HitPos
end

--- Returns the barrel angles that aim at the controller's crosshair.
--
-- A port of `CFuncTank::AimBarrelAtPlayerCrosshair` from the Source SDK.
--
-- @return [Angle The local barrel angles]
function ENT:AimBarrelAtPlayerCrosshair()
  -- CalcPlayerCrosshairTarget(&vecTarget)
  local vecTarget = self:CalcPlayerCrosshairTarget()

  -- *pAngles = AimBarrelAt(m_parentMatrix.WorldToLocal(vecTarget))
  return self:AimBarrelAt(self:WorldToLocal(vecTarget))
end

-- Copied from a vmf

--- Returns the barrel angles that aim the offset barrel at a local position.
--
-- A port of `CFuncTank::AimBarrelAt` from the Source SDK, with the barrel offset taken from
-- a map file.
--
-- @param parentTarget [Vector The target, local to the gun]
-- @return [Angle The local barrel angles]
function ENT:AimBarrelAt(parentTarget)
-- ~ 	local m_barrelPos = Vector(31, 0, 8)
  local m_barrelPos = Vector(20.8, 0, 18.15)

-- ~ 	local m_barrelPos = self:LocalToWorld(m_barrelPos)

  -- Vector target = parentTarget - GetLocalOrigin()
  local target = parentTarget - self:WorldToLocal(self:GetAttachment(self:LookupAttachment('aimrotation')).Pos)

  -- float quadTarget = target.LengthSqr()
  local quadTarget = target:LengthSqr()
  -- float quadTargetXY = target.x*target.x + target.y*target.y
  quadTargetXY = target.x * target.x + target.y * target.y

  -- // Target is too close!  Can't aim at it
  -- if (quadTarget <= m_barrelPos.LengthSqr())
-- ~ 	if quadTarget <= m_barrelPos:LengthSqr() then
    -- return GetLocalAngles();
-- ~ 		return Angle(self:GetPoseParameter('aim_pitch'), self:GetPoseParameter('aim_yaw'), 0)
  -- else
-- ~ 	else
  -- // We're trying to aim the offset barrel at an arbitrary point.
  -- // To calculate this, I think of the target as being on a sphere with
  -- // it's center at the origin of the gun.
  -- // The rotation we need is the opposite of the rotation that moves the target
  -- // along the surface of that sphere to intersect with the gun's shooting direction
  -- // To calculate that rotation, we simply calculate the intersection of the ray
  -- // coming out of the barrel with the target sphere (that's the new target position)
  -- // and use atan2() to get angles
  --
  -- // angles from target pos to center
  -- float targetToCenterYaw = atan2(target.y, target.x)
  local targetToCenterYaw = math.atan2(target.y, target.x)
  -- float centerToGunYaw = atan2(m_barrelPos.y, sqrt(quadTarget - (m_barrelPos.y*m_barrelPos.y)))
  local centerToGunYaw = math.atan2(m_barrelPos.y, math.sqrt(quadTarget - (m_barrelPos.y * m_barrelPos.y)))
  -- float targetToCenterPitch = atan2(target.z, sqrt(quadTargetXY))
  local targetToCenterPitch = math.atan2(target.z, math.sqrt(quadTargetXY))
  -- float centerToGunPitch = atan2(-m_barrelPos.z, sqrt(quadTarget - (m_barrelPos.z*m_barrelPos.z)))
  local centerToGunPitch = math.atan2(-m_barrelPos.z, math.sqrt(quadTarget - (m_barrelPos.z * m_barrelPos.z)))
    -- return QAngle(-RAD2DEG(targetToCenterPitch+centerToGunPitch), RAD2DEG(targetToCenterYaw + centerToGunYaw), 0)

-- ~ 		self.Controller:PrintMessage(HUD_PRINTCENTER, string.format('%.3f - %.3f | %.3f - %.3f', targetToCenterYaw,
-- ~ 		centerToGunYaw, targetToCenterPitch, centerToGunPitch))
  return Angle(
    math.NormalizeAngle(-math.Rad2Deg(targetToCenterPitch + centerToGunPitch)),
    math.NormalizeAngle(math.Rad2Deg(targetToCenterYaw + centerToGunYaw)),
    0
  )
-- ~ 	end
end

-- Stuff that is supposedly set in the model; we can assume it's 0/0 for our cause
local m_yawCenter, m_pitchCenter = 0, 7.5
-- Stuff that is set in the vmf - we just copied it.
local m_yawRange, m_yawTolerance = 60, 15
local m_pitchRange, m_pitchTolerance = 60, 15
local m_yawRate, m_pitchRate = 200, 120

--- Sets the gun's stored angular velocity towards the given angles, within its turn range.
--
-- A port of `CFuncTank::RotateTankToAngles` from the Source SDK. Unused.
--
-- @param angles [Angle The angles to turn to]
-- @return [Boolean Whether the angles were clamped to the gun's range]
function ENT:RotateTankToAngles(angles)
-- ~ 	local m_yawCenter = self.m_yawCenter
-- ~ 	local m_pitchCenter = self.m_pitchCenter
  -- bool bClamped = false
  local bClamped = false

  -- // Force the angles to be relative to the center position
  -- float offsetY = UTIL_AngleDistance(angles.y, m_yawCenter)
  local offsetY = math.AngleDifference(angles.yaw, m_yawCenter)
  -- float offsetX = UTIL_AngleDistance(angles.x, m_pitchCenter)
  local offsetX = math.AngleDifference(angles.pitch, m_pitchCenter)

  -- float flActualYaw = m_yawCenter + offsetY
  local flActualYaw = m_yawCenter + offsetY
  -- float flActualPitch = m_pitchCenter + offsetX
  local flActualPitch = m_pitchCenter + offsetX

  -- if ((fabs(offsetY) > m_yawRange + m_yawTolerance) ||
  -- 	(fabs(offsetX) > m_pitchRange + m_pitchTolerance))
  if (math.abs(offsetY) > m_yawRange + m_yawTolerance) or (math.abs(offsetX) > m_pitchRange + m_pitchTolerance) then
    -- // Limit against range in x
    -- flActualYaw = clamp(flActualYaw, m_yawCenter - m_yawRange, m_yawCenter + m_yawRange)
    flActualYaw = math.Clamp(flActualYaw, m_yawCenter - m_yawRange, m_yawCenter + m_yawRange)
    -- flActualPitch = clamp(flActualPitch, m_pitchCenter - m_pitchRange, m_pitchCenter + m_pitchRange)
    flActualPitch = math.Clamp(flActualPitch, m_pitchCenter - m_pitchRange, m_pitchCenter + m_pitchRange)
    -- bClamped = true
    bClamped = true
  end

  -- // Get at the angular vel
  -- QAngle vecAngVel = GetLocalAngularVelocity()
  local vecAngVel = self.LocAngVel

  -- // Move toward target at rate or less
  -- float distY = UTIL_AngleDistance(flActualYaw, GetLocalAngles().y)
  local distY = math.AngleDifference(flActualYaw, self:GetPoseParameter('aim_yaw'))
  -- vecAngVel.y = distY * 10
  vecAngVel.yaw = distY * 10
  -- vecAngVel.y = clamp(vecAngVel.y, -m_yawRate, m_yawRate)
  vecAngVel.yaw = math.Clamp(vecAngVel.yaw, -m_yawRate, m_yawRate)

  -- // Move toward target at rate or less
  -- float distX = UTIL_AngleDistance(flActualPitch, GetLocalAngles().x)
  local distX = math.AngleDifference(flActualPitch, self:GetPoseParameter('aim_pitch'))
  -- vecAngVel.x = distX  * 10;
  vecAngVel.pitch = distX * 10
  -- vecAngVel.x = clamp(vecAngVel.x, -m_pitchRate, m_pitchRate)
  vecAngVel.pitch = math.Clamp(vecAngVel.pitch, -m_pitchRate, m_pitchRate)

  -- // How exciting! We're done
  -- SetLocalAngularVelocity(vecAngVel)
  self.LocAngVel = vecAngVel

  -- if (pDistX && pDistY)
  -- {
    -- *pDistX = distX
    -- *pDistY = distY
  -- }

  -- return bClamped
  return bClamped
end

-- ]==]--

--- Turns the barrel towards the controller's view, a few degrees per tick.
--
-- The pose parameters are set here because the Source `func_tank` does the same in its
-- physics simulation. Yaw is limited to 60 degrees each way and pitch to -35 to 50.
--
-- @return [Number `SIM_NOTHING`]
function ENT:PhysicsSimulate()
  if !IsValid(self) or !IsValid(self.Controller) then
    return SIM_NOTHING
  end

  --[[The "official" way. It isn't exactly working as in HL2, but "close enough".
  local angles = self.LocAng

  self:SetPoseParameter('aim_yaw', math.Clamp(math.NormalizeAngle(angles.yaw), -60, 60))
  self:SetPoseParameter('aim_pitch', math.Clamp(math.NormalizeAngle(angles.pitch), -35, 50))

  --]] -- /official way.

-- ~ 	--[[Cheap way - but "works".

-- ~ 	self:SetPoseParameter('aim_yaw', ZAR_ANG2.yaw)
-- ~ 	self:SetPoseParameter('aim_pitch', ZAR_ANG2.pitch)
  local newAngles = self.Controller:EyeAngles()
  newAngles.pitch = math.NormalizeAngle(newAngles.pitch - self:GetAngles().pitch)
  newAngles.yaw = math.NormalizeAngle(newAngles.yaw - self:GetAngles().yaw)

  local angles = Angle(self:GetPoseParameter('aim_pitch'), self:GetPoseParameter('aim_yaw'), 0)

  -- "Smoothen" out the movement by limiting its velocity.
  local newPitch = math.Clamp(math.AngleDifference(newAngles.pitch + 7, angles.pitch), -1, 1)
  local newYaw = math.Clamp(math.AngleDifference(newAngles.yaw, angles.yaw), -2, 2)

  self:SetPoseParameter('aim_yaw', math.Clamp(math.NormalizeAngle(angles.yaw + newYaw), -60, 60))
  self:SetPoseParameter('aim_pitch', math.Clamp(math.NormalizeAngle(angles.pitch + newPitch), -35, 50))

  -- ]]-- /cheap way.

  return SIM_NOTHING
end

--- Removes the gun's spotlight and cone and releases its controller.
function ENT:OnRemove()
  -- Try to find the cone one last time/first time, depending on the PoV.
  FindCone(self, 10)

  self:DisableFlashlight()

  -- Get rid of our controller.
  if IsValid(self.Controller) or IsValid(self.PendingController) then
    self:Abandon()
  end

  if IsValid(self.FlashlightCone) then
    self.FlashlightCone:Remove()
  end
end

local function Attack(ply, cmd, args)
  if !IsValid(ply.ZAR3) then
    return
  end

  ply.ZAR3.Shooting = args[1] == '1'
end

concommand.Add('zar3_attack', Attack)

-- A little something something - we simply override the normal flashlight.
local function PlayerSwitchFlashlight(ply, on)
  local gun = ply.ZAR3

  if IsValid(gun) then
    local curTime = CurTime()

    if !gun.NextFlashlight or curTime >= gun.NextFlashlight then
      gun.NextFlashlight = curTime + FLASHLIGHT_INTERVAL
      gun[(gun.FlashlightOn and 'Disable' or 'Enable')..'Flashlight'](gun)
    end

    return false
  end
end

hook.Add('PlayerSwitchFlashlight', '_ZAR3PlayerSwitchFlashlight', PlayerSwitchFlashlight)

local function PhysgunDrop(ply, ent)
  if IsValid(ent) and ent.ZAR3NoCollided then
    local phys = ent:GetPhysicsObject()

    if IsValid(phys) then
      phys:EnableMotion(false)
    end
  end
end

hook.Add('PhysgunDrop', '_ZAR3PhysgunDrop', PhysgunDrop)
