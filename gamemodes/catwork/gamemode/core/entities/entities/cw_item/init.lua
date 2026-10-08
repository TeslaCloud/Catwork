--- Server side of the `cw_item` entity, an item instance lying in the world.
--
-- `ENT:SetItemTable` binds the entity to an item, taking its model and skin and registering it with
-- `item.AddItemEntity`. The entity has 25 health and passes damage, thinking and removal on to the item's
-- `OnEntityTakeDamage`, `OnEntityThink`, `OnEntityDestroyed` and `OnEntityRemoved` callbacks and the
-- `ItemEntityTakeDamage` and `ItemEntityDestroyed` hooks.

include('shared.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

--- Sets up physics, simple use and 25 health for the item entity.
function ENT:Initialize()
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetUseType(SIMPLE_USE)
  self:SetHealth(25)
  self:SetSolid(SOLID_VPHYSICS)

  local physicsObject = self:GetPhysicsObject()

  if IsValid(physicsObject) then
    physicsObject:Wake()
    physicsObject:EnableMotion(true)
  end
end

--- Always transmits the item entity to every client.
function ENT:UpdateTransmitState()
  return TRANSMIT_ALWAYS
end

--- Returns the item instance the entity represents.
-- @return [Item The item instance, or `nil` before `ENT:SetItemTable` is called]
function ENT:GetItemTable()
  return self.cwItemTable
end

--- Makes the entity represent an item instance.
--
-- Sets the item's model and skin, networks its index, calls the item's `OnCreated(entity)` and registers the
-- entity with `item.AddItemEntity`. Does nothing when `itemTable` is `nil`.
-- @param itemTable [Item The item instance]
function ENT:SetItemTable(itemTable)
  if itemTable then
    self:SetSkin(itemTable.skin or 1)
    self:SetModel(itemTable.model)
    self:SetDTInt(0, itemTable.index)

    if itemTable.OnCreated then
      itemTable:OnCreated(self)
    end

    self.cwItemTable = itemTable

    item.RemoveItemEntity(self)
    item.AddItemEntity(self, itemTable)
  end
end

--- Calls the item's `OnEntityRemoved(entity)` when the entity is removed.
function ENT:OnRemove()
  local itemTable = self.cwItemTable

  if itemTable and itemTable.OnEntityRemoved then
    itemTable:OnEntityRemoved(self)
  end
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

--- Applies damage above 5 to the entity's health and destroys it at zero health.
--
-- The item's `OnEntityTakeDamage` can return `false` to ignore the damage. Fires `ItemEntityTakeDamage` and,
-- when destroyed, the item's `OnEntityDestroyed` and the `ItemEntityDestroyed` hook.
function ENT:OnTakeDamage(damageInfo)
  local itemTable = self.cwItemTable

  if itemTable.OnEntityTakeDamage
  and itemTable:OnEntityTakeDamage(self, damageInfo) == false then
    return
  end

  hook.Run('ItemEntityTakeDamage', self, itemTable, damageInfo)

  if damageInfo:GetDamage() > 5 then
    self:SetHealth(math.max(self:Health() - damageInfo:GetDamage(), 0))

    if self:Health() <= 0 then
      if itemTable.OnEntityDestroyed then
        itemTable:OnEntityDestroyed(self)
      end

      hook.Run('ItemEntityDestroyed', self, itemTable)
      self:Explode()
      self:Remove()
    end
  end
end

--- Removes entities stuck in the world or without an item, and runs the item's `OnEntityThink`.
--
-- `OnEntityThink` may return the number of seconds until the next think; the default is one second.
function ENT:Think()
  local itemTable = self.cwItemTable

  if !self:IsInWorld() then
    timer.Simple(2, function()
      if IsValid(self) then
        local pos = self:GetPos()
        local trace = util.TraceLine({
          start = pos + Vector(0, 0, 16),
          endpos = pos
        })

        if trace and trace.StartSolid then
          self:Remove()
        end
      end
    end)
  end

  if itemTable then
    if itemTable.OnEntityThink then
      local nextThink = itemTable:OnEntityThink(self)

      if isnumber(nextThink) then
        return self:NextThink(CurTime() + nextThink)
      end
    end
  else
    self:Remove()
  end

  self:NextThink(CurTime() + 1)
end
