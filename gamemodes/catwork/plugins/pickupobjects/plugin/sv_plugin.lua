--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

config.Add('take_physcannon', true)

--- Drops the entity a player is holding and throws it in the direction they aim.
-- @param player [Player The player throwing]
function cwPickupObjects:ForceThrowEntity(player)
  local entity = self:ForceDropEntity(player)
  local force = player:GetAimVector() * 768

  timer.Simple(FrameTime() * 0.5, function()
    if IsValid(entity) and IsValid(player) then
      local physicsObject = entity:GetPhysicsObject()

      if IsValid(physicsObject) then
        physicsObject:ApplyForceCenter(force)
      end
    end
  end)
end

--- Makes a player drop the entity they are holding.
--
-- Removes the grab entity and restores the entity's collision group when `prop_kill_protection` is on.
-- With that config on, the dropped entity deals no damage for a minute; a dropped ragdoll also takes no
-- damage for a second. The player cannot punch for a second afterwards.
-- @param player [Player The player dropping]
-- @return [Entity The entity that was held, or `nil` when the player held nothing]
function cwPickupObjects:ForceDropEntity(player)
  local holdingGrab = player.cwHoldingGrab
  local curTime = CurTime()
  local entity = player.cwHoldingEnt

  if IsValid(holdingGrab) then
    constraint.RemoveAll(holdingGrab)
    holdingGrab:Remove()
  end

  if IsValid(entity) then
    entity.cwNextTakeDmg = curTime + 1
    entity.cwHoldingGrab = nil

    if config.Get('prop_kill_protection'):Get()
    and entity.cwLastCollideGroup then
      cw.entity:ReturnCollisionGroup(
        entity, entity.cwLastCollideGroup
      )

      entity.cwLastCollideGroup = nil
    end

    entity.cwDamageImmunity = CurTime() + 60
  end

  if player.cwHoldingEnt then
    player:EmitSound('physics/body/body_medium_impact_soft'..math.random(1, 7)..'.wav')
  end

  player.nextPunchTime = curTime + 1
  player.cwHoldingEnt = nil
  player.cwHoldingGrab = nil

  return entity
end

--- Makes a player pick up an entity with the hands, dropping anything they already held.
--
-- Spawns an invisible `cw_grab` entity at the trace hit position and welds the entity to it; the grab
-- then follows the player's aim. With `prop_kill_protection` on, the entity is switched to
-- `COLLISION_GROUP_WEAPON` while held.
-- @param player [Player The player picking up]
-- @param entity [Entity The entity to pick up]
-- @param trace [Map The trace that hit the entity; `HitPos` and `PhysicsBone` are used]
function cwPickupObjects:ForcePickup(player, entity, trace)
  self:ForceDropEntity(player)

  player.cwHoldingGrab = ents.Create('cw_grab')
  player.cwHoldingGrab:SetOwner(player)
  player.cwHoldingGrab:SetPos(trace.HitPos)
  player.cwHoldingGrab:Spawn()

  player.cwHoldingGrab:StartMotionController()
  player.cwHoldingGrab:SetComputePosition(trace.HitPos)
  player.cwHoldingGrab:SetPlayer(player)
  player.cwHoldingGrab:SetTarget(entity)

  player.cwHoldingEnt = entity
  player.cwHoldingGrab:SetCollisionGroup(COLLISION_GROUP_WORLD)
  player.cwHoldingGrab:SetNotSolid(true)
  player.cwHoldingGrab:SetNoDraw(true)

  player.cwHoldingAngles = entity:GetAngles()
  player.cwOriginalEyeAngles = player:EyeAngles()

  entity.cwHoldingGrab = player.cwHoldingGrab

  if config.Get('prop_kill_protection'):Get()
  and !entity.cwLastCollideGroup then
    cw.entity:StopCollisionGroupRestore(entity)
    entity.cwLastCollideGroup = entity:GetCollisionGroup()
    entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
  end

  player:EmitSound('physics/body/body_medium_impact_soft'..math.random(1, 7)..'.wav')

  if entity:GetClass() == 'prop_ragdoll' then
    constraint.Weld(entity, player.cwHoldingGrab, trace.PhysicsBone, 0, 0)
  else
    constraint.Weld(entity, player.cwHoldingGrab, 0, 0, 0)
  end
end

--- Moves a player's grab entity to where the held entity should be, in front of their aim.
--
-- The distance grows while the player walks forward, and sprinting backwards pulls the entity close.
-- @param player [Player The player holding the entity]
-- @return [Boolean `true` when the position was updated, `nil` when the player can no longer hold it]
function cwPickupObjects:CalculatePosition(player)
  local holdingGrab = player.cwHoldingGrab
  local curTime = CurTime()
  local entity = player.cwHoldingEnt

  if IsValid(entity) and IsValid(holdingGrab) and player:Alive() and !player:IsRagdolled() then
    if player:IsUsingHands() then
      local shootPosition = player:GetShootPos()
      local isRagdoll = entity:GetClass() == 'prop_ragdoll'
      local filter = { holdingGrab, entity, player }
      local length = 32 + entity:BoundingRadius()
      local entAngles = entity:GetAngles()
      local oldAngles = player.cwHoldingAngles
      local eyeAngles = player:EyeAngles()
      local oldEyeAngles = player.cwOriginalEyeAngles
      local diff = eyeAngles.y - oldEyeAngles.y

      holdingGrab:SetAngles(Angle(entAngles.x, oldAngles.y + diff, oldAngles.z))

      if isRagdoll then
        length = 0
      end

      if player:KeyDown(IN_FORWARD) then
        length = length + (player:GetVelocity():Length() / 2)
      elseif player:KeyDown(IN_BACK) and player:KeyDown(IN_SPEED) then
        length = -16
      end

      local trace = util.TraceLine({
        start = shootPosition,
        endpos = shootPosition + (player:GetAimVector() * length),
        filter = filter
      })

      holdingGrab:SetComputePosition(trace.HitPos - holdingGrab:OBBCenter())

      if entity:GetClass() == 'prop_ragdoll' then
        holdingGrab.cwComputePos.z = math.min(holdingGrab.cwComputePos.z, shootPosition.z - 32)
      else
        holdingGrab.cwComputePos.z = math.min(holdingGrab.cwComputePos.z, shootPosition.z + 8)
      end

      return true
    end
  end
end
