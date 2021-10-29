--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local PANEL = {}

-- Called when the panel is initialized.
function PANEL:Init()
	self.Icon.PaintOver = function(icon)
		local curTime = CurTime()

		if (self.Cooldown and self.Cooldown.expireTime > curTime) then
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

		if (self.BorderColor) then
			local alpha = math.min(self.BorderColor.a, self:GetAlpha())
			cw.SpawnIconMaterial:SetVector("$color", Vector(self.BorderColor.r / 255, self.BorderColor.g / 255, self.BorderColor.b / 255))
			cw.SpawnIconMaterial:SetFloat("$alpha", alpha / 255)
				surface.SetDrawColor(self.BorderColor.r, self.BorderColor.g, self.BorderColor.b, alpha)
				surface.SetMaterial(cw.SpawnIconMaterial)
				self:DrawTexturedRect()
			cw.SpawnIconMaterial:SetFloat("$alpha", 1)
			cw.SpawnIconMaterial:SetVector("$color", Vector(1, 1, 1))
		end
	end
end

-- A function to set the border color.
function PANEL:SetColor(color)
	self.BorderColor = color
end

-- A function to set the cooldown.
function PANEL:SetCooldown(expireTime, textureID)
	self.Cooldown = {
		expireTime = expireTime,
		textureID = textureID or surface.GetTextureID("vgui/white"),
		duration = expireTime - CurTime()
	}
end

vgui.Register("cwSpawnIcon", PANEL, "SpawnIcon");
