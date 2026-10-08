--- Server side of the `cw_combineaccessmonitor` entity of the Combine Devices plugin, a small Combine monitor that
-- displays three lines of text and an access level.
--
-- `SetStatus` switches it between normal (0), destroyed (1) and error (2). It has 1 health, so any damage destroys the
-- screen with sparks and broken glass.

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
  self:SetDTInt(5, int)
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

    effect = EffectData()
    effect:SetOrigin(self:GetPos() + self:GetForward() * 13 + self:GetUp() * 10)
    effect:SetNormal(self:GetForward())
    effect:SetRadius(10)
    effect:SetMagnitude(0)
    effect:SetScale(1)
    util.Effect('cball_bounce', effect)
  end
end
