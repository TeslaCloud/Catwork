--[[
  © 2013 CloudSixteen.com do not share, re-distribute or modify
  without permission of its author (kurozael@gmail.com).
--]]

include('shared.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

--- Sets the small Combine monitor model and physics, with 1 health and the normal status.
function ENT:Initialize()
  self:SetModel('models/props_combine/combine_smallmonitor001.mdl')

  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetUseType(SIMPLE_USE)
  self:SetHealth(1)
  self:SetSolid(SOLID_VPHYSICS)

  /*
  self.glow = ents.Create("env_sprite")
  self.glow:SetKeyValue("model","glow06.vmt")
  self.glow:SetKeyValue("rendermode","9")
  self.glow:SetKeyValue("renderalpha","0")
  self.glow:SetKeyValue("scale","0.8")
  self.glow:SetPos(self:GetPos() + self:GetForward() * 12 + self:GetUp() * 10)
  self.glow:SetParent(self)
  self.glow:Spawn()
  self.glow:Activate()
  */

  local physicsObject = self:GetPhysicsObject()

  if IsValid(physicsObject) then
    physicsObject:Wake()
    physicsObject:EnableMotion(true)
  end

  self:SetStatus(0)
end

--- Returns `TRANSMIT_ALWAYS`, so the monitor is networked to every client.
--
-- @return [Number `TRANSMIT_ALWAYS`]
function ENT:UpdateTransmitState()
  return TRANSMIT_ALWAYS
end

--- Sets the monitor's status in the networked int 5.
--
-- @param int [Number 0 for normal, 1 for destroyed (screen off) or 2 for the flashing error screen]
function ENT:SetStatus(int)
  // if int == 0 then
  //	self.glow:SetKeyValue("rendercolor","96 190 255")
  // elseif int == 1 then
  //	self.glow:SetKeyValue("rendercolor","0 0 0")
  // elseif int == 2 then
  //	self.glow:SetKeyValue("rendercolor","255 0 0")
  // end
  // self.glow:SetKeyValue("renderalpha","0")

  self:SetDTInt(5, int)
end

--- Thinks every 0.1 seconds without doing anything else.
function ENT:Think()
  self:NextThink(CurTime() + 0.1)
end

--- Allows every tool on the monitor.
--
-- @return [Boolean Always `true`]
function ENT:CanTool(player, trace, tool)
  return true
end

--- Destroys the monitor's screen with sparks and broken glass once its health runs out.
function ENT:OnTakeDamage(damageInfo)
  if self:GetDTInt(5) == 1 then return end

  self:SetHealth(math.max(self:Health() - damageInfo:GetDamage(), 0))

  if self:Health() <= 0 then
    self:SetStatus(1)

    sound.Play('ambient/energy/zap'..math.random(1, 3)..'.wav', self:GetPos(), 70, 100, 1)
    sound.Play('physics/glass/glass_impact_bullet'..math.random(1, 4)..'.wav', self:GetPos(), 70, 100, 1)

    local effect = EffectData()
    effect:SetOrigin(self:GetPos() + self:GetForward() * 16 + self:GetUp() * 10)
    util.Effect('GlassImpact', effect)

    local effect = EffectData()
    effect:SetOrigin(self:GetPos() + self:GetForward() * 13 + self:GetUp() * 10)
    effect:SetNormal(self:GetForward())
    effect:SetRadius(10)
    effect:SetMagnitude(0)
    effect:SetScale(1)
    util.Effect('cball_bounce', effect)
  end
end

--- Does nothing; the glow sprite it would remove is disabled.
function ENT:OnRemove()
  // self.glow:Remove()
end
