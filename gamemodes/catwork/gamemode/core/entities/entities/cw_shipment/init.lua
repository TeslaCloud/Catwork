--- Server side of the `cw_shipment` entity, a crate holding a batch of instances of one item.
--
-- `ENT:SetItemTable` fills it and takes the model from the item's `shipmentModel` or the `model_shipment` option. The
-- crate has 50 health and drops the items it still holds into the world when it is destroyed or removed.

include('shared.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

--- Sets up physics, simple use and 50 health for the shipment.
function ENT:Initialize()
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

--- Removes the shipment once a second check finds it outside the world.
function ENT:Think()
  self:NextThink(CurTime() + 1)

  if !self:IsInWorld() then
    self:Remove()
  end

  return true
end

--- Always transmits the shipment to every client.
function ENT:UpdateTransmitState()
  return TRANSMIT_ALWAYS
end

--- Fills the shipment with new instances of an item and sets its model, weight and space.
--
-- Uses the item's `shipmentModel`, or the `model_shipment` option. Does nothing for an unknown item.
-- @param uniqueID [String The unique ID of the item to ship]
-- @param batch [Number How many instances to put in the shipment]
function ENT:SetItemTable(uniqueID, batch)
  local itemTable = item.FindByID(uniqueID)

  if itemTable then
    self.cwWeight = itemTable.weight * batch
    self.cwSpace = itemTable.space * batch
    self.cwItemTable = itemTable
    self.cwInventory = {}

    for i = 1, batch do
      cw.inventory:AddInstance(
        self.cwInventory, item.CreateInstance(uniqueID)
      )
    end

    self:SetModel(itemTable.shipmentModel or cw.option:GetKey('model_shipment'))
    self:SetDTInt(0, itemTable.index)
  end
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

--- Subtracts the damage from the shipment's health and destroys it at zero health.
function ENT:OnTakeDamage(damageInfo)
  self:SetHealth(math.max(self:Health() - damageInfo:GetDamage(), 0))

  if self:Health() <= 0 then
    self:Explode() self:Remove()
  end
end

--- Drops the shipment's items into the world, unless the server is shutting down.
function ENT:OnRemove()
  if !cw.core:IsShuttingDown() and self.cwInventory then
    cw.entity:DropItemsAndCash(self.cwInventory, nil, self:GetPos(), self)
    self.cwInventory = nil
  end
end
