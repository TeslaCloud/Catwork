--- Defines the `cw_stunstick` weapon, the Civil Protection stun baton.
--
-- Primary fire strikes a player or prop within 96 units for club damage that scales with the owner's strength
-- attribute and runs the `PlayerStunEntity` hook. Secondary fire knocks on a door (`PlayerCanKnockOnDoor`,
-- `PlayerKnockOnDoor`) or pushes whatever is aimed at. The client draws a pulsing glow on the baton while it is
-- raised.

if SERVER then
  AddCSLuaFile('shared.lua')

  cw.core:AddFile('materials/models/weapons/v_stunstick/v_stunstick_diffuse.vmt')
  cw.core:AddFile('materials/models/weapons/v_stunstick/v_stunstick_diffuse.vtf')
  cw.core:AddFile('materials/models/weapons/v_stunstick/v_stunstick_normal.vtf')

  cw.core:AddFile('models/weapons/v_stunstick.dx80.vtx')
  cw.core:AddFile('models/weapons/v_stunstick.dx90.vtx')
  cw.core:AddFile('models/weapons/v_stunstick.sw.vtx')
  cw.core:AddFile('models/weapons/v_stunstick.mdl')
  cw.core:AddFile('models/weapons/v_stunstick.phy')
  cw.core:AddFile('models/weapons/v_stunstick.vvd')
end

if CLIENT then
  SWEP.Slot = 0
  SWEP.SlotPos = 5
  SWEP.DrawAmmo = false
  SWEP.PrintName = '#SWEPS_Stunstick'
  SWEP.DrawCrosshair = true
end

SWEP.Instructions = '#SWEPS_Stunstick_Instructions'
SWEP.Purpose = '#SWEPS_Stunstick_Purpose'
SWEP.Contact = ''
SWEP.Author = 'kurozael'

SWEP.WorldModel = 'models/weapons/w_stunbaton.mdl'
SWEP.ViewModel = 'models/weapons/v_stunstick.mdl'
SWEP.HoldType = 'melee'

SWEP.AdminSpawnable = false
SWEP.Spawnable = false

SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = 10
SWEP.Primary.Delay = 1
SWEP.Primary.Ammo = ''

SWEP.Secondary.NeverRaised = true
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Delay = 1
SWEP.Secondary.Ammo = ''

SWEP.NoIronSightFovChange = true
SWEP.NoIronSightAttack = true
SWEP.IronSightPos = Vector(0, 0, 0)
SWEP.IronSightAng = Vector(0, 0, 0)

if CLIENT then
  SWEP.FirstPersonGlowSprite = Material('sprites/light_glow02_add_noz')
  SWEP.ThirdPersonGlowSprite = Material('sprites/light_glow02_add')
end

-- The view model's spark attachments: `spark1a` to `spark9a`, then `spark1b` to `spark9b`.
local sparkAttachments = {}

for i = 1, 9 do
  sparkAttachments[i] = 'spark'..i..'a'
  sparkAttachments[i + 9] = 'spark'..i..'b'
end

--- Plays the draw animation.
-- @return [Boolean Always `true` to allow the deploy]
function SWEP:Deploy()
  self:SendWeaponAnim(ACT_VM_DRAW)

  return true
end

--- Plays the holster animation.
-- @return [Boolean Always `true` to allow the holster]
function SWEP:Holster(switchingTo)
  self:SendWeaponAnim(ACT_VM_HOLSTER)

  return true
end

--- Sets the melee hold type.
function SWEP:Initialize()
  self:SetHoldType(self.HoldType)
end

--- Plays the door knock sound, mirrored to the owner's client when called on the server.
function SWEP:PlayKnockSound()
  if SERVER then
    self:CallOnClient('PlayKnockSound', '')
  end

  self:EmitSound('physics/wood/wood_crate_impact_hard2.wav')
end

--- Plays the push sound, mirrored to the owner's client when called on the server.
function SWEP:PlayPushSound()
  if SERVER then
    self:CallOnClient('PlayPushSound', '')
  end

  self:EmitSound('weapons/crossbow/hitbod2.wav')
end

--- Plays the swing animation with a spark, flesh hit or impact sound and the stunstick impact effect.
--
-- The effect and hit sounds only play when the owner's eye trace hits something within 96 units;
-- otherwise a swing sound plays.
function SWEP:DoHitEffects()
  local trace = self.Owner:GetEyeTraceNoCursor()

  if (trace.Hit or trace.HitWorld) and self.Owner:GetPos():Distance(trace.HitPos) <= 96 then
    self:EmitSound('weapons/stunstick/spark'..math.random(1, 2)..'.wav')

    if IsValid(trace.Entity) and (trace.Entity:IsPlayer() or trace.Entity:IsNPC()) then
      self:SendWeaponAnim(ACT_VM_MISSCENTER)
      self:EmitSound('weapons/stunstick/stunstick_fleshhit'..math.random(1, 2)..'.wav')
    elseif IsValid(trace.Entity) and cw.entity:GetPlayer(trace.Entity) then
      self:SendWeaponAnim(ACT_VM_MISSCENTER)
      self:EmitSound('weapons/stunstick/stunstick_fleshhit'..math.random(1, 2)..'.wav')
    else
      self:SendWeaponAnim(ACT_VM_MISSCENTER)
      self:EmitSound('weapons/stunstick/stunstick_impact'..math.random(1, 2)..'.wav')
    end

    local effectData = EffectData()

    effectData:SetStart(trace.HitPos)
    effectData:SetOrigin(trace.HitPos)
    effectData:SetNormal(trace.HitNormal)

    if IsValid(trace.Entity) then
      effectData:SetEntity(trace.Entity)
    end

    util.Effect('StunstickImpact', effectData, true, true)
  else
    self:SendWeaponAnim(ACT_VM_MISSCENTER)
    self:EmitSound('weapons/stunstick/stunstick_swing'..math.random(1, 2)..'.wav')
  end
end

--- Plays a spark sound and, for Civil Protection models, the baton deactivation animation.
function SWEP:OnLowered()
  self:EmitSound('weapons/stunstick/spark'..math.random(1, 3)..'.wav')

  if SERVER then
    self:CallOnClient('OnLowered', '')

    if cw.animation:GetModelClass(self.Owner:GetModel()) == 'civilProtection' then
      self.Owner:SetForcedAnimation('deactivatebaton', 1)
    end
  end
end

--- Plays a spark sound and, for Civil Protection models, the baton activation animation.
function SWEP:OnRaised()
  self:EmitSound('weapons/stunstick/spark'..math.random(1, 3)..'.wav')

  if SERVER then
    self:CallOnClient('OnRaised', '')

    if cw.animation:GetModelClass(self.Owner:GetModel()) == 'civilProtection' then
      self.Owner:SetForcedAnimation('activatebaton', 1)
    end
  end
end

--- Draws the stunstick with a pulsing glow at its tip while raised.
function SWEP:DrawWorldModel()
  self:DrawModel()

  if IsValid(self.Owner) and self.Owner:IsWeaponRaised() then
    local attachment = self:GetAttachment(1)
    local curTime = CurTime()
    local scale = math.abs(math.sin(curTime) * 4)
    local alpha = math.abs(math.sin(curTime) / 4)

    self.ThirdPersonGlowSprite:SetFloat('$alpha', 0.7 + alpha)

    if attachment and attachment.Pos then
      cam.Start3D(EyePos(), EyeAngles())
        render.SetMaterial(self.ThirdPersonGlowSprite)
        render.DrawSprite(attachment.Pos, 8 + scale, 8 + scale, color_white)
      cam.End3D()
    end
  end
end

--- Draws the pulsing glow and spark sprites on the view model while raised.
function SWEP:ViewModelDrawn()
  if self.Owner:IsWeaponRaised() then
    if self:IsCarriedByLocalPlayer() then
      local viewModel = cw.client:GetViewModel()

      if IsValid(viewModel) then
        local attachment = viewModel:GetAttachment(viewModel:LookupAttachment('sparkrear'))
        local curTime = CurTime()
        local scale = math.abs(math.sin(curTime) * 4)
        local alpha = math.abs(math.sin(curTime) / 4)

        self.FirstPersonGlowSprite:SetFloat('$alpha', 0.7 + alpha)
        self.ThirdPersonGlowSprite:SetFloat('$alpha', 0.5 + alpha)

        if attachment and attachment.Pos then
          cam.Start3D(EyePos(), EyeAngles())
            render.SetMaterial(self.ThirdPersonGlowSprite)
            render.DrawSprite(attachment.Pos, 8 + scale, 8 + scale, color_white)

            self.FirstPersonGlowSprite:SetFloat('$alpha', 0.5 + alpha)

            for k, v in ipairs(sparkAttachments) do
              local spark = viewModel:GetAttachment(viewModel:LookupAttachment(v))

              if spark and spark.Pos then
                local i = (k - 1) % 9 + 1

                if i == 1 or i == 2 or i == 9 then
                  render.SetMaterial(self.ThirdPersonGlowSprite)
                else
                  render.SetMaterial(self.FirstPersonGlowSprite)
                end

                render.DrawSprite(spark.Pos, 1, 1, color_white)
              end
            end
          cam.End3D()
        end
      end
    end
  end
end

--- Plays the owner's attack animation unless `idle` is set.
-- @param idle=nil [Boolean Whether to skip the attack animation]
function SWEP:DoAnimations(idle)
  if !idle then
    self.Owner:SetAnimation(PLAYER_ATTACK1)
  end
end

--- Strikes whatever the owner aims at within 96 units.
--
-- Players are pushed back and, while above 10 health, take club damage that scales with the owner's
-- strength. Physics props are pushed and take more damage; ragdolled players take the player damage.
-- Fires the `PlayerStunEntity` hook for every hit.
function SWEP:PrimaryAttack()
  self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
  self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

  self:DoAnimations() self:DoHitEffects()

  if SERVER then
    if self.Owner.LagCompensation then
      self.Owner:LagCompensation(true)
    end

    local trace = self.Owner:GetEyeTraceNoCursor()

    if self.Owner:GetShootPos():Distance(trace.HitPos) <= 96 then
      if IsValid(trace.Entity) then
        local player = cw.entity:GetPlayer(trace.Entity)
        local strength = cw.attributes:Fraction(self.Owner, ATB_STRENGTH, 3, 1.5)

        if trace.Entity:IsPlayer() then
          local normal = (trace.Entity:GetPos() - self.Owner:GetPos()):GetNormalized()
          local push = 128 * normal

          trace.Entity:SetVelocity(push)

          if trace.Entity:Health() > 10 then
            trace.Entity:TakeDamageInfo(
              cw.core:FakeDamageInfo(1 + strength, self, self.Owner, trace.HitPos, DMG_CLUB, 2)
            )
          end

          hook.Run('PlayerStunEntity', self.Owner, trace.Entity)
        elseif IsValid(trace.Entity:GetPhysicsObject()) then
          trace.Entity:GetPhysicsObject():ApplyForceOffset(self.Owner:GetAimVector() * 256, trace.HitPos)

          if !player or player:Health() > 10 then
            if !player then
              trace.Entity:TakeDamageInfo(
                cw.core:FakeDamageInfo(5 + (strength * 2), self, self.Owner, trace.HitPos, DMG_CLUB, 2)
              )
            else
              trace.Entity:TakeDamageInfo(
                cw.core:FakeDamageInfo(1 + strength, self, self.Owner, trace.HitPos, DMG_CLUB, 2)
              )
            end
          end

          hook.Run('PlayerStunEntity', self.Owner, trace.Entity)
        end
      end
    end

    if self.Owner.LagCompensation then
      self.Owner:LagCompensation(false)
    end
  end
end

--- Knocks on a door within 64 units or pushes the player, NPC or prop being aimed at within 96 units.
--
-- Knocking needs the `PlayerCanKnockOnDoor` hook to allow it and fires `PlayerKnockOnDoor`. Pushing plays
-- the Civil Protection push animation for those models.
function SWEP:SecondaryAttack()
  if SERVER then
    if self.Owner.LagCompensation then
      self.Owner:LagCompensation(true)
    end

    local trace = self.Owner:GetEyeTraceNoCursor()

    if self.Owner:GetShootPos():Distance(trace.HitPos) <= 96 then
      if IsValid(trace.Entity) then
        if self.Owner:GetShootPos():Distance(trace.HitPos) <= 64 and cw.entity:IsDoor(trace.Entity) then
          self:SetNextPrimaryFire(CurTime() + 0.25)
          self:SetNextSecondaryFire(CurTime() + 0.25)

          if hook.Run('PlayerCanKnockOnDoor', self.Owner, trace.Entity) then
            self:PlayKnockSound()

            hook.Run('PlayerKnockOnDoor', self.Owner, trace.Entity)
          end
        else
          self:PlayPushSound()

          self:SetNextPrimaryFire(CurTime() + 0.5)
          self:SetNextSecondaryFire(CurTime() + 0.5)

          if cw.animation:GetModelClass(self.Owner:GetModel()) == 'civilProtection' then
            self.Owner:SetForcedAnimation('pushplayer', 1)
          end

          if trace.Entity:IsPlayer() or trace.Entity:IsNPC() then
            if self.Owner:GetPos():Distance(trace.HitPos) <= 96 then
              local normal = (trace.Entity:GetPos() - self.Owner:GetPos()):GetNormalized()
              local push = 256 * normal

              trace.Entity:SetVelocity(push)
            end
          elseif IsValid(trace.Entity:GetPhysicsObject()) then
            trace.Entity:GetPhysicsObject():ApplyForceOffset(self.Owner:GetAimVector() * 256, trace.HitPos)
          end
        end
      end
    end

    if self.Owner.LagCompensation then
      self.Owner:LagCompensation(false)
    end
  end
end
