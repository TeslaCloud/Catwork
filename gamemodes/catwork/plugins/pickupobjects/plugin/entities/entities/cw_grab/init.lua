--- Server-side code of the `cw_grab` entity, the invisible physics handle that the Pickup Objects plugin welds a
-- carried entity to.
--
-- The grab moves towards its compute position with shadow control, asks `cwPickupObjects:CalculatePosition` for a new
-- position 20 times a second, and drops the entity once the player can no longer hold it.

util.Include('shared.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

--- Sets up the grab as a heavy, non-solid physics object for the shadow controller.
function ENT:Initialize()
  self:SetModel('models/weapons/w_bugbait.mdl')
  self:SetSolid(SOLID_NONE)
  self:PhysicsInit(SOLID_BBOX)
  self:SetMoveType(MOVETYPE_VPHYSICS)

  self.cwComputePos = Vector(0, 0, 0)
  self._player = NULL

  local physicsObject = self:GetPhysicsObject()

  if IsValid(physicsObject) then
    physicsObject:SetMass(2048)
    physicsObject:Wake()
  end
end

--- Does nothing; the grab cannot be used.
function ENT:Use(activator, caller) end

local think_rate = 1 / 20

--- Updates the held entity's position 20 times a second, and drops it or removes the grab once the
-- player can no longer hold it.
function ENT:Think()
  if IsValid(self._player) and IsValid(self.cwTargetEnt) and cwPickupObjects then
    if !cwPickupObjects:CalculatePosition(self._player) then
      cwPickupObjects:ForceDropEntity(self._player)
    end
  else
    self:Remove()
  end

  self:NextThink(CurTime() + think_rate)

  return true
end

--- Sets the position the grab moves towards.
-- @param position [Vector The target position]
function ENT:SetComputePosition(position)
  self.cwComputePos = position
end

--- Sets the player holding the grab.
-- @param player [Player The holding player]
function ENT:SetPlayer(player)
  self._player = player
end

--- Sets the entity the grab is carrying.
-- @param target [Entity The held entity]
function ENT:SetTarget(target)
  self.cwTargetEnt = target
end

--- Moves the grab towards its compute position with shadow control and keeps the held entity awake.
function ENT:PhysicsSimulate(physicsObject, deltaTime)
  if IsValid(self.cwTargetEnt) then
    local targetPhysicsObject = self.cwTargetEnt:GetPhysicsObject()

    if IsValid(targetPhysicsObject) then
      targetPhysicsObject:Wake()
    end
  end

  physicsObject:Wake()
  physicsObject:ComputeShadowControl({
    secondstoarrive = 0.01,
    teleportdistance = 128,
    maxangulardamp = 10000,
    maxspeeddamp = 10000,
    dampfactor = 0.8,
    deltatime = deltaTime,
    maxangular = 512,
    maxspeed = 256,
    angle = self:GetAngles(),
    pos = self.cwComputePos
  })
end
