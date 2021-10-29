--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

if (SERVER) then
	AddCSLuaFile("shared.lua")

	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

	resource.AddFile("models/weapons/w_fists_t.mdl")

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

if (CLIENT) then
	SWEP.PrintName			= L("#SWEPS_Hands")
	SWEP.Instructions		= L("#SWEPS_Hands_Instructions")
	SWEP.Purpose			= L("#SWEPS_Hands_Purpose")
	SWEP.Author 			= "Cloud Sixteen"
	SWEP.Contact			= "CloudSixteen.com"

	SWEP.DrawAmmo 			= false
	SWEP.DrawCrosshair 		= false
	SWEP.DrawSecondaryAmmo	= false
	SWEP.ViewModelFOV		= 55
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false

	SWEP.Slot				= 1
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "j"
end

SWEP.Category				= "Backsword"

SWEP.HoldType				= "fist"

SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

SWEP.ViewModel 				= "models/weapons/c_arms.mdl"
SWEP.WorldModel 			= ""
SWEP.UseHands				= true

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.Damage			= 2
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			="none"
SWEP.DrawAmmo 				= false

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Damage		= 100
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= ""

SWEP.WallSound 				= Sound("Flesh.ImpactHard")
SWEP.SwingSound				= Sound("WeaponFrag.Throw")
SWEP.HitDistance			= 38
SWEP.LoweredAngles 			= Angle(0.000, 0.000, -22.000)

/*---------------------------------------------------------
Initialize
---------------------------------------------------------*/
function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end

/*---------------------------------------------------------
Deploy
---------------------------------------------------------*/
function SWEP:Deploy()
	local vm = self.Owner:GetViewModel()

	vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_draw"))
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)

	return true
end

/*---------------------------------------------------------
PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	if (SERVER) then
		if (hook.Run("PlayerCanThrowPunch", self.Owner)) then
			self:PlayPunchAnimation()
			self.Owner:SetAnimation(PLAYER_ATTACK1)
			self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
			self.Weapon:SetNextSecondaryFire(CurTime() + 0.7)
			timer.Simple(0.10, function ()self.Weapon:EmitSound(self.SwingSound); end)
			self.Primary.Damage = self.Primary.Damage --+ cw.attributes:Get(self.Owner, ATB_MELEE, nil, true) * 0.03 + cw.attributes:Get(self.Owner, ATB_STRENGTH, nil, true) * 0.03

			local trace = self.Owner:GetEyeTraceNoCursor()

			if (self.Owner:GetShootPos():Distance(trace.HitPos) <= 64) then
				if (IsValid(trace.Entity)) then
					if (trace.Entity:IsPlayer() or trace.Entity:IsNPC() or trace.Entity:GetClass() == "prop_ragdoll") then
						if (trace.Entity:IsPlayer() and trace.Entity:Health() - self.Primary.Damage <= 30
						and hook.Run("PlayerCanPunchKnockout", self.Owner, trace.Entity, trace)) then
							cw.player:SetRagdollState(trace.Entity, RAGDOLL_KNOCKEDOUT, 15)
							hook.Run("PlayerPunchKnockout", self.Owner, trace.Entity)
						elseif (hook.Run("PlayerCanPunchEntity", self.Owner, trace.Entity)) then
							self:PunchEntity()
							hook.Run("PlayerPunchEntity", self.Owner, trace.Entity)
						end

						if (trace.Entity:IsPlayer() or trace.Entity:IsNPC()) then
							local normal = trace.Entity:GetPos() - self.Owner:GetPos()
								normal:Normalize()
							local push = 128 * normal

							trace.Entity:SetVelocity(push)
						end
					elseif (IsValid(trace.Entity:GetPhysicsObject())) then
						if (hook.Run("PlayerCanPunchEntity", self.Owner, trace.Entity)) then
							self:PunchEntity()

							hook.Run("PlayerPunchEntity", self.Owner, trace.Entity)
						end
					elseif (trace.Hit) then
						self:PunchEntity()
					end
				elseif (trace.Hit) then
					self:PunchEntity()
				end
			end

			hook.Run("PlayerPunchThrown", self.Owner)

			local info = {
				primaryFire = 0.5,
				secondaryFire = 0.5
			}

			hook.Run("PlayerAdjustNextPunchInfo", self.Owner, info)

			self.Weapon:SetNextPrimaryFire(CurTime() + info.primaryFire)
			self.Weapon:SetNextSecondaryFire(CurTime() + info.secondaryFire)

			self.Owner:ViewPunch(Angle(
				math.Rand(-16, 16), math.Rand(-8, 8), 0
			))
		end
	end
end

/*---------------------------------------------------------
SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	if (SERVER) then
		local trace = self.Owner:GetEyeTraceNoCursor()

		if (IsValid(trace.Entity) and cw.entity:IsDoor(trace.Entity)) then
			if (self.Owner:GetShootPos():Distance(trace.HitPos) <= 64) then
				if (hook.Run("PlayerCanKnockOnDoor", self.Owner, trace.Entity) != false) then
					self:PlayKnockSound()

					self.Weapon:SetNextPrimaryFire(CurTime() + 0.25)
					self.Weapon:SetNextSecondaryFire(CurTime() + 0.25)

					hook.Run("PlayerKnockOnDoor", self.Owner, trace.Entity)
				end
			end
		end
	end
end

/*---------------------------------------------------------
KnockSound
---------------------------------------------------------*/
function SWEP:PlayKnockSound()
	if (SERVER) then
		self.Weapon:CallOnClient("PlayKnockSound", "")
	end

	self.Weapon:EmitSound("physics/wood/wood_crate_impact_hard2.wav")
end

/*---------------------------------------------------------
Reload
---------------------------------------------------------*/
function SWEP:Reload()

	return false
end

/*---------------------------------------------------------
OnRemove
---------------------------------------------------------*/
function SWEP:OnRemove()

	return true
end

/*---------------------------------------------------------
Holster
---------------------------------------------------------*/
function SWEP:Holster()

	return true
end

/*---------------------------------------------------------
ShootEffects
---------------------------------------------------------*/
function SWEP:ShootEffects() end

/*---------------------------------------------------------
OnDrop
---------------------------------------------------------*/
function SWEP:OnDrop()
	self:Remove()
end

/*---------------------------------------------------------
SetupDataTables
---------------------------------------------------------*/
function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "NextMeleeAttack")
 	self:NetworkVar("Float", 1, "NextIdle")
end

/*---------------------------------------------------------
UpdateNextIdle
---------------------------------------------------------*/
function SWEP:UpdateNextIdle()
 	local vm = self.Owner:GetViewModel()

 	self:SetNextIdle(CurTime() + vm:SequenceDuration())
end

/*---------------------------------------------------------
PunchEntity
---------------------------------------------------------*/
function SWEP:PunchEntity()
	local bounds = Vector(0, 0, 0)
	local startPosition = self.Owner:GetShootPos()
	local finishPosition = startPosition + (self.Owner:GetAimVector() * 64)
	local traceLineAttack = util.TraceLine({
		start = startPosition,
		endpos = finishPosition,
		filter = self.Owner
	})

	timer.Simple(0.32, function ()
		if (IsValid(self.Weapon)) then
			self.Weapon:EmitSound(self.WallSound)
		end
	end)

	if (SERVER) then
		self.Weapon:CallOnClient("PunchEntity", "")

		if (IsValid(traceLineAttack.Entity)) then
			traceLineAttack.Entity:TakeDamageInfo(
				cw.core:FakeDamageInfo(self.Primary.Damage, self, self.Owner, traceLineAttack.HitPos, DMG_CLUB, 1)
			)
		end
	end
end

-- A function to play the punch animation.
/*---------------------------------------------------------
PunchingAnimation
---------------------------------------------------------*/
function SWEP:PlayPunchAnimation()
	if (SERVER) then
		self.Weapon:CallOnClient("PlayPunchAnimation", "")
	end

 	if (self.left == nil) then self.left = true; else self.left = !self.left; end

	local anim = "fists_right"
	local ownerAnim = PLAYER_ATTACK1

 	if (self.left) then
		anim = "fists_left"
		--ownerAnim = PLAYER_ATTACK2
	end

 	local vm = self.Owner:GetViewModel()

 	self.Owner:SetAnimation(ownerAnim)
 	vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))
end
