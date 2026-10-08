--- Server side of the `cw_radio` entity, the stationary radio placed from an item.
--
-- It keeps the item it came from, a networked frequency (`ENT:SetFrequency`) and an off state (`ENT:SetOff`,
-- `ENT:Toggle`). The radio has 25 health and is removed with an impact effect when destroyed.

include('shared.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

--- Sets up the citizen radio model, physics and 25 health.
function ENT:Initialize()
  self:SetModel('models/props_lab/citizenradio.mdl')
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

--- Always transmits the radio to every client.
function ENT:UpdateTransmitState()
  return TRANSMIT_ALWAYS
end

--- Returns the item the radio was placed from.
-- @return [Item The item set with `ENT:SetItemTable`, or `nil`]
function ENT:GetItemTable()
  return self.cwItemTable
end

--- Sets the item the radio was placed from.
-- @param itemTable [Item The stationary radio item]
function ENT:SetItemTable(itemTable)
  self.cwItemTable = itemTable
end

--- Plays a glass impact effect and impact sound at the radio.
function ENT:Explode()
  local effectData = EffectData()

  effectData:SetStart(self:GetPos())
  effectData:SetOrigin(self:GetPos())
  effectData:SetScale(8)

  util.Effect('GlassImpact', effectData, true, true)

  self:EmitSound('physics/body/body_medium_impact_soft'..math.random(1, 7)..'.wav')
end

--- Subtracts the damage from the radio's health and destroys it when it reaches 0.
function ENT:OnTakeDamage(damageInfo)
  -- Several hits can land in the tick the radio breaks, before it is actually removed.
  if self.destroyed then return end

  self:SetHealth(math.max(self:Health() - damageInfo:GetDamage(), 0))

  if self:Health() <= 0 then
    self.destroyed = true

    self:Explode() self:Remove()
  end
end

--- Sets the frequency the radio is tuned to, networked to every client.
-- @param frequency [String The frequency, such as `101.1`]
function ENT:SetFrequency(frequency)
  self:SetNWString('frequency', frequency)
end

--- Turns the radio off or on.
-- @param off [Boolean Whether the radio is off]
function ENT:SetOff(off)
  self:SetDTBool(0, off)
end

--- Turns the radio on when it is off and off when it is on.
function ENT:Toggle()
  if self:IsOff() then
    self:SetOff(false)
  else
    self:SetOff(true)
  end
end
