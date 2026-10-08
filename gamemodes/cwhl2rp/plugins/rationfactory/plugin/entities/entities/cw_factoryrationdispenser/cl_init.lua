--- Client side of the `cw_factoryrationdispenser` entity of the Ration Factory plugin, which draws the status light and
-- shows the ration count to Combine players.
--
-- The light blinks blue while a ration is being dispensed, turns red while flashing a denial, and is orange when the
-- dispenser is locked and green otherwise.
--
-- Originally written for the Iron Wall community.

include('shared.lua')

local glowMaterial = Material('sprites/glow04_noz')

--- Draws the dispenser's name and ration count for Combine players looking at it.
function ENT:HUDPaintTargetID(x, y, alpha)
  local colorTargetID = cw.option:GetColor('target_id')
  local colorWhite = cw.option:GetColor('white')

  if Schema:PlayerIsCombine(cw.client) then
    y = cw.core:DrawInfo('#Factory_RationDispenser', x, y, colorTargetID, alpha)
    y = cw.core:DrawInfo('#Factory_FillState '..self:GetDTInt(0), x, y, colorWhite, alpha)
  end
end

--- Draws the status light: blinking blue while dispensing, red when flashing, orange when locked, else green.
function ENT:Draw()
  local a = self:GetColor().a
  local rationTime = self:GetDTFloat(0)
  local flashTime = self:GetDTFloat(1)
  local position = self:GetPos()
  local forward = self:GetForward() * 8
  local curTime = CurTime()
  local right = self:GetRight() * 5
  local up = self:GetUp() * 13

  if rationTime > curTime then
    local glowColor = Color(0, 0, 255, a)
    local timeLeft = rationTime - curTime

    if !self.nextFlash or curTime >= self.nextFlash or (self.flashUntil and self.flashUntil > curTime) then
      cam.Start3D(EyePos(), EyeAngles())
        render.SetMaterial(glowMaterial)
        render.DrawSprite(position + forward + right + up, 20, 20, glowColor)
      cam.End3D()

      if !self.flashUntil or curTime >= self.flashUntil then
        self.nextFlash = curTime + (timeLeft / 4)
        self.flashUntil = curTime + (FrameTime() * 4)
        self:EmitSound('hl1/fvox/boop.wav')
      end
    end
  else
    local glowColor = Color(0, 255, 0, a)

    if self:IsLocked() then
      glowColor = Color(255, 150, 0, a)
    end

    if flashTime and flashTime >= curTime then
      glowColor = Color(255, 0, 0, a)
    end

    cam.Start3D(EyePos(), EyeAngles())
      render.SetMaterial(glowMaterial)
      render.DrawSprite(position + forward + right + up, 20, 20, glowColor)
    cam.End3D()
  end
end
