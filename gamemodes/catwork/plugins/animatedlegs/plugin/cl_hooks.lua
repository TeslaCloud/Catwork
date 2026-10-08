--- Client-side hooks of the Animated Legs plugin that update and draw the local player's legs model.
--
-- `UpdateAnimation` creates the legs or syncs them with the player, and `RenderScreenspaceEffects` draws them clipped
-- below the eyes and then runs the `PostDrawAnimatedLegs` hook.

--- Called when a player's animation is updated; creates or advances the local player's legs model.
--
-- Only acts for the local player: creates the legs with `cwAnimatedLegs:CreateLegs` if they do not exist
-- yet, otherwise syncs them with `cwAnimatedLegs:LegsThink`.
--
-- @param player [Player The player whose animation is updated]
-- @param velocity [Vector The player's velocity]
-- @param maxSeqGroundSpeed [Number Ground speed of the current sequence, used to scale the playback rate]
function cwAnimatedLegs:UpdateAnimation(player, velocity, maxSeqGroundSpeed)
  if cw.client == player then
    if IsValid(self.LegsEntity) then
      self:LegsThink(maxSeqGroundSpeed)
    else
      self:CreateLegs()
    end
  end
end

--- Called when screenspace effects are rendered; draws the local player's legs model.
--
-- Positions the legs behind the player's eye position (or in the vehicle seat), tints them with the
-- player's color, clips everything above the eyes and runs the `PostDrawAnimatedLegs` hook with the
-- legs entity, render position and render angle. Does nothing when `cwAnimatedLegs:ShouldDrawLegs`
-- returns false.
function cwAnimatedLegs:RenderScreenspaceEffects()
  if !self:ShouldDrawLegs() then return end

  cam.Start3D(EyePos(), EyeAngles())
    self.RenderPos = cw.client:GetPos()

    if !cw.client:InVehicle() then
      self.BiasAngles = cw.client:EyeAngles()
      self.RenderAngle = Angle(0, self.BiasAngles.y, 0)
      self.RadAngle = math.rad(self.BiasAngles.y)
      self.ForwardOffset = -12 + (1 - (math.Clamp(self.BiasAngles.p - 45, 0, 45) / 45) * 7)
      self.RenderPos.x = self.RenderPos.x + math.cos(self.RadAngle) * self.ForwardOffset
      self.RenderPos.y = self.RenderPos.y + math.sin(self.RadAngle) * self.ForwardOffset

      if cw.client:GetGroundEntity() == NULL then
        self.RenderPos.z = self.RenderPos.z + 8

        if cw.client:KeyDown(IN_DUCK) then
          self.RenderPos.z = self.RenderPos.z - 28
        end
      end
    else
      self.RenderAngle = cw.client:GetVehicle():GetAngles()
      self.RenderAngle:RotateAroundAxis(self.RenderAngle:Up(), 90)
    end

    self.RenderColor = cw.client:GetColor(true)

    render.EnableClipping(true)
    render.PushCustomClipPlane(self.ClipVector, self.ClipVector:Dot(EyePos()))
    render.SetColorModulation(self.RenderColor.r / 255, self.RenderColor.g / 255, self.RenderColor.b / 255)
    render.SetBlend(self.RenderColor.a / 255)

    self.LegsEntity:SetRenderOrigin(self.RenderPos)
    self.LegsEntity:SetRenderAngles(self.RenderAngle)
    self.LegsEntity:SetupBones()
    self.LegsEntity:DrawModel()
    self.LegsEntity:SetRenderOrigin()
    self.LegsEntity:SetRenderAngles()

    render.SetBlend(1)
    render.SetColorModulation(1, 1, 1)

    hook.Run('PostDrawAnimatedLegs', self.LegsEntity, self.RenderPos, self.RenderAngle)

    render.PopCustomClipPlane()
    render.EnableClipping(false)
  cam.End3D()
end
