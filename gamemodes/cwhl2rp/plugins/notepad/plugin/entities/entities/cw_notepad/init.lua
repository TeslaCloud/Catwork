--[[
  © 2012 CloudSixteen.com do not share, re-distribute or modify
  without permission of its author (kurozael@gmail.com).
--]]

include('shared.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

--- Sets the clipboard model and physics and gives the notepad 25 health.
function ENT:Initialize()
  self:SetModel('models/props_lab/clipboard.mdl')

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

--- Returns `TRANSMIT_ALWAYS`, so the notepad is networked to every client.
--
-- @return [Number `TRANSMIT_ALWAYS`]
function ENT:UpdateTransmitState()
  return TRANSMIT_ALWAYS
end

--- Plays the effect and sound of the notepad being destroyed.
function ENT:Explode()
  local effectData = EffectData()

  effectData:SetStart(self:GetPos())
  effectData:SetOrigin(self:GetPos())
  effectData:SetScale(8)

  util.Effect('GlassImpact', effectData, true, true)

  self:EmitSound('physics/body/body_medium_impact_soft'..math.random(1, 7)..'.wav')
end

--- Subtracts the damage from the notepad's health and destroys it at 0.
function ENT:OnTakeDamage(damageInfo)
  self:SetHealth(math.max(self:Health() - damageInfo:GetDamage(), 0))

  if self:Health() <= 0 then
    self:Explode() self:Remove()
  end
end

--- Sets the notepad's text and marks it as written.
--
-- The text's CRC becomes the notepad's `uniqueID`, which clients use to cache it. Does
-- nothing when `text` is `nil`.
--
-- @param text [String The new text]
function ENT:SetText(text)
  if text then
    self.text = text
    self.uniqueID = util.CRC(text)
    self:SetDTBool(0, true)
  end
end
