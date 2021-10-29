--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.
	
	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

if (SERVER) then
	
	-- resource.AddFile("models/weapons/v_vortbeamvm.mdl")
	-- resource.AddFile("materials/vgui/entities/swep_vortigaunt_beam.vmt")
	-- resource.AddFile("materials/vgui/killicons/swep_vortigaunt_beam.vmt")
	
	AddCSLuaFile( "shared.lua" )
	
	SWEP.AutoSwitchTo		= true
	SWEP.AutoSwitchFrom		= true
	
end



if ( CLIENT ) then
	
	SWEP.DrawAmmo			= false
	SWEP.PrintName			= "Vorti-Beam"
	SWEP.Author				= "DV"
	SWEP.DrawCrosshair		= true
	SWEP.ViewModelFOV		= 54
	-- SWEP.Contact		= "chajecraft@hotmail.com"
	-- SWEP.Purpose		= "Wooooooooooosh 'Thanks buddy'!"
	SWEP.Instructions = "ЛКМ - Атака.\nПКМ - Лечение."
	
end



SWEP.Category				= "HL2"
SWEP.Slot					= 3
SWEP.SlotPos				= 5
SWEP.Weight					= 5
SWEP.Spawnable     			= false
SWEP.AdminOnly		  		= true

SWEP.ViewModel 				= "models/weapons/v_vortbeamvm.mdl"
SWEP.WorldModel 			= ""

SWEP.Range					= 2*GetConVarNumber( "sk_vortigaunt_zap_range",100)*15--because it's in feet,we convert it.
SWEP.DamageForce			= 48000	 --12000 is the force done by two vortigaunts claws zap attack
SWEP.AmmoPerUse				= 0		 --we use ar2 altfire ammo,don't exagerate here
SWEP.HealSound				= Sound("HealthKit.Touch")
SWEP.HealLoop				= Sound("NPC_Vortigaunt.StartHealLoop")
SWEP.AttackLoop				= Sound("NPC_Vortigaunt.ZapPowerup" )
SWEP.AttackSound			= Sound("npc/vort/attack_shoot.wav")
SWEP.HealDelay				= 3		--we heal again CurTime()+self.HealDelay
SWEP.MaxHealth				= 18	--used for the math.random
SWEP.MinHealth				= 12	--"		"	"	"
SWEP.HealthLimit				= 100	--100 is the default hl2 health limit
SWEP.BeamDamage				= 60	--25 is done by one zap attack,since vortigaunt has two claws,50 dmg,
SWEP.BeamChargeTime			= 1.25	--the delay used to charge the beam and zap!
SWEP.Deny					= Sound("Buttons.snd19")

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1	--give the poor user 25 combine balls to have fun with this wepon
SWEP.Primary.Ammo 			= ""
SWEP.Primary.Automatic		= false

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo 		= false
SWEP.Secondary.Automatic 	= false


function SWEP:Initialize()
	
	self.Charging=false--we are not charging!
	self.Healing=false	--we are not healing!
	self.ArmorRegenTime=CurTime()
	self.HealTime=CurTime()--we can heal
	self.ChargeTime=CurTime()--we can zap
	self:SetWeaponHoldType("shotgun")--this is the better holdtype i could find,well,it fits its job
	
	if (CLIENT) then return end
	
	self:CreateSounds()			--create the looping sounds
end



function SWEP:Precache()
	
	PrecacheParticleSystem( "vortigaunt_beam" )		--the zap beam
	PrecacheParticleSystem( "vortigaunt_beam_charge" )	--the glow particles
	util.PrecacheModel(self.ViewModel)					--the... come on,that's obvious
end



function SWEP:CreateSounds()
	
	if (!self.ChargeSound) then
		self.ChargeSound = CreateSound( self.Weapon, self.AttackLoop )
	end
	
	if (!self.HealingSound) then
		self.HealingSound = CreateSound( self.Weapon, self.HealLoop )
	end
end



function SWEP:DispatchEffect(EFFECTSTR)
	
	local pPlayer=self.Owner
	
	if !pPlayer then return end
	local view
	if CLIENT then view=GetViewEntity() else view=pPlayer:GetViewEntity() end
	if ( !pPlayer:IsNPC() && view:IsPlayer() ) then
		ParticleEffectAttach( EFFECTSTR, PATTACH_POINT_FOLLOW, pPlayer:GetViewModel(), pPlayer:GetViewModel():LookupAttachment( "muzzle" ) )
		else
		ParticleEffectAttach( EFFECTSTR, PATTACH_POINT_FOLLOW, pPlayer, pPlayer:LookupAttachment( "rightclaw" ) )
	end
end



function SWEP:ShootEffect(EFFECTSTR,startpos,endpos)
	
	local pPlayer=self.Owner
	if !pPlayer then return end
	local view
	if CLIENT then view=GetViewEntity() else view=pPlayer:GetViewEntity() end
	if ( !pPlayer:IsNPC() && view:IsPlayer() ) then
		util.ParticleTracerEx( EFFECTSTR, self.Weapon:GetAttachment( self.Weapon:LookupAttachment( "muzzle" ) ).Pos,endpos, true, pPlayer:GetViewModel():EntIndex(), pPlayer:GetViewModel():LookupAttachment( "muzzle" ) )
		else
		util.ParticleTracerEx( EFFECTSTR, pPlayer:GetAttachment( pPlayer:LookupAttachment( "rightclaw" ) ).Pos,endpos, true,pPlayer:EntIndex(), pPlayer:LookupAttachment( "rightclaw" ) )
	end
end



function SWEP:ImpactEffect( traceHit )
	
	local data = EffectData()
	
	data:SetOrigin(traceHit.HitPos)
	data:SetNormal(traceHit.HitNormal)
	data:SetScale(20)
	util.Effect( "StunstickImpact", data )
	
	local rand=math.random(1,1.5)
	
	self:CreateBlast(rand,traceHit.HitPos)
	self:CreateBlast(rand,traceHit.HitPos)
	
	if SERVER && traceHit.Entity && IsValid(traceHit.Entity) && string.find(traceHit.Entity:GetClass(),"ragdoll") then
		
		traceHit.Entity:Fire("StartRagdollBoogie")
		
		--[[	local boog=ents.Create("env_ragdoll_boogie")
			boog:SetPos(traceHit.Entity:GetPos())
			boog:SetParent(traceHit.Entity)
			boog:Spawn()
		boog:SetParent(traceHit.Entity)]]--
	end
end



function SWEP:CreateBlast(scale,pos)
	
	if CLIENT then return end
	
	local blastspr = ents.Create("env_sprite")			--took me hours to understand how this damn
	
	blastspr:SetPos( pos )								--entity works
	blastspr:SetKeyValue( "model", "sprites/vortring1.vmt")--the damn vortigaunt beam ring
	blastspr:SetKeyValue( "scale",tostring(scale))
	blastspr:SetKeyValue( "framerate",60)
	blastspr:SetKeyValue( "spawnflags","1")
	blastspr:SetKeyValue( "brightness","255")
	blastspr:SetKeyValue( "angles","0 0 0")
	blastspr:SetKeyValue( "rendermode","9")
	blastspr:SetKeyValue( "renderamt","255")
	blastspr:Spawn()
	blastspr:Fire("kill","",0.45)							--remove it after 0.45 seconds
end

function SWEP:Shoot(dmg,effect)
	
	local pPlayer=self.Owner
	
	if !pPlayer then return end
	
	local traceres=util.QuickTrace(self.Owner:EyePos(),self.Owner:GetAimVector()*self.Range,self.Owner)
	
	self:ShootEffect(effect or "vortigaunt_beam",pPlayer:EyePos(),traceres.HitPos)	--shoop da whoop
	
	if SERVER then
		if IsValid(traceres.Entity) then	--we hit something
			local DMG=DamageInfo()
			DMG:SetDamageType(DMG_SHOCK)		--it's called vortigaunt zap attack for a reason
			DMG:SetDamage(dmg or self.BeamDamage)
			DMG:SetAttacker(self.Owner)
			DMG:SetInflictor(self)
			DMG:SetDamagePosition(traceres.HitPos)
			DMG:SetDamageForce(pPlayer:GetAimVector()*self.DamageForce)
			traceres.Entity:TakeDamageInfo(DMG)
		end
	end
	
	self.Owner:GetViewModel():EmitSound(self.AttackSound)
	self:ImpactEffect( traceres )
end



function SWEP:Holster( wep )
	self:StopEveryThing()
	return true
end



function SWEP:OnRemove()
	self:StopEveryThing()
end



function SWEP:StopEveryThing()
	
	self.Charging=false
	if SERVER && self.ChargeSound then
		self.ChargeSound:Stop()
	end
	
	self.Healing=false
	if SERVER && self.HealingSound then
		self.HealingSound:Stop()
	end
	
	
	
	local pPlayer = self.LastOwner
	if (!pPlayer) then
		return
	end
	
	local Weapon = self.Weapon
	
	if (!IsValid(pPlayer)) then return end
	if (!pPlayer:GetViewModel()) then return end
	if ( CLIENT ) then if ( pPlayer == LocalPlayer() ) then pPlayer:GetViewModel():StopParticles()end	end
	pPlayer:StopParticles()
end



function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self:SetDeploySpeed( 1 )
	return true
end



function SWEP:Think()
	
	if self.Owner && IsValid(self.Owner)then self.LastOwner=self.Owner end --i hate doing this,whatever
	
	if self.Charging && self.ChargeTime-0.25 < CurTime() && !self.attack then
		if self.Owner:GetAmmoCount(self.Primary.Ammo)>=self.AmmoPerUse then--check always if we have ammo
			self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
			self:DispatchEffect("vortigaunt_charge_token")--this effect lags a lot,but we see it for 0.75 seconds,who cares
			timer.Simple(0.75,function()if !IsValid(self.Owner) || self.Owner:GetActiveWeapon()!=self || !IsValid(self)  then return end self.Weapon:SendWeaponAnim(ACT_VM_IDLE)end)
		end
		self.attack=true
	end
	
	
	
	if self.Charging && self.ChargeTime < CurTime() then
		if self.Owner:GetAmmoCount(self.Primary.Ammo)<self.AmmoPerUse then
			
			self.Weapon:EmitSound(self.Deny)
			self.Weapon:SetNextPrimaryFire(CurTime()+SoundDuration(self.Deny))
			self.Weapon:SetNextSecondaryFire(CurTime()+SoundDuration(self.Deny))
			if IsValid(self.Owner:GetViewModel())then self.Owner:GetViewModel():StopParticles() end
			self.Owner:StopParticles()
			self.Charging=false
			self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
			if SERVER && self.ChargeSound then	self.ChargeSound:Stop()end
			return
		end
		
		
		
		
		if IsValid(self.Owner:GetViewModel())then self.Owner:GetViewModel():StopParticles() end
		self.Owner:StopParticles()
		self:Shoot()
		self.Charging=false
		self.attack=false
		
		if SERVER && self.ChargeSound then	self.ChargeSound:Stop()end
		self.Weapon:SetNextPrimaryFire(CurTime()+3)
		self.Weapon:SetNextSecondaryFire(CurTime()+3)
	end
	
	
	
	if self.Healing && self.HealTime<CurTime() then
		if self.Owner:GetAmmoCount(self.Primary.Ammo)<self.AmmoPerUse then
			self.Weapon:EmitSound(self.Deny)
			self.Weapon:SetNextPrimaryFire(CurTime()+SoundDuration(self.Deny))
			self.Weapon:SetNextSecondaryFire(CurTime()+SoundDuration(self.Deny))
			if IsValid(self.Owner:GetViewModel())then self.Owner:GetViewModel():StopParticles() end
			self.Owner:StopParticles()
			self.Healing=false
			self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
			
			if SERVER && self.HealingSound then	self.HealingSound:Stop()end
			return
		end
		
		if IsValid(self.Owner:GetViewModel())then self.Owner:GetViewModel():StopParticles() end
		self.Owner:StopParticles()
		self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
		self.Healing=false
		self.Owner:EmitSound(self.HealSound)
		
		if SERVER && self.HealingSound then	self.HealingSound:Stop()end
		self:GiveHealth()
		self.Weapon:SetNextPrimaryFire(CurTime()+3)
		self.Weapon:SetNextSecondaryFire(CurTime()+6)
	end
end



function SWEP:GiveHealth()
	
	if CLIENT then return end
	local arm=math.random(self.MinHealth,self.MaxHealth)
	local trace = util.QuickTrace(self.Owner:EyePos(),self.Owner:GetAimVector()*50,self.Owner)
	local healety = trace.Entity
	
	if (!IsValid(healety) or !healety:IsPlayer()) then
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



function SWEP:PrimaryAttack()
	
	if self.Charging || self.Healing then return end
	if self.Owner:GetAmmoCount(self.Primary.Ammo)<self.AmmoPerUse then
		self.Weapon:EmitSound(self.Deny)
		self.Weapon:SetNextPrimaryFire(CurTime()+SoundDuration(self.Deny))
		self.Weapon:SetNextSecondaryFire(CurTime()+SoundDuration(self.Deny))
		return
	end
	
	self:DispatchEffect("vortigaunt_charge_token_b")
	self:DispatchEffect("vortigaunt_charge_token_c")
	self.ChargeTime=CurTime()+self.BeamChargeTime
	self.attack=false
	self.Charging=true
	self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
	
	if SERVER && self.ChargeSound then
		self.ChargeSound:PlayEx( 100, 150 )
	end
	
	self.Weapon:SetNextPrimaryFire(CurTime()+6)
	self.Weapon:SetNextSecondaryFire(CurTime()+6)
end





function SWEP:SecondaryAttack()
	
	if self.Charging || self.Healing then
		return
	end
	
	local trace = util.QuickTrace(self.Owner:EyePos(),self.Owner:GetAimVector()*50,self.Owner)
	
	if ((IsValid(trace.Entity) and trace.Entity:IsPlayer() and trace.Entity:Health() < self.HealthLimit) or self.Owner:Health() < self.HealthLimit) then
		if self.Owner:GetAmmoCount(self.Primary.Ammo)<self.AmmoPerUse  then
			self.Weapon:EmitSound(self.Deny)
			self.Weapon:SetNextPrimaryFire(CurTime()+SoundDuration(self.Deny))
			self.Weapon:SetNextSecondaryFire(CurTime()+SoundDuration(self.Deny))
			return
		end
		
		self.HealTime=CurTime()+self.HealDelay
		self.Healing=true
		self:DispatchEffect("vortigaunt_charge_token")
		self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
		
		if SERVER && self.HealingSound then
			self.HealingSound:PlayEx( 100, 150 )
		end
		
		self.Weapon:SetNextPrimaryFire(CurTime()+3)
		self.Weapon:SetNextSecondaryFire(CurTime()+6)
	end
end

function SWEP:Reload()
end
