--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

include('shared.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

--- Sets up the book's physics and gives it 25 health.
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

--- Returns `TRANSMIT_ALWAYS`, so the book is networked to every client.
--
-- @return [Number `TRANSMIT_ALWAYS`]
function ENT:UpdateTransmitState()
  return TRANSMIT_ALWAYS
end

--- Plays the effect and sound of the book being destroyed.
function ENT:Explode()
  local effectData = EffectData()

  effectData:SetStart(self:GetPos())
  effectData:SetOrigin(self:GetPos())
  effectData:SetScale(8)

  util.Effect('GlassImpact', effectData, true, true)

  self:EmitSound('physics/body/body_medium_impact_soft'..math.random(1, 7)..'.wav')
end

--- Subtracts the damage from the book's health and destroys it at 0.
function ENT:OnTakeDamage(damageInfo)
  self:SetHealth(math.max(self:Health() - damageInfo:GetDamage(), 0))

  if self:Health() <= 0 then
    self:Explode() self:Remove()
  end
end

--- Sets which book item the entity is, taking the item's model and skin.
--
-- Networks the item's index in the int 0 data table variable. Does nothing when no item
-- matches.
--
-- @param book [String The book item's unique ID]
function ENT:SetBook(book)
  local itemTable = item.FindByID(book)

  if itemTable then
    self.book = itemTable

    if itemTable.skin then
      self:SetModel(itemTable.model)
      self:SetSkin(itemTable.skin)
    else
      self:SetModel(itemTable.model)
    end

    self:SetDTInt(0, itemTable.index)
  end
end
