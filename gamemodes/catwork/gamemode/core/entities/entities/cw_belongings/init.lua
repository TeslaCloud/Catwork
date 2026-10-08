--- Server side of the `cw_belongings` entity, a suitcase that holds an inventory of items and an amount of cash.
--
-- `ENT:SetData` stores the contents, which the gamemode's entity menu handling opens as storage. The suitcase has 50
-- health, and whatever it still holds is dropped into the world when it is destroyed or removed.

include('shared.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

--- Sets up physics, simple use and 50 health for the belongings.
function ENT:Initialize()
  self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetUseType(SIMPLE_USE)
  self:SetHealth(50)
  self:SetSolid(SOLID_VPHYSICS)

  local physicsObject = self:GetPhysicsObject()

  if IsValid(physicsObject) then
    physicsObject:Wake()
    physicsObject:EnableMotion(true)
  end
end

--- Always transmits the belongings to every client.
function ENT:UpdateTransmitState()
  return TRANSMIT_ALWAYS
end

--- Sets the suitcase model and stores the inventory and cash the belongings hold.
--
-- The contents are dropped into the world when the entity is removed (see `ENT:OnRemove`).
-- @param inventory [Inventory The items to keep in the belongings]
-- @param cash [Number The amount of cash to keep in the belongings]
function ENT:SetData(inventory, cash)
  self:SetModel('models/weapons/w_suitcase_passenger.mdl')
  self.cwInventory = inventory
  self.cwCash = cash
end

--- Plays a glass impact effect and a soft impact sound at the entity's position.
-- @param scale=nil [Number Unused; the effect scale is always 8]
function ENT:Explode(scale)
  local effectData = EffectData()
    effectData:SetStart(self:GetPos())
    effectData:SetOrigin(self:GetPos())
    effectData:SetScale(8)
  util.Effect('GlassImpact', effectData, true, true)

  self:EmitSound('physics/body/body_medium_impact_soft'..math.random(1, 7)..'.wav')
end

--- Subtracts the damage from the belongings' health and destroys them at zero health.
function ENT:OnTakeDamage(damageInfo)
  self:SetHealth(math.max(self:Health() - damageInfo:GetDamage(), 0))

  if self:Health() <= 0 then
    self:Explode() self:Remove()
  end
end

--- Drops the stored items and cash into the world, unless the server is shutting down.
function ENT:OnRemove()
  if !cw.core:IsShuttingDown() then
    cw.entity:DropItemsAndCash(self.cwInventory, self.cwCash, self:GetPos(), self)
    self.cwInventory = nil
    self.cwCash = nil
  end
end
