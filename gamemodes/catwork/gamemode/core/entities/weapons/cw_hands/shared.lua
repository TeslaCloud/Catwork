--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

if SERVER then
  AddCSLuaFile('shared.lua')

  SWEP.Weight = 5
  SWEP.AutoSwitchTo = false
  SWEP.AutoSwitchFrom = false

  resource.AddFile('models/weapons/w_fists_t.mdl')

  SWEP.ActivityTranslate = {
    [ACT_HL2MP_GESTURE_RANGE_ATTACK] = ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST,
    [ACT_HL2MP_GESTURE_RELOAD] = ACT_HL2MP_GESTURE_RELOAD_FIST,
    [ACT_HL2MP_WALK_CROUCH] = ACT_HL2MP_WALK_CROUCH_FIST,
    [ACT_HL2MP_IDLE_CROUCH] = ACT_HL2MP_IDLE_CROUCH_FIST,
    [ACT_RANGE_ATTACK1] = ACT_RANGE_ATTACK1,
    [ACT_HL2MP_IDLE] = ACT_HL2MP_IDLE_FIST,
    [ACT_HL2MP_WALK] = ACT_HL2MP_WALK_FIST,
    [ACT_HL2MP_JUMP] = ACT_HL2MP_JUMP_FIST,
    [ACT_HL2MP_RUN] = ACT_HL2MP_RUN_FIST
  }
end

if CLIENT then
  SWEP.PrintName = L('#SWEPS_Hands')
  SWEP.Instructions = L('#SWEPS_Hands_Instructions')
  SWEP.Purpose			= L('#SWEPS_Hands_Purpose')
  SWEP.Author 			= 'Cloud Sixteen'
  SWEP.Contact			= 'CloudSixteen.com'

  SWEP.DrawAmmo = false
  SWEP.DrawCrosshair = false
  SWEP.DrawSecondaryAmmo = false
  SWEP.ViewModelFOV = 55
  SWEP.ViewModelFlip = false
  SWEP.CSMuzzleFlashes = false

  SWEP.Slot = 1
  SWEP.SlotPos = 1
  SWEP.IconLetter = 'j'
end

SWEP.Category				= 'Backsword'

SWEP.HoldType				= 'fist'

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel 				= 'models/weapons/c_arms.mdl'
SWEP.WorldModel 			= ''
SWEP.UseHands = true

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = 2
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = 'none'
SWEP.DrawAmmo = false

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Damage = 100
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ''

SWEP.WallSound 				= Sound('Flesh.ImpactHard')
SWEP.SwingSound				= Sound('WeaponFrag.Throw')
SWEP.HitDistance			= 38
SWEP.LoweredAngles = Angle(0.000, 0.000, -22.000)

/*---------------------------------------------------------
Initialize
---------------------------------------------------------*/

--- Sets the fist hold type.
function SWEP:Initialize()
  self:SetHoldType(self.HoldType)
end

/*---------------------------------------------------------
Deploy
---------------------------------------------------------*/

--- Plays the fists draw animation and delays the first punch by one second.
function SWEP:Deploy()
  local vm = self:GetOwner():GetViewModel()

  vm:SendViewModelMatchingSequence(vm:LookupSequence('fists_draw'))
  self:SetNextPrimaryFire(CurTime() + 1)

  return true
end

/*---------------------------------------------------------
PrimaryAttack
---------------------------------------------------------*/

--- Throws a punch that damages, pushes or knocks out what the owner looks at within 64 units.
--
-- A player left at 30 health or less is knocked out for 15 seconds if `PlayerCanPunchKnockout` allows it.
-- Runs `PlayerCanThrowPunch`, `PlayerCanPunchEntity`, `PlayerPunchEntity`, `PlayerPunchKnockout`,
-- `PlayerPunchThrown` and `PlayerAdjustNextPunchInfo`, which can change the attack delays.
function SWEP:PrimaryAttack()
  if SERVER then
    if hook.Run('PlayerCanThrowPunch', self:GetOwner()) then
      self:PlayPunchAnimation()
      self:GetOwner():SetAnimation(PLAYER_ATTACK1)
      self:SetNextPrimaryFire(CurTime() + 0.5)
      self:SetNextSecondaryFire(CurTime() + 0.7)
      timer.Simple(0.10, function ()self:EmitSound(self.SwingSound) end)
      self.Primary.Damage = self.Primary.Damage
      -- + cw.attributes:Get(self:GetOwner(), ATB_MELEE, nil, true) * 0.03
      -- + cw.attributes:Get(self:GetOwner(), ATB_STRENGTH, nil, true) * 0.03

      local trace = self:GetOwner():GetEyeTraceNoCursor()

      if self:GetOwner():GetShootPos():Distance(trace.HitPos) <= 64 then
        if IsValid(trace.Entity) then
          if trace.Entity:IsPlayer() or trace.Entity:IsNPC() or trace.Entity:GetClass() == 'prop_ragdoll' then
            if trace.Entity:IsPlayer() and trace.Entity:Health() - self.Primary.Damage <= 30
            and hook.Run('PlayerCanPunchKnockout', self:GetOwner(), trace.Entity, trace) then
              cw.player:SetRagdollState(trace.Entity, RAGDOLL_KNOCKEDOUT, 15)
              hook.Run('PlayerPunchKnockout', self:GetOwner(), trace.Entity)
            elseif hook.Run('PlayerCanPunchEntity', self:GetOwner(), trace.Entity) then
              self:PunchEntity()
              hook.Run('PlayerPunchEntity', self:GetOwner(), trace.Entity)
            end

            if trace.Entity:IsPlayer() or trace.Entity:IsNPC() then
              local normal = trace.Entity:GetPos() - self:GetOwner():GetPos()
                normal:Normalize()
              local push = 128 * normal

              trace.Entity:SetVelocity(push)
            end
          elseif IsValid(trace.Entity:GetPhysicsObject()) then
            if hook.Run('PlayerCanPunchEntity', self:GetOwner(), trace.Entity) then
              self:PunchEntity()

              hook.Run('PlayerPunchEntity', self:GetOwner(), trace.Entity)
            end
          elseif trace.Hit then
            self:PunchEntity()
          end
        elseif trace.Hit then
          self:PunchEntity()
        end
      end

      hook.Run('PlayerPunchThrown', self:GetOwner())

      local info = {
        primaryFire = 0.5,
        secondaryFire = 0.5
      }

      hook.Run('PlayerAdjustNextPunchInfo', self:GetOwner(), info)

      self:SetNextPrimaryFire(CurTime() + info.primaryFire)
      self:SetNextSecondaryFire(CurTime() + info.secondaryFire)

      self:GetOwner():ViewPunch(Angle(
        math.Rand(-16, 16), math.Rand(-8, 8), 0
      ))
    end
  end
end

/*---------------------------------------------------------
SecondaryAttack
---------------------------------------------------------*/

--- Knocks on the door the owner looks at within 64 units if `PlayerCanKnockOnDoor` allows it.
--
-- Fires `PlayerKnockOnDoor` afterwards.
function SWEP:SecondaryAttack()
  if SERVER then
    local trace = self:GetOwner():GetEyeTraceNoCursor()

    if IsValid(trace.Entity) and cw.entity:IsDoor(trace.Entity) then
      if self:GetOwner():GetShootPos():Distance(trace.HitPos) <= 64 then
        if hook.Run('PlayerCanKnockOnDoor', self:GetOwner(), trace.Entity) != false then
          self:PlayKnockSound()

          self:SetNextPrimaryFire(CurTime() + 0.25)
          self:SetNextSecondaryFire(CurTime() + 0.25)

          hook.Run('PlayerKnockOnDoor', self:GetOwner(), trace.Entity)
        end
      end
    end
  end
end

/*---------------------------------------------------------
KnockSound
---------------------------------------------------------*/

--- Plays the door knock sound, and on the server also on the owner's client.
function SWEP:PlayKnockSound()
  if SERVER then
    self:CallOnClient('PlayKnockSound', '')
  end

  self:EmitSound('physics/wood/wood_crate_impact_hard2.wav')
end

/*---------------------------------------------------------
Reload
---------------------------------------------------------*/

--- Does nothing; the hands cannot reload.
function SWEP:Reload()
  return false
end

/*---------------------------------------------------------
OnRemove
---------------------------------------------------------*/

--- Allows the hands to be removed.
function SWEP:OnRemove()
  return true
end

/*---------------------------------------------------------
Holster
---------------------------------------------------------*/

--- Allows the hands to be holstered at any time.
function SWEP:Holster()
  return true
end

/*---------------------------------------------------------
ShootEffects
---------------------------------------------------------*/
--- Overridden to show no shooting effects.
function SWEP:ShootEffects() end

/*---------------------------------------------------------
OnDrop
---------------------------------------------------------*/

--- Removes the hands instead of dropping them.
function SWEP:OnDrop()
  self:Remove()
end

/*---------------------------------------------------------
SetupDataTables
---------------------------------------------------------*/

--- Sets up the networked `NextMeleeAttack` and `NextIdle` floats.
function SWEP:SetupDataTables()
  self:NetworkVar('Float', 0, 'NextMeleeAttack')
  self:NetworkVar('Float', 1, 'NextIdle')
end

/*---------------------------------------------------------
UpdateNextIdle
---------------------------------------------------------*/

--- Sets the next idle time to when the current view model sequence ends.
function SWEP:UpdateNextIdle()
  local vm = self:GetOwner():GetViewModel()

  self:SetNextIdle(CurTime() + vm:SequenceDuration())
end

/*---------------------------------------------------------
PunchEntity
---------------------------------------------------------*/

--- Damages the entity in front of the owner within 64 units with a club hit of `Primary.Damage`.
--
-- Plays the hit sound after a short delay. The server also runs it on the owner's client for the sound.
function SWEP:PunchEntity()
  local bounds = Vector(0, 0, 0)
  local startPosition = self:GetOwner():GetShootPos()
  local finishPosition = startPosition + (self:GetOwner():GetAimVector() * 64)
  local traceLineAttack = util.TraceLine({
    start = startPosition,
    endpos = finishPosition,
    filter = self:GetOwner()
  })

  timer.Simple(0.32, function ()
    if IsValid(self) then
      self:EmitSound(self.WallSound)
    end
  end)

  if SERVER then
    self:CallOnClient('PunchEntity', '')

    if IsValid(traceLineAttack.Entity) then
      traceLineAttack.Entity:TakeDamageInfo(
        cw.core:FakeDamageInfo(self.Primary.Damage, self, self:GetOwner(), traceLineAttack.HitPos, DMG_CLUB, 1)
      )
    end
  end
end

/*---------------------------------------------------------
PunchingAnimation
---------------------------------------------------------*/

--- Plays the next punch animation, alternating left and right fists.
--
-- On the server it also runs the animation on the owner's client.
function SWEP:PlayPunchAnimation()
  if SERVER then
    self:CallOnClient('PlayPunchAnimation', '')
  end

  if self.left == nil then self.left = true else self.left = !self.left end

  local anim = 'fists_right'
  local ownerAnim = PLAYER_ATTACK1

  if self.left then
    anim = 'fists_left'
    -- ownerAnim = PLAYER_ATTACK2
  end

  local vm = self:GetOwner():GetViewModel()

  self:GetOwner():SetAnimation(ownerAnim)
  vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))
end
