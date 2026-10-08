--- Defines the `cw_flashgrenade` weapon (Flash), a thrown grenade that blinds every player within 768 units who can see
-- it.
--
-- Holding primary fire charges the throw and releasing it throws a `prop_physics` grenade that explodes after four
-- seconds and sends the `Flashed` netstream message to the affected players. Each throw uses up one grenade, and the
-- weapon is stripped when none are left.

if SERVER then
  AddCSLuaFile('shared.lua')
end

if CLIENT then
  SWEP.Slot = 4
  SWEP.SlotPos = 4
  SWEP.DrawAmmo = false
  SWEP.PrintName = 'Flash'
  SWEP.DrawCrosshair = true
end

SWEP.Instructions = 'Primary Fire: Throw.'
SWEP.Purpose = 'Disorientating characters with a bright white flash.'
SWEP.Contact = ''
SWEP.Author = 'kurozael'

SWEP.WorldModel = 'models/weapons/w_grenade.mdl'
SWEP.ViewModel = 'models/weapons/v_grenade.mdl'

SWEP.AdminSpawnable = false
SWEP.Spawnable = false

SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = 0
SWEP.Primary.Delay = 1
SWEP.Primary.Ammo = 'grenade'

SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Delay = 1
SWEP.Secondary.Ammo = ''

SWEP.NoIronSightFovChange = true
SWEP.NoIronSightAttack = true
SWEP.IronSightPos = Vector(0, 0, 0)
SWEP.IronSightAng = Vector(0, 0, 0)

--- Throws the grenade once the attack key is released and, after the throw, uses up one
-- grenade, stripping the weapon when none are left.
function SWEP:Think()
  local curTime = CurTime()

  if self.PulledBack and !self.Owner:KeyDown(IN_ATTACK) then
    if curTime >= self.PulledBack then
      self.PulledBack = nil
      self.Attacking = curTime + (self.Primary.Delay / 2)
      self.Raised = curTime + self.Primary.Delay + 2

      if !self.AttackTime then
        self.AttackTime = curTime
      end

      self:CreateGrenade(math.Clamp(curTime - self.AttackTime, 0, 10) * 40)
      self:EmitSound('WeaponFrag.Throw')

      self:SendWeaponAnim(ACT_VM_THROW)
      self:SetNextPrimaryFire(curTime + self.Primary.Delay)

      self.Owner:SetAnimation(PLAYER_ATTACK1)
    end
  elseif type(self.Attacking) == 'number' then
    if curTime >= self.Attacking then
      self.Attacking = nil

      self:SendWeaponAnim(ACT_VM_DRAW)

      if SERVER then
        self.Owner:RemoveAmmo(1, 'grenade')

        if self.Owner:GetAmmoCount('grenade') == 0 then
          self.Owner:StripWeapon(self:GetClass())
        end
      end
    end
  end
end

--- Plays the draw animation and cancels any throw in progress.
-- @return [Boolean Always `true` to allow the deploy]
function SWEP:Deploy()
  if SERVER then
    self:SetHoldType('grenade')
  end

  self:SendWeaponAnim(ACT_VM_DRAW)

  self.PulledBack = nil
  self.Attacking = nil

  return true
end

--- Plays the holster animation and cancels any throw in progress.
-- @return [Boolean Always `true` to allow the holster]
function SWEP:Holster(switchingTo)
  self:SendWeaponAnim(ACT_VM_HOLSTER)

  self.PulledBack = nil
  self.Attacking = nil

  return true
end

--- Reports the weapon as raised while throwing and for two seconds after.
-- @return [Boolean `true` while raised, otherwise `nil`]
function SWEP:GetRaised()
  local curTime = CurTime()

  if self.Attacking or (self.Raised and self.Raised > curTime) then
    return true
  end
end

--- Sets the grenade hold type on the server.
function SWEP:Initialize()
  if SERVER then
    self:SetHoldType('grenade')
  end
end

--- Throws a flash grenade that, after four seconds, explodes and blinds every player within 768 units
-- who can see it.
--
-- Runs only on the server. The grenade spawns 64 units ahead of the owner, or just short of a surface
-- closer than 80 units, and is thrown with a force of `800 + power`.
--
-- @param power [Number Extra throw force, 40 per second the attack key was held, up to 400]
function SWEP:CreateGrenade(power)
  if SERVER then
    local position = self.Owner:GetShootPos() + (self.Owner:GetAimVector() * 64)
    local entity = ents.Create('prop_physics')
    local trace = self.Owner:GetEyeTraceNoCursor()

    if trace.HitPos:Distance(self.Owner:GetShootPos()) <= 80 then
      position = trace.HitPos - (self.Owner:GetAimVector() * 16)
    end

    entity:SetModel('models/items/grenadeammo.mdl')
    entity:SetPos(position)
    entity:Spawn()

    if IsValid(entity) then
      if IsValid(entity:GetPhysicsObject()) then
        entity:GetPhysicsObject():ApplyForceCenter(self.Owner:GetAimVector() * (800 + power))
        entity:GetPhysicsObject():AddAngleVelocity(Vector(600, math.random(-1200, 1200), 0))
      end

      local trail = util.SpriteTrail(
        entity,
        entity:LookupAttachment('fuse'),
        Color(255, 100, 0),
        true,
        8,
        1,
        1,
        (1 / 9) * 0.5,
        'sprites/bluelaser1.vmt'
      )

      if IsValid(trail) then
        entity:DeleteOnRemove(trail)
      end

      timer.Simple(4, function()
        if IsValid(entity) then
          local effectData = EffectData()
          local position = entity:GetPos()

          effectData:SetStart(entity:GetPos())
          effectData:SetOrigin(entity:GetPos())
          effectData:SetScale(16)

          util.Effect('Explosion', effectData, true, true)

          for k, v in ipairs(_player.GetAll()) do
            if v:HasInitialized() then
              if v:GetPos():Distance(position) <= 768 then
                if cw.player:CanSeeEntity(v, entity, 0.9, true) then
                  netstream.Start(v, 'Flashed', true)
                end
              end
            end
          end

          entity:EmitSound('physics/body/body_medium_impact_soft'..math.random(1, 7)..'.wav')
          entity:Remove()
        end
      end)
    end
  end
end

--- Pulls the grenade back to start a throw, which `SWEP:Think` releases.
-- @return [Boolean Always `false`]
function SWEP:PrimaryAttack()
  local curTime = CurTime()

  if !self.Attacking then
    self:SendWeaponAnim(ACT_VM_PULLBACK_HIGH)

    self.PulledBack = curTime + 0.157
    self.AttackTime = curTime
    self.Attacking = true
  end

  return false
end

--- Does nothing.
function SWEP:SecondaryAttack() end
