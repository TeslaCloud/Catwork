--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

include('shared.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

--- Sets up the breach padlock model and physics.
function ENT:Initialize()
  self:SetModel('models/props_wasteland/prison_padlock001a.mdl')

  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetUseType(SIMPLE_USE)
  self:SetSolid(SOLID_VPHYSICS)

  local physicsObject = self:GetPhysicsObject()

  if IsValid(physicsObject) then
    physicsObject:Wake()
    physicsObject:EnableMotion(true)
  end
end

--- Always transmits the breach to every client.
function ENT:UpdateTransmitState()
  return TRANSMIT_ALWAYS
end

--- Spawns a broken padlock prop at the breach that decays after 30 seconds.
function ENT:CreateDummyBreach()
  local entity = ents.Create('prop_physics')

  entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
  entity:SetAngles(self:GetAngles())
  entity:SetModel('models/props_wasteland/prison_padlock001b.mdl')
  entity:SetPos(self:GetPos())

  entity:Spawn()

  if IsValid(entity) then
    cw.entity:Decay(entity, 30)
  end
end

--- Attaches the breach to an entity at the traced hit position.
--
-- The breach is parented to the entity, faces along the hit normal, is removed together with the
-- entity and gets 5 health. The entity's `breach` field is set to the breach.
--
-- @param entity [Entity The door or entity to breach]
-- @param trace [Map Trace result whose `HitPos` and `HitNormal` place the breach]
function ENT:SetBreachEntity(entity, trace)
  local position = trace.HitPos
  local angles = trace.HitNormal:Angle()

  self.entity = entity
  self.entity:DeleteOnRemove(self)

  self:SetPos(position)
  self:SetAngles(angles)
  self:SetParent(entity)

  entity.breach = self self:SetHealth(5)
end

--- Detonates the breach, removes it and fires the `EntityBreached` hook for the attached entity.
-- @param activator [Entity Whoever set off the breach, usually the attacker that destroyed it]
function ENT:BreachEntity(activator)
  self:Explode() self:Remove()

  hook.Run('EntityBreached', self.entity, activator)
end

--- Plays the breach detonation effect and impact sound at the breach position.
function ENT:Explode()
  local effectData = EffectData()

  effectData:SetStart(self:GetPos())
  effectData:SetOrigin(self:GetPos())
  effectData:SetScale(8)

  util.Effect('GlassImpact', effectData, true, true)

  self:EmitSound('physics/body/body_medium_impact_soft'..math.random(1, 7)..'.wav')
end

--- Subtracts the damage from the breach's health and breaches the entity when it reaches 0.
function ENT:OnTakeDamage(damageInfo)
  self:SetHealth(math.max(self:Health() - damageInfo:GetDamage(), 0))

  if self:Health() <= 0 then
    self:CreateDummyBreach()
    self:BreachEntity(damageInfo:GetAttacker())
  end
end
