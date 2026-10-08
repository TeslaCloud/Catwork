--- Defines the `cw_keys` weapon, which locks the entity the owner looks at with primary fire and unlocks it with
-- secondary fire.
--
-- The `PlayerGetLockInfo` and `PlayerGetUnlockInfo` hooks supply the duration and the callback that does the work, and
-- `PlayerCanLockEntity` or `PlayerCanUnlockEntity` must keep allowing the action, within 192 units, until the timed
-- `lock` or `unlock` action ends.

if SERVER then
  AddCSLuaFile('shared.lua')

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
  SWEP.Slot = 5
  SWEP.SlotPos = 2
  SWEP.DrawAmmo = false
  SWEP.DrawCrosshair = false
  SWEP.PrintName = L('#SWEPS_Keys')
end

SWEP.Instructions = L('#SWEPS_Keys_Instructions')
SWEP.Purpose 				= L('#SWEPS_Keys_Purpose')
SWEP.Contact 				= 'Cloudsixteen.com'
SWEP.Author = 'Cloudsixteen'

SWEP.WorldModel 			= ''
SWEP.ViewModel 				= 'models/weapons/c_arms.mdl'
SWEP.HoldType = 'fist'

SWEP.AdminSpawnable = false
SWEP.Spawnable = false

SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = 1
SWEP.Primary.Ammo = ''

SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Ammo = ''

SWEP.NoIronSightFovChange = true
SWEP.NoIronSightAttack = true
SWEP.IronSightPos 			= Vector(0, 0, 0)
SWEP.IronSightAng 			= Vector(0, 0, 0)
SWEP.NeverRaised = true
SWEP.LoweredAngles = Angle(0.000, 0.000, -22.000)

--[[Bunch of key functionality bullshit.]] --

--- Plays the fists draw animation.
function SWEP:Deploy()
  local vm = self:GetOwner():GetViewModel()
  vm:SendViewModelMatchingSequence(vm:LookupSequence('fists_draw'))

  return true
end

--- Plays the holster animation and allows the keys to be holstered.
function SWEP:Holster(switchingTo)
  self:SendWeaponAnim(ACT_VM_HOLSTER)
  return true
end

--- Starts locking the entity the owner looks at within 192 units.
--
-- `PlayerGetLockInfo` supplies the lock duration, callback and sound flag; `PlayerCanLockEntity` must allow it
-- and keep allowing it until the timer ends.
function SWEP:PrimaryAttack()
  self:SetNextPrimaryFire(CurTime() + 1)

  if SERVER then
    local action = cw.player:GetAction(self:GetOwner())
    local trace = self:GetOwner():GetEyeTraceNoCursor()

    if self:GetOwner():GetPos():Distance(trace.HitPos) > 192
    or !IsValid(trace.Entity) then
      return
    end

    local info = hook.Run('PlayerGetLockInfo', self:GetOwner(), trace.Entity)

    if info and hook.Run('PlayerCanLockEntity', self:GetOwner(), trace.Entity) then
      local isNotUnlocking = (action != 'unlock')
      local isNotLocking = (action != 'lock')

      if isNotLocking or isNotUnlocking then
        cw.player:SetAction(self:GetOwner(), 'lock', info.duration)
        cw.player:EntityConditionTimer(self:GetOwner(), trace.Entity, nil, info.duration, 192,
          function()
            return (hook.Run('PlayerCanLockEntity', self:GetOwner(), trace.Entity)
            and self:GetOwner():Alive() and !self:GetOwner():IsRagdolled() and self:GetOwner():IsUsingKeys())
          end,
          function(success)
            if success then
              info.Callback(self:GetOwner(), trace.Entity)

              if !info.noSound then
                self:GetOwner():EmitSound('doors/door_latch3.wav')
              end
            else
              cw.player:SetAction(self:GetOwner(), 'lock', false)
            end
          end
        )
      end
    end
  end
end

--- Starts unlocking the entity the owner looks at within 192 units.
--
-- `PlayerGetUnlockInfo` supplies the unlock duration, callback and sound flag; `PlayerCanUnlockEntity` must
-- allow it and keep allowing it until the timer ends.
function SWEP:SecondaryAttack()
  self:SetNextSecondaryFire(CurTime() + 1)

  if SERVER then
    local action = cw.player:GetAction(self:GetOwner())
    local trace = self:GetOwner():GetEyeTraceNoCursor()

    if self:GetOwner():GetPos():Distance(trace.HitPos) > 192
    or !IsValid(trace.Entity) then
      return
    end

    local info = hook.Run('PlayerGetUnlockInfo', self:GetOwner(), trace.Entity)

    if info and hook.Run('PlayerCanUnlockEntity', self:GetOwner(), trace.Entity) then
      local isNotUnlocking = (action != 'unlock')
      local isNotLocking = (action != 'lock')

      if isNotLocking or isNotUnlocking then
        cw.player:SetAction(self:GetOwner(), 'unlock', info.duration)
        cw.player:EntityConditionTimer(self:GetOwner(), trace.Entity, nil, info.duration, 192,
          function()
            return (hook.Run('PlayerCanUnlockEntity', self:GetOwner(), trace.Entity)
            and self:GetOwner():Alive() and !self:GetOwner():IsRagdolled() and self:GetOwner():IsUsingKeys())
          end,
          function(success)
            if success then
              info.Callback(self:GetOwner(), trace.Entity)

              if !info.noSound then
                self:GetOwner():EmitSound('doors/door_latch3.wav')
              end
            else
              cw.player:SetAction(self:GetOwner(), 'unlock', false)
            end
          end
        )
      end
    end
  end
end
