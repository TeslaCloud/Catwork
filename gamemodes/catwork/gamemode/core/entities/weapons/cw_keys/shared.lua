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

--- Starts a timed `lock` or `unlock` action on the entity the owner looks at within 192 units.
--
-- Does nothing while the owner is already locking or unlocking. The info hook supplies the duration, callback
-- and sound flag; the permission hook must allow the action and keep allowing it until the timer ends.
-- @param action [String Name of the action, `lock` or `unlock`]
-- @param infoHook [String Hook that returns the action's info, such as `PlayerGetLockInfo`]
-- @param canHook [String Hook that allows the action, such as `PlayerCanLockEntity`]
function SWEP:StartKeyAction(action, infoHook, canHook)
  local owner = self:GetOwner()
  local currentAction = cw.player:GetAction(owner)
  local trace = owner:GetEyeTraceNoCursor()
  local entity = trace.Entity

  if owner:GetPos():Distance(trace.HitPos) > 192 or !IsValid(entity)
  or currentAction == 'lock' or currentAction == 'unlock' then
    return
  end

  local info = hook.Run(infoHook, owner, entity)

  if info and hook.Run(canHook, owner, entity) then
    cw.player:SetAction(owner, action, info.duration)
    cw.player:EntityConditionTimer(owner, entity, nil, info.duration, 192,
      function()
        return (hook.Run(canHook, owner, entity)
        and owner:Alive() and !owner:IsRagdolled() and owner:IsUsingKeys())
      end,
      function(success)
        if success then
          info.Callback(owner, entity)

          if !info.noSound then
            owner:EmitSound('doors/door_latch3.wav')
          end
        elseif IsValid(owner) then
          cw.player:SetAction(owner, action, false)
        end
      end
    )
  end
end

--- Starts locking the entity the owner looks at within 192 units.
--
-- `PlayerGetLockInfo` supplies the lock duration, callback and sound flag; `PlayerCanLockEntity` must allow it
-- and keep allowing it until the timer ends.
function SWEP:PrimaryAttack()
  self:SetNextPrimaryFire(CurTime() + 1)

  if SERVER then
    self:StartKeyAction('lock', 'PlayerGetLockInfo', 'PlayerCanLockEntity')
  end
end

--- Starts unlocking the entity the owner looks at within 192 units.
--
-- `PlayerGetUnlockInfo` supplies the unlock duration, callback and sound flag; `PlayerCanUnlockEntity` must
-- allow it and keep allowing it until the timer ends.
function SWEP:SecondaryAttack()
  self:SetNextSecondaryFire(CurTime() + 1)

  if SERVER then
    self:StartKeyAction('unlock', 'PlayerGetUnlockInfo', 'PlayerCanUnlockEntity')
  end
end
