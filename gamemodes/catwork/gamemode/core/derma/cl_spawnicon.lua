--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local PANEL = {}

--- Draws the cooldown overlay and the colored border over the icon.
function PANEL:Init()
  self.Icon.PaintOver = function(icon)
    local curTime = CurTime()

    if self.Cooldown and self.Cooldown.expireTime > curTime then
      local timeLeft = self.Cooldown.expireTime - curTime
      local progress = 100 - ((100 / self.Cooldown.duration) * timeLeft)

      cw.cooldown:DrawBox(
        self.x,
        self.y,
        self:GetWide(),
        self:GetTall(),
        progress, Color(255, 255, 255, 255 - ((255 / 100) * progress)),
        self.Cooldown.textureID
      )
    end

    if self.BorderColor then
      local alpha = math.min(self.BorderColor.a, self:GetAlpha())
      cw.SpawnIconMaterial:SetVector(
        '$color',
        Vector(self.BorderColor.r / 255, self.BorderColor.g / 255, self.BorderColor.b / 255)
      )
      cw.SpawnIconMaterial:SetFloat('$alpha', alpha / 255)
        surface.SetDrawColor(self.BorderColor.r, self.BorderColor.g, self.BorderColor.b, alpha)
        surface.SetMaterial(cw.SpawnIconMaterial)
        self:DrawTexturedRect()
      cw.SpawnIconMaterial:SetFloat('$alpha', 1)
      cw.SpawnIconMaterial:SetVector('$color', Vector(1, 1, 1))
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
