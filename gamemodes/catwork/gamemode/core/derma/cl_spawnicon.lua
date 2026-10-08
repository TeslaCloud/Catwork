--- Defines `cwSpawnIcon`, a `SpawnIcon` that draws a colored border set with `SetColor` and a fading cooldown overlay
-- set with `SetCooldown`.

-- Reused every frame by the paint function below instead of allocating new objects.
local cooldownColor = Color(255, 255, 255, 255)
local borderVector = Vector(1, 1, 1)
local whiteVector = Vector(1, 1, 1)

local PANEL = {}

--- Draws the cooldown overlay and the colored border over the icon.
function PANEL:Init()
  self.Icon.PaintOver = function(icon)
    local curTime = CurTime()

    if self.Cooldown and self.Cooldown.expireTime > curTime then
      local timeLeft = self.Cooldown.expireTime - curTime
      local progress = 100 - ((100 / self.Cooldown.duration) * timeLeft)

      cooldownColor.a = 255 - ((255 / 100) * progress)

      cw.cooldown:DrawBox(
        self.x,
        self.y,
        self:GetWide(),
        self:GetTall(),
        progress, cooldownColor,
        self.Cooldown.textureID
      )
    end

    if self.BorderColor then
      local alpha = math.min(self.BorderColor.a, self:GetAlpha())

      borderVector.x = self.BorderColor.r / 255
      borderVector.y = self.BorderColor.g / 255
      borderVector.z = self.BorderColor.b / 255

      cw.SpawnIconMaterial:SetVector('$color', borderVector)
      cw.SpawnIconMaterial:SetFloat('$alpha', alpha / 255)
        surface.SetDrawColor(self.BorderColor.r, self.BorderColor.g, self.BorderColor.b, alpha)
        surface.SetMaterial(cw.SpawnIconMaterial)
        self:DrawTexturedRect()
      cw.SpawnIconMaterial:SetFloat('$alpha', 1)
      cw.SpawnIconMaterial:SetVector('$color', whiteVector)
    end
  end
end

--- Sets the color of the border drawn over the icon.
-- @param color [Color Border color, or `nil` to draw no border]
function PANEL:SetColor(color)
  self.BorderColor = color
end

--- Shows a cooldown overlay on the icon that fades out until the given time.
-- @param expireTime [Number `CurTime` at which the cooldown ends]
-- @param textureID=nil [Number Texture ID of the overlay; defaults to `vgui/white`]
function PANEL:SetCooldown(expireTime, textureID)
  self.Cooldown = {
    expireTime = expireTime,
    textureID = textureID or surface.GetTextureID('vgui/white'),
    duration = expireTime - CurTime()
  }
end

vgui.Register('cwSpawnIcon', PANEL, 'SpawnIcon')
