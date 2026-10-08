--- Defines the `weapon_vort` weapon (Vorti-Beam), the vortigaunt's beam attack and healing ability.
--
-- Primary fire charges for `SWEP.BeamChargeTime` seconds and then fires a shock beam for `SWEP.BeamDamage` damage;
-- secondary fire heals the player in front of the owner, or the owner, by 12 to 18 health after `SWEP.HealDelay`
-- seconds. Both are advanced in `SWEP:Think` with looping sounds and particle effects, and the instructions are
-- hard-coded in Russian.

if SERVER then
  -- resource.AddFile("models/weapons/v_vortbeamvm.mdl")
  -- resource.AddFile("materials/vgui/entities/swep_vortigaunt_beam.vmt")
  -- resource.AddFile("materials/vgui/killicons/swep_vortigaunt_beam.vmt")

  AddCSLuaFile('shared.lua')

  SWEP.AutoSwitchTo = true
  SWEP.AutoSwitchFrom = true
end

if CLIENT then
  SWEP.DrawAmmo = false
  SWEP.PrintName = 'Vorti-Beam'
  SWEP.Author = 'DV'
  SWEP.DrawCrosshair = true
  SWEP.ViewModelFOV = 54
  -- SWEP.Contact		= "chajecraft@hotmail.com"
  -- SWEP.Purpose		= "Wooooooooooosh 'Thanks buddy'!"
  SWEP.Instructions = 'ЛКМ - Атака.\nПКМ - Лечение.'
end

SWEP.Category = 'HL2'
SWEP.Slot = 3
SWEP.SlotPos				= 5
SWEP.Weight					= 5
SWEP.Spawnable = false
SWEP.AdminOnly = true

SWEP.ViewModel 				= 'models/weapons/v_vortbeamvm.mdl'
SWEP.WorldModel 			= ''

SWEP.Range = 2 * cvars.Number('sk_vortigaunt_zap_range', 100) * 15 -- because it's in feet,we convert it.
SWEP.DamageForce			= 48000 -- 12000 is the force done by two vortigaunts claws zap attack
SWEP.AmmoPerUse				= 0 -- we use ar2 altfire ammo,don't exagerate here
SWEP.HealSound = Sound('HealthKit.Touch')
SWEP.HealLoop = Sound('NPC_Vortigaunt.StartHealLoop')
SWEP.AttackLoop				= Sound('NPC_Vortigaunt.ZapPowerup')
SWEP.AttackSound			= Sound('npc/vort/attack_shoot.wav')
SWEP.HealDelay				= 3		-- we heal again CurTime()+self.HealDelay
SWEP.MaxHealth				= 18	-- used for the math.random
SWEP.MinHealth				= 12	-- "		"	"	"
SWEP.HealthLimit = 100 -- 100 is the default hl2 health limit
SWEP.BeamDamage = 60 -- 25 is done by one zap attack,since vortigaunt has two claws,50 dmg,
SWEP.BeamChargeTime = 1.25 -- the delay used to charge the beam and zap!
SWEP.Deny = Sound('Buttons.snd19')

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1 -- give the poor user 25 combine balls to have fun with this wepon
SWEP.Primary.Ammo = ''
SWEP.Primary.Automatic = false

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = false
SWEP.Secondary.Automatic = false

--- Resets the charge and heal state, sets the shotgun hold type and creates the looping sounds
-- on the server.
function SWEP:Initialize()
  self.Charging = false -- we are not charging!
  self.Healing = false -- we are not healing!
  self.ArmorRegenTime = CurTime()
  self.HealTime = CurTime() -- we can heal
  self.ChargeTime = CurTime() -- we can zap
  self:SetHoldType('shotgun') -- this is the better holdtype i could find,well,it fits its job

  if CLIENT then return end

  self:CreateSounds()			-- create the looping sounds
end

--- Precaches the vortigaunt beam particles and the view model.
function SWEP:Precache()
  PrecacheParticleSystem('vortigaunt_beam') -- the zap beam
  PrecacheParticleSystem('vortigaunt_beam_charge') -- the glow particles
  util.PrecacheModel(self.ViewModel) -- the... come on,that's obvious
end

--- Creates the charge and heal loop sounds if they do not exist yet.
function SWEP:CreateSounds()
  if !self.ChargeSound then
    self.ChargeSound = CreateSound(self, self.AttackLoop)
  end

  if !self.HealingSound then
    self.HealingSound = CreateSound(self, self.HealLoop)
  end
end

--- Attaches a particle effect to the view model muzzle, or to the owner's right claw when seen from outside.
-- @param EFFECTSTR [String Name of the particle system]
function SWEP:DispatchEffect(EFFECTSTR)
  local pPlayer = self.Owner

  if !pPlayer then return end

  local view
  if CLIENT then view = GetViewEntity() else view = pPlayer:GetViewEntity() end

  if !pPlayer:IsNPC() and view:IsPlayer() then
    ParticleEffectAttach(
      EFFECTSTR,
      PATTACH_POINT_FOLLOW,
      pPlayer:GetViewModel(),
      pPlayer:GetViewModel():LookupAttachment('muzzle')
    )
  else
    ParticleEffectAttach(EFFECTSTR, PATTACH_POINT_FOLLOW, pPlayer, pPlayer:LookupAttachment('rightclaw'))
  end
end

--- Draws a particle tracer from the muzzle, or the owner's right claw when seen from outside, to a position.
-- @param EFFECTSTR [String Name of the particle system]
-- @param startpos [Vector Start of the tracer when the weapon has no muzzle attachment]
-- @param endpos [Vector End of the tracer]
function SWEP:ShootEffect(EFFECTSTR, startpos, endpos)
  local pPlayer = self.Owner
  if !pPlayer then return end

  local view
  if CLIENT then view = GetViewEntity() else view = pPlayer:GetViewEntity() end

  if !pPlayer:IsNPC() and view:IsPlayer() then
    -- The weapon has no world model, so it may well have no muzzle attachment either.
    local attachment = self:GetAttachment(self:LookupAttachment('muzzle'))

    util.ParticleTracerEx(
      EFFECTSTR,
      attachment and attachment.Pos or startpos,
      endpos,
      true,
      pPlayer:GetViewModel():EntIndex(),
      pPlayer:GetViewModel():LookupAttachment('muzzle')
    )
  else
    util.ParticleTracerEx(
      EFFECTSTR,
      pPlayer:GetAttachment(pPlayer:LookupAttachment('rightclaw')).Pos,
      endpos,
      true,
      pPlayer:EntIndex(),
      pPlayer:LookupAttachment('rightclaw')
    )
  end
end

--- Plays the zap impact effect and blast rings at a trace hit, and makes hit ragdolls dance on the server.
-- @param traceHit [Map Trace result of the beam]
function SWEP:ImpactEffect(traceHit)
  local data = EffectData()

  data:SetOrigin(traceHit.HitPos)
  data:SetNormal(traceHit.HitNormal)
  data:SetScale(20)
  util.Effect('StunstickImpact', data)

  local rand = math.random(1, 1.5)

  self:CreateBlast(rand, traceHit.HitPos)
  self:CreateBlast(rand, traceHit.HitPos)

  if SERVER and traceHit.Entity and IsValid(traceHit.Entity) and string.find(traceHit.Entity:GetClass(), 'ragdoll') then
    traceHit.Entity:Fire('StartRagdollBoogie')

    --[[	local boog=ents.Create("env_ragdoll_boogie")
      boog:SetPos(traceHit.Entity:GetPos())
      boog:SetParent(traceHit.Entity)
      boog:Spawn()
    boog:SetParent(traceHit.Entity)]] --
  end
end

--- Spawns a short-lived vortigaunt ring sprite on the server.
-- @param scale [Number Sprite scale]
-- @param pos [Vector Where to place the sprite]
function SWEP:CreateBlast(scale, pos)
  if CLIENT then return end

  local blastspr = ents.Create('env_sprite') -- took me hours to understand how this damn

  blastspr:SetPos(pos) -- entity works
  blastspr:SetKeyValue('model', 'sprites/vortring1.vmt') -- the damn vortigaunt beam ring
  blastspr:SetKeyValue('scale', tostring(scale))
  blastspr:SetKeyValue('framerate', 60)
  blastspr:SetKeyValue('spawnflags', '1')
  blastspr:SetKeyValue('brightness', '255')
  blastspr:SetKeyValue('angles', '0 0 0')
  blastspr:SetKeyValue('rendermode', '9')
  blastspr:SetKeyValue('renderamt', '255')
  blastspr:Spawn()
  blastspr:Fire('kill', '', 0.45) -- remove it after 0.45 seconds
end

--- Fires the vortigaunt beam along the owner's aim, up to `SWEP.Range` units.
--
-- On the server, the entity hit takes shock damage with a strong push. The beam tracer, attack sound and
-- impact effects play in both realms.
--
-- @param dmg=nil [Number Damage to deal; defaults to `SWEP.BeamDamage`]
-- @param effect=nil [String Tracer particle system; defaults to `vortigaunt_beam`]
function SWEP:Shoot(dmg, effect)
  local pPlayer = self.Owner

  if !pPlayer then return end

  local traceres = util.QuickTrace(self.Owner:EyePos(), self.Owner:GetAimVector() * self.Range, self.Owner)

  self:ShootEffect(effect or 'vortigaunt_beam', pPlayer:EyePos(), traceres.HitPos) -- shoop da whoop

  if SERVER then
    if IsValid(traceres.Entity) then -- we hit something
      local DMG = DamageInfo()
      DMG:SetDamageType(DMG_SHOCK) -- it's called vortigaunt zap attack for a reason
      DMG:SetDamage(dmg or self.BeamDamage)
      DMG:SetAttacker(self.Owner)
      DMG:SetInflictor(self)
      DMG:SetDamagePosition(traceres.HitPos)
      DMG:SetDamageForce(pPlayer:GetAimVector() * self.DamageForce)
      traceres.Entity:TakeDamageInfo(DMG)
    end
  end

  self.Owner:GetViewModel():EmitSound(self.AttackSound)
  self:ImpactEffect(traceres)
end

--- Cancels any charge or heal in progress.
-- @return [Boolean Always `true` to allow the holster]
function SWEP:Holster(wep)
  self:StopEveryThing()
  return true
end

--- Cancels any charge or heal in progress.
function SWEP:OnRemove()
  self:StopEveryThing()
end

--- Cancels charging and healing, stops their loop sounds and clears the last owner's particles.
function SWEP:StopEveryThing()
  self.Charging = false

  if SERVER and self.ChargeSound then
    self.ChargeSound:Stop()
  end

  self.Healing = false

  if SERVER and self.HealingSound then
    self.HealingSound:Stop()
  end

  local pPlayer = self.LastOwner

  if !pPlayer then
    return
  end

  if !IsValid(pPlayer) then return end
  if !pPlayer:GetViewModel() then return end

  if CLIENT then if pPlayer == LocalPlayer() then pPlayer:GetViewModel():StopParticles()end end
  pPlayer:StopParticles()
end

--- Plays the draw animation at normal speed.
-- @return [Boolean Always `true` to allow the deploy]
function SWEP:Deploy()
  self:SendWeaponAnim(ACT_VM_DRAW)
  self:SetDeploySpeed(1)
  return true
end

--- Advances a charge or heal started by an attack and fires the beam or heals once it completes.
--
-- Also records the current owner for `SWEP:StopEveryThing`. Without enough ammo the charge or heal is
-- cancelled with a deny sound.
function SWEP:Think()
  if self.Owner and IsValid(self.Owner)then self.LastOwner = self.Owner end -- i hate doing this,whatever

  if self.Charging and self.ChargeTime - 0.25 < CurTime() and !self.attack then
    if self.Owner:GetAmmoCount(self.Primary.Ammo) >= self.AmmoPerUse then -- check always if we have ammo
      self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
      self:DispatchEffect('vortigaunt_charge_token') -- this effect lags a lot,but we see it for 0.75 seconds,who cares
      timer.Simple(0.75, function()
        if !IsValid(self.Owner) or self.Owner:GetActiveWeapon() != self or !IsValid(self) then return end

        self:SendWeaponAnim(ACT_VM_IDLE)
      end)
    end

    self.attack = true
  end

  if self.Charging and self.ChargeTime < CurTime() then
    if self.Owner:GetAmmoCount(self.Primary.Ammo) < self.AmmoPerUse then
      self:EmitSound(self.Deny)
      self:SetNextPrimaryFire(CurTime() + SoundDuration(self.Deny))
      self:SetNextSecondaryFire(CurTime() + SoundDuration(self.Deny))
      if IsValid(self.Owner:GetViewModel())then self.Owner:GetViewModel():StopParticles() end
      self.Owner:StopParticles()
      self.Charging = false
      self:SendWeaponAnim(ACT_VM_IDLE)
      if SERVER and self.ChargeSound then self.ChargeSound:Stop()end
      return
    end

    if IsValid(self.Owner:GetViewModel())then self.Owner:GetViewModel():StopParticles() end
    self.Owner:StopParticles()
    self:Shoot()
    self.Charging = false
    self.attack = false

    if SERVER and self.ChargeSound then self.ChargeSound:Stop()end
    self:SetNextPrimaryFire(CurTime() + 3)
    self:SetNextSecondaryFire(CurTime() + 3)
  end

  if self.Healing and self.HealTime < CurTime() then
    if self.Owner:GetAmmoCount(self.Primary.Ammo) < self.AmmoPerUse then
      self:EmitSound(self.Deny)
      self:SetNextPrimaryFire(CurTime() + SoundDuration(self.Deny))
      self:SetNextSecondaryFire(CurTime() + SoundDuration(self.Deny))
      if IsValid(self.Owner:GetViewModel())then self.Owner:GetViewModel():StopParticles() end
      self.Owner:StopParticles()
      self.Healing = false
      self:SendWeaponAnim(ACT_VM_IDLE)

      if SERVER and self.HealingSound then self.HealingSound:Stop()end
      return
    end

    if IsValid(self.Owner:GetViewModel())then self.Owner:GetViewModel():StopParticles() end
    self.Owner:StopParticles()
    self:SendWeaponAnim(ACT_VM_IDLE)
    self.Healing = false
    self.Owner:EmitSound(self.HealSound)

    if SERVER and self.HealingSound then self.HealingSound:Stop()end
    self:GiveHealth()
    self:SetNextPrimaryFire(CurTime() + 3)
    self:SetNextSecondaryFire(CurTime() + 6)
  end
end

--- Heals the player in front of the owner within 50 units, or the owner, by 12 to 18 health up to 100.
--
-- Runs only on the server; does nothing when the target is already at the health limit.
function SWEP:GiveHealth()
  if CLIENT then return end

  local arm = math.random(self.MinHealth, self.MaxHealth)
  local trace = util.QuickTrace(self.Owner:EyePos(), self.Owner:GetAimVector() * 50, self.Owner)
  local healety = trace.Entity

  if !IsValid(healety) or !healety:IsPlayer() then
    healety = self.Owner
  end

  local plarm = healety:Health()

  if plarm >= self.HealthLimit then
    return
  end

  if plarm <= (self.HealthLimit - arm) then
    healety:SetHealth(plarm + arm)
  else
    healety:SetHealth(self.HealthLimit)
  end
end

--- Starts charging the beam, which `SWEP:Think` fires after `SWEP.BeamChargeTime` seconds.
function SWEP:PrimaryAttack()
  if self.Charging or self.Healing then return end

  if self.Owner:GetAmmoCount(self.Primary.Ammo) < self.AmmoPerUse then
    self:EmitSound(self.Deny)
    self:SetNextPrimaryFire(CurTime() + SoundDuration(self.Deny))
    self:SetNextSecondaryFire(CurTime() + SoundDuration(self.Deny))
    return
  end

  self:DispatchEffect('vortigaunt_charge_token_b')
  self:DispatchEffect('vortigaunt_charge_token_c')
  self.ChargeTime = CurTime() + self.BeamChargeTime
  self.attack = false
  self.Charging = true
  self:SendWeaponAnim(ACT_VM_RELOAD)

  if SERVER and self.ChargeSound then
    self.ChargeSound:PlayEx(100, 150)
  end

  self:SetNextPrimaryFire(CurTime() + 6)
  self:SetNextSecondaryFire(CurTime() + 6)
end

--- Starts a heal, which `SWEP:Think` applies after `SWEP.HealDelay` seconds.
--
-- Only starts when the player in front of the owner or the owner is below the health limit.
function SWEP:SecondaryAttack()
  if self.Charging or self.Healing then
    return
  end

  local trace = util.QuickTrace(self.Owner:EyePos(), self.Owner:GetAimVector() * 50, self.Owner)

  if (IsValid(trace.Entity) and trace.Entity:IsPlayer() and trace.Entity:Health() < self.HealthLimit)
  or self.Owner:Health() < self.HealthLimit then
    if self.Owner:GetAmmoCount(self.Primary.Ammo) < self.AmmoPerUse then
      self:EmitSound(self.Deny)
      self:SetNextPrimaryFire(CurTime() + SoundDuration(self.Deny))
      self:SetNextSecondaryFire(CurTime() + SoundDuration(self.Deny))
      return
    end

    self.HealTime = CurTime() + self.HealDelay
    self.Healing = true
    self:DispatchEffect('vortigaunt_charge_token')
    self:SendWeaponAnim(ACT_VM_RELOAD)

    if SERVER and self.HealingSound then
      self.HealingSound:PlayEx(100, 150)
    end

    self:SetNextPrimaryFire(CurTime() + 3)
    self:SetNextSecondaryFire(CurTime() + 6)
  end
end

--- Does nothing.
function SWEP:Reload()
end
