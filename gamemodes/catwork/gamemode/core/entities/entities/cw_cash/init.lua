--- Server side of the `cw_cash` entity, an amount of cash lying in the world.
--
-- The model comes from the `model_cash` option and `ENT:SetAmount` sets and networks the amount. The entity has 25
-- health and removes itself when it ends up outside the world.

include('shared.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

--- Sets the cash model from the `model_cash` option and sets up debris physics, simple use and 25 health.
function ENT:Initialize()
  self:SetModel(cw.option:GetKey('model_cash'))
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetUseType(SIMPLE_USE)
  self:SetHealth(25)
  self:SetSolid(SOLID_VPHYSICS)
  self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

  local physicsObject = self:GetPhysicsObject()

  if IsValid(physicsObject) then
    physicsObject:Wake()
    physicsObject:EnableMotion(true)
  end
end

--- Removes the cash once a second check finds it outside the world.
function ENT:Think()
  self:NextThink(CurTime() + 1)

  if !self:IsInWorld() then
    self:Remove()
  end
end

--- Always transmits the cash entity to every client.
function ENT:UpdateTransmitState()
  return TRANSMIT_ALWAYS
end

--- Sets the amount of cash the entity holds and networks it to clients.
-- @param amount [Number The cash amount]
function ENT:SetAmount(amount)
  self.cwAmount = amount
  self:SetDTInt(0, amount)
end

--- Plays a glass impact effect and a soft impact sound at the entity's position.
function ENT:Explode()
  local effectData = EffectData()
    effectData:SetStart(self:GetPos())
    effectData:SetOrigin(self:GetPos())
    effectData:SetScale(8)
  util.Effect('GlassImpact', effectData, true, true)

  self:EmitSound('physics/body/body_medium_impact_soft'..math.random(1, 7)..'.wav')
end

--- Subtracts the damage from the cash entity's health and destroys it at zero health.
function ENT:OnTakeDamage(damageInfo)
  self:SetHealth(math.max(self:Health() - damageInfo:GetDamage(), 0))

  if self:Health() <= 0 then
    self:Explode() self:Remove()
  end
end
