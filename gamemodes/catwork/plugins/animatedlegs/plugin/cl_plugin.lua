--- Client-side functions and state of the Animated Legs plugin, which shows the local player their own legs in first
-- person.
--
-- `cwAnimatedLegs:CreateLegs` makes a clientside copy of the player's model, `cwAnimatedLegs:LegsThink` keeps it in
-- sync with the player's animation, and `cwAnimatedLegs:WeaponChanged` hides the upper-body bones listed in
-- `cwAnimatedLegs.BoneHoldTypes` for the current hold type. The legs are not drawn for the `FACTION_VORT` and
-- `FACTION_VORT_SLAVE` factions.

cwAnimatedLegs.BoneHoldTypes = {
  ['none'] = {
    'ValveBiped.Bip01_Head1',
    'ValveBiped.Bip01_Neck1',
    'ValveBiped.Bip01_Spine4',
    'ValveBiped.Bip01_Spine2'
  },
  ['fist'] = {
    'ValveBiped.Bip01_Head1',
    'ValveBiped.Bip01_Neck1',
    'ValveBiped.Bip01_Spine4',
    'ValveBiped.Bip01_Spine2'
  },
  ['chair'] = {
    'ValveBiped.Bip01_Head1',
    'ValveBiped.Bip01_Neck1',
    'ValveBiped.Bip01_Spine4',
    'ValveBiped.Bip01_Spine2',
    'ValveBiped.Bip01_R_Upperarm',
    'ValveBiped.Bip01_L_Upperarm',
    'ValveBiped.Bip01_R_Clavicle',
    'ValveBiped.Bip01_L_Clavicle'
  },
  ['default'] = {
    'ValveBiped.Bip01_Head1',
    'ValveBiped.Bip01_L_Hand',
    'ValveBiped.Bip01_L_Forearm',
    'ValveBiped.Bip01_L_Upperarm',
    'ValveBiped.Bip01_L_Clavicle',
    'ValveBiped.Bip01_R_Hand',
    'ValveBiped.Bip01_R_Forearm',
    'ValveBiped.Bip01_R_Upperarm',
    'ValveBiped.Bip01_R_Clavicle',
    'ValveBiped.Bip01_L_Finger4',
    'ValveBiped.Bip01_L_Finger41',
    'ValveBiped.Bip01_L_Finger42',
    'ValveBiped.Bip01_L_Finger3',
    'ValveBiped.Bip01_L_Finger31',
    'ValveBiped.Bip01_L_Finger32',
    'ValveBiped.Bip01_L_Finger2',
    'ValveBiped.Bip01_L_Finger21',
    'ValveBiped.Bip01_L_Finger22',
    'ValveBiped.Bip01_L_Finger1',
    'ValveBiped.Bip01_L_Finger11',
    'ValveBiped.Bip01_L_Finger12',
    'ValveBiped.Bip01_L_Finger0',
    'ValveBiped.Bip01_L_Finger01',
    'ValveBiped.Bip01_L_Finger02',
    'ValveBiped.Bip01_R_Finger4',
    'ValveBiped.Bip01_R_Finger41',
    'ValveBiped.Bip01_R_Finger42',
    'ValveBiped.Bip01_R_Finger3',
    'ValveBiped.Bip01_R_Finger31',
    'ValveBiped.Bip01_R_Finger32',
    'ValveBiped.Bip01_R_Finger2',
    'ValveBiped.Bip01_R_Finger21',
    'ValveBiped.Bip01_R_Finger22',
    'ValveBiped.Bip01_R_Finger1',
    'ValveBiped.Bip01_R_Finger11',
    'ValveBiped.Bip01_R_Finger12',
    'ValveBiped.Bip01_R_Finger0',
    'ValveBiped.Bip01_R_Finger01',
    'ValveBiped.Bip01_R_Finger02'
  },
  ['vehicle'] = {
    'ValveBiped.Bip01_Head1',
    'ValveBiped.Bip01_Neck1',
    'ValveBiped.Bip01_Spine4',
    'ValveBiped.Bip01_Spine2'
  }
}

cwAnimatedLegs.PlaybackRate = 1
cwAnimatedLegs.OldWeapon = nil
cwAnimatedLegs.Sequence = nil
cwAnimatedLegs.Velocity = 0
cwAnimatedLegs.HoldType = nil
cwAnimatedLegs.ForwardOffset = -24
cwAnimatedLegs.BonesToRemove = {}
cwAnimatedLegs.RenderAngle = nil
cwAnimatedLegs.RenderColor = {}
cwAnimatedLegs.BreathScale = 0.5
cwAnimatedLegs.BoneMatrix = nil
cwAnimatedLegs.NextBreath = 0
cwAnimatedLegs.BiaisAngle = nil
cwAnimatedLegs.ClipVector = vector_up * -1
cwAnimatedLegs.RenderPos = nil
cwAnimatedLegs.RadAngle = nil

--- Returns whether the local player's legs should be drawn this frame.
--
-- False when the legs model does not exist, the player is dead, in third person, observing another
-- entity, viewing through another entity, in a vehicle without third-person mode, or in the
-- `FACTION_VORT` or `FACTION_VORT_SLAVE` faction.
--
-- @return [Boolean Whether to draw the legs]
function cwAnimatedLegs:ShouldDrawLegs()
  return IsValid(self.LegsEntity) and cw.client:Alive()
  and self:CheckDrawVehicle() and GetViewEntity() == cw.client
  and !cw.client:ShouldDrawLocalPlayer() and !IsValid(cw.client:GetObserverTarget())
  and cw.client:GetFaction() != FACTION_VORT
  and cw.client:GetFaction() != FACTION_VORT_SLAVE
end

--- Returns whether the local player's vehicle state allows drawing the legs.
--
-- @return [Boolean True when the player is not in a vehicle, or the vehicle is in third-person mode]
function cwAnimatedLegs:CheckDrawVehicle()
  return cw.client:InVehicle()
  and (cw.client:GetVehicle() and cw.client:GetVehicle():GetThirdPersonMode())
  or !cw.client:InVehicle()
end

--- Creates the clientside legs model from the local player's model, skin and material.
--
-- The model is stored in `cwAnimatedLegs.LegsEntity` and set not to draw on its own; it is drawn
-- manually in the `RenderScreenspaceEffects` hook.
function cwAnimatedLegs:CreateLegs()
  self.LegsEntity = ClientsideModel(cw.client:GetModel(), RENDER_GROUP_OPAQUE_ENTITY)
  self.LegsEntity:SetNoDraw(true)
  self.LegsEntity:SetSkin(cw.client:GetSkin())
  self.LegsEntity:SetMaterial(cw.client:GetMaterial())
  self.LegsEntity.LastTick = 0
end

--- Updates the legs model's hold type and hides the bones that should not be visible.
--
-- Resets every bone, then shrinks and moves away the bones listed in `cwAnimatedLegs.BoneHoldTypes` for
-- the weapon's hold type, or the vehicle or chair set when the player is seated. Does nothing when the
-- legs model does not exist.
--
-- @param weapon [Weapon The newly active weapon; an invalid weapon uses the `none` hold type]
function cwAnimatedLegs:WeaponChanged(weapon)
  if IsValid(self.LegsEntity) then
    if IsValid(weapon) then
      self.HoldType = weapon.HoldType
    else
      self.HoldType = 'none'
    end

    for i = 0, self.LegsEntity:GetBoneCount() do
      self.LegsEntity:ManipulateBoneScale(i, Vector(1, 1, 1))
      self.LegsEntity:ManipulateBonePosition(i, vector_origin)
    end

    self.BonesToRemove = { 'ValveBiped.Bip01_Head1' }

    if !cw.client:InVehicle() then
      if (self.HoldType != 'fist' or !cw.client:IsWeaponRaised())
      and self.BoneHoldTypes[self.HoldType] then
        self.BonesToRemove = self.BoneHoldTypes[self.HoldType]
      else
        self.BonesToRemove = self.BoneHoldTypes['default']
      end
    elseif !cw.entity:IsChairEntity(cw.client:GetVehicle()) then
      self.BonesToRemove = self.BoneHoldTypes['vehicle']
    else
      self.BonesToRemove = self.BoneHoldTypes['chair']
    end

    for k, v in pairs(self.BonesToRemove) do
      local bone = self.LegsEntity:LookupBone(v)

      if bone then
        self.LegsEntity:ManipulateBoneScale(bone, vector_origin)
        self.LegsEntity:ManipulateBonePosition(bone, Vector(-10, -10, 0))
      end
    end
  end
end

--- Syncs the legs model with the local player for the current frame.
--
-- Calls `cwAnimatedLegs:WeaponChanged` when the active weapon changed, and copies the model, material,
-- skin, sequence, playback rate and pose parameters from the player. Does nothing when the legs model
-- does not exist.
--
-- @param maxSeqGroundSpeed [Number Ground speed of the current sequence; the playback rate is the
-- player's 2D speed divided by it, clamped to 0.01-10]
function cwAnimatedLegs:LegsThink(maxSeqGroundSpeed)
  local curTime = CurTime()

  if IsValid(self.LegsEntity) then
    if cw.client:GetActiveWeapon() != self.OldWeapon then
      self.OldWeapon = cw.client:GetActiveWeapon()
      self:WeaponChanged(self.OldWeapon)
    end

    if self.LegsEntity:GetModel() != cw.client:GetModel() then
      self.LegsEntity:SetModel(cw.client:GetModel())
    end

    self.LegsEntity:SetMaterial(cw.client:GetMaterial())
    self.LegsEntity:SetSkin(cw.client:GetSkin())
    self.Velocity = cw.client:GetVelocity():Length2D()
    self.PlaybackRate = 1

    if self.Velocity > 0.5 then
      if maxSeqGroundSpeed < 0.001 then
        self.PlaybackRate = 0.01
      else
        self.PlaybackRate = self.Velocity / maxSeqGroundSpeed
        self.PlaybackRate = math.Clamp(self.PlaybackRate, 0.01, 10)
      end
    end

    self.LegsEntity:SetPlaybackRate(self.PlaybackRate)
    self.Sequence = cw.client:GetSequence()

    if self.LegsEntity.Anim != self.Sequence then
      self.LegsEntity.Anim = self.Sequence
      self.LegsEntity:ResetSequence(self.Sequence)
    end

    self.LegsEntity:FrameAdvance(curTime - self.LegsEntity.LastTick)
    self.LegsEntity.LastTick = curTime

    if self.NextBreath <= curTime then
      self.NextBreath = curTime + 1.95 / self.BreathScale
      self.LegsEntity:SetPoseParameter('breathing', self.BreathScale)
    end

    self.LegsEntity:SetPoseParameter('move_yaw', (cw.client:GetPoseParameter('move_yaw') * 360) - 180)
    self.LegsEntity:SetPoseParameter('body_yaw', (cw.client:GetPoseParameter('body_yaw') * 180) - 90)
    self.LegsEntity:SetPoseParameter('spine_yaw', (cw.client:GetPoseParameter('spine_yaw') * 180) - 90)

    if cw.client:InVehicle() then
      self.LegsEntity:SetColor(color_transparent)
      self.LegsEntity:SetPoseParameter(
        'vehicle_steer',
        (cw.client:GetVehicle():GetPoseParameter('vehicle_steer') * 2) - 1
      )
    end
  end
end
