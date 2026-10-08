--- Server side of the `cw_emptyration` entity of the Ration Factory plugin, an empty ration packet that players fill.
--
-- It absorbs a `breens_water` and a `citizen_supplements` item entity that touch it and is marked full once it holds
-- both, ready to be packed into a `cw_emptycrate`. It has 25 health and breaks when it runs out.
--
-- Originally written for the Iron Wall community.

include('shared.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

--- Sets up the empty ration packet with 25 health and nothing inside.
function ENT:Initialize()
  self:SetModel('models/weapons/w_package.mdl')

  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetUseType(SIMPLE_USE)
  self:SetHealth(25)
  self:SetSolid(SOLID_VPHYSICS)

  self:SetDTBool(1, false)
  self:SetDTBool(2, false)
  self:SetDTBool(3, false)

  self.breens_water = item.FindByID('breens_water')
  self.citizen_supplements = item.FindByID('citizen_supplements')

  local physicsObject = self:GetPhysicsObject()

  if IsValid(physicsObject) then
    physicsObject:Wake()
    physicsObject:EnableMotion(true)
  end
end

--- Plays the effect and sound of the packet breaking apart.
function ENT:Explode()
  local effectData = EffectData()

  effectData:SetStart(self:GetPos())
  effectData:SetOrigin(self:GetPos())
  effectData:SetScale(8)

  util.Effect('GlassImpact', effectData, true, true)

  self:EmitSound('physics/body/body_medium_impact_soft'..math.random(1, 7)..'.wav')
end

--- Makes the packet always transmit to clients.
function ENT:UpdateTransmitState()
  return TRANSMIT_ALWAYS
end

--- Takes damage off the packet's health and breaks it when the health runs out.
function ENT:OnTakeDamage(damageInfo)
  self:SetHealth(math.max(self:Health() - damageInfo:GetDamage(), 0))

  if self:Health() <= 0 then
    self:Explode() self:Remove()
  end
end

--- Absorbs a touching `breens_water` or `citizen_supplements` item entity the packet still lacks.
--
-- The item is flagged as it is absorbed: it only disappears at the end of the tick, and could fill a second packet
-- that touches it until then.
function ENT:Touch(ent)
  if !self:GetDTBool(2) or !self:GetDTBool(1) then
    if IsValid(ent) and ent:GetClass() == 'cw_item' and !ent.cwFactoryUsed then
      local index = ent:GetDTInt(0)

      if index != 0 then
        local findedItem = item.FindByID(index)

        if findedItem == self.citizen_supplements or findedItem == self.breens_water then
          if findedItem == self.citizen_supplements then
            if !self:GetDTBool(2) then
              self:SetDTBool(2, true)
              ent.cwFactoryUsed = true
              ent:Remove()
              self:EmitSound('items/medshot4.wav')
            end
          else
            if !self:GetDTBool(1) then
              self:SetDTBool(1, true)
              ent.cwFactoryUsed = true
              ent:Remove()
              self:EmitSound('items/medshot4.wav')
            end
          end

          self:CheckFull()
        end
      end
    end
  end
end

--- Marks the packet full once it holds both the water and the supplements.
function ENT:CheckFull()
  if self:GetDTBool(2) and self:GetDTBool(1) then
    self:SetDTBool(3, true)
  end
end
