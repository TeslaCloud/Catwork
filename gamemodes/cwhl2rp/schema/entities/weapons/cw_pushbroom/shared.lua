--- Defines the `cw_pushbroom` weapon, a push broom for sweeping rubbish that has no view model and shows a broom prop
-- in the owner's hand instead.
--
-- While it is raised the server forces the owner's sweeping, idle or walking broom animation, and primary fire plays a
-- two second sweep.

if SERVER then
  AddCSLuaFile('shared.lua')
end

if CLIENT then
  SWEP.Slot = 0
  SWEP.SlotPos = 7
  SWEP.DrawAmmo = false
  SWEP.PrintName = '#SWEPS_Pushbroom'
  SWEP.DrawCrosshair = true
end

SWEP.Author = 'NA'
SWEP.Instructions = '#SWEPS_Pushbroom_Instructions'
SWEP.Purpose = '#SWEPS_Pushbroom_Purpose'
SWEP.Contact = ''

SWEP.AdminSpawnable = false
SWEP.Spawnable = true

-- SWEP.ViewModel = "models/weapons/v_hands.mdl" -- causes console error spam
SWEP.WorldModel = ''

SWEP.HoldType = 'melee'

SWEP.Primary.Delay = 0.2 -- In seconds
SWEP.Primary.Recoil			= 0 -- Gun Kick
SWEP.Primary.Damage			= 0 -- Damage per Bullet
SWEP.Primary.NumShots = 1 -- Number of shots per one fire
SWEP.Primary.Cone = 0 -- Bullet Spread
SWEP.Primary.ClipSize = -1	-- Use "-1 if there are no clips"
SWEP.Primary.DefaultClip = -1 -- Number of shots in next clip
SWEP.Primary.Automatic = false -- Pistol fire (false) or SMG fire (true)
SWEP.Primary.Ammo         	= 'none' -- Ammo Type

SWEP.Secondary.NeverRaised = true
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Delay = 1
SWEP.Secondary.Ammo = ''

--- Sets the melee hold type.
function SWEP:Initialize()
  self:SetHoldType(self.HoldType)
end

--- Hides the view model and attaches a push broom prop to the owner's hand on the server.
-- @return [Boolean Always `true` to allow the deploy]
function SWEP:Deploy()
  -- ents.Create only exists serverside.
  if SERVER then
    self.Owner:DrawViewModel(false) -- Workaround for viewmodel error spam

    if IsValid(self.Owner.broomProp) then
      self.Owner.broomProp:Remove()
    end

    self.Owner.broomProp = ents.Create('prop_dynamic')
    self.Owner.broomProp:SetModel('models/props_c17/pushbroom.mdl')
    self.Owner.broomProp:DrawShadow(true)
    self.Owner.broomProp:SetMoveType(MOVETYPE_NONE)
    self.Owner.broomProp:SetParent(self.Owner)
    self.Owner.broomProp:SetSolid(SOLID_NONE)
    self.Owner.broomProp:Spawn()
    self.Owner.broomProp:Fire('setparentattachment', 'cleaver_attachment', 0.01)

    -- OnRemove cannot reach the prop when the weapon is removed after losing its owner.
    self:DeleteOnRemove(self.Owner.broomProp)
  end

  return true
end

--- Shows the view model again and removes the broom prop and the forced animation.
-- @return [Boolean Always `true` to allow the holster]
function SWEP:Holster()
  if SERVER then
    self.Owner:DrawViewModel(true) -- Workaround for viewmodel error spam
  end

  if self.Owner.broomProp then
    if self.Owner.broomProp:IsValid() then
      self.Owner.broomProp:Remove()
      self.Owner:SetForcedAnimation(false)
    end
  end

  return true
end

--- Forces the owner's sweeping, idle or walking broom animation while the broom is raised.
--
-- Runs on the server. Standing still or in the air plays the two second sweep after a primary attack and
-- the idle sweep otherwise; moving on the ground plays the walking animation.
function SWEP:Think()
  if SERVER then
    local currentAnim = self.Owner:GetForcedAnimation() -- Get the player's current animation for checks

    if cw.player:GetWeaponRaised(self.Owner) then
      if self.Owner:GetVelocity() == vector_origin or !self.Owner:OnGround() then
        local curTime = CurTime()

        if self.isSweep then
          if !self.nextSweep then
            self.nextSweep = curTime + 2
          end

          -- If the player's animation is not the one we're trying to set
          if currentAnim and currentAnim.animation != 'sweep' then
            self.Owner:SetForcedAnimation(false) -- then remove their forced animation so it can be set to the new one.
          end

          self.Owner:SetForcedAnimation('sweep', 0, nil)

          if self.nextSweep then
            if curTime >= self.nextSweep then
              self.isSweep = nil
              self.nextSweep = nil
            end
          end
        else
          -- If the player's animation is not the one we're trying to set
          if currentAnim and currentAnim.animation != 'sweep_idle' then
            self.Owner:SetForcedAnimation(false) -- then remove their forced animation so it can be set to the new one.
          end

          self.Owner:SetForcedAnimation('sweep_idle', 0, nil)
        end
      else
        -- If the player's animation is not the one we're trying to set
        if currentAnim and currentAnim.animation != 'Walk_all_HoldBroom' then
          self.Owner:SetForcedAnimation(false) -- then remove their forced animation so it can be set to the new one.
        end

        self.Owner:SetForcedAnimation('Walk_all_HoldBroom', 0, nil)
      end
    end
  end
end

--- Shows the view model again and removes the broom prop and the forced animation.
-- @return [Boolean Always `true`]
function SWEP:OnRemove()
  -- The owner is already gone when the weapon is removed along with a disconnecting player.
  if !IsValid(self.Owner) then return end

  if SERVER then
    self.Owner:DrawViewModel(true) -- Workaround for viewmodel error spam
  end

  if self.Owner.broomProp then
    if self.Owner.broomProp:IsValid() then
      self.Owner.broomProp:Remove()
      self.Owner:SetForcedAnimation(false)
    end
  end

  return true
end

--- Clears the owner's forced broom animation on the server.
function SWEP:OnLowered()
  if SERVER then
    self.Owner:SetForcedAnimation(false)
  end
end

--- Starts a sweep, which `SWEP:Think` plays, unless one is already running.
function SWEP:PrimaryAttack()
  if !self.nextSweep then
    if !self.isSweep then
      self.isSweep = true
    end
  end
end

--- Does nothing.
-- @return [Boolean Always `false`]
function SWEP:SecondaryAttack()
  return false
end
