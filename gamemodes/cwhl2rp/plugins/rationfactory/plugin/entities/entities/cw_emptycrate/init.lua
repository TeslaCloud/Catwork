--- Server side of the `cw_emptycrate` entity of the Ration Factory plugin, a crate that collects finished ration
-- packets.
--
-- A full `cw_emptyration` that touches it is packed in, at most one per second; at ten the crate turns into a shipment
-- of ten `ration_standard` items. It has 50 health and breaks when it runs out.
--
-- Originally written for the Iron Wall community.

include('shared.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

--- Sets up the empty crate with 50 health and no rations inside.
function ENT:Initialize()
  self:SetModel('models/Items/item_item_crate.mdl')

  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetUseType(SIMPLE_USE)
  self:SetHealth(50)
  self:SetSolid(SOLID_VPHYSICS)

  self:SetDTInt(1, 0)
  self:SetDTBool(2, false)

  self.breens_water = item.FindByID('breens_water')
  self.citizen_supplements = item.FindByID('citizen_supplements')

  local physicsObject = self:GetPhysicsObject()

  if IsValid(physicsObject) then
    physicsObject:Wake()
    physicsObject:EnableMotion(true)
  end
end

--- Plays the effect and sound of the crate breaking apart.
function ENT:Explode()
  local effectData = EffectData()

  effectData:SetStart(self:GetPos())
  effectData:SetOrigin(self:GetPos())
  effectData:SetScale(8)

  util.Effect('GlassImpact', effectData, true, true)

  self:EmitSound('physics/body/body_medium_impact_soft'..math.random(1, 7)..'.wav')
end

--- Makes the crate always transmit to clients.
function ENT:UpdateTransmitState()
  return TRANSMIT_ALWAYS
end

--- Takes damage off the crate's health and breaks it when the health runs out.
function ENT:OnTakeDamage(damageInfo)
  self:SetHealth(math.max(self:Health() - damageInfo:GetDamage(), 0))

  if self:Health() <= 0 then
    self:Explode() self:Remove()
  end
end

--- Packs a touching full `cw_emptyration` into the crate, at most one per second.
--
-- At ten rations the crate turns into a shipment of ten `ration_standard` items.
function ENT:Touch(ent)
  if IsValid(ent) and ent:GetClass() == 'cw_emptyration' and (self.nextadd or 0) <= CurTime() then
    if ent:GetDTBool(3) then
      ent:Remove()
      self:EmitSound('items/medshot4.wav')
      self:SetDTInt(1, self:GetDTInt(1) + 1)
      self.nextadd = CurTime() + 1

      if self:GetDTInt(1) >= 10 then
        cw.entity:CreateShipment(nil, 'ration_standard', 10, self:GetPos(), self:GetAngles())
        self:Remove()
      end
    end
  end
end

--- Flags the crate full once it holds ten rations.
function ENT:CheckFull()
  if self:GetDTInt(1) >= 10 then
    self:SetDTBool(2, true)
  end
end
