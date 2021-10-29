--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

include("shared.lua")

local glowMaterial = Material("sprites/glow04_noz")

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = cw.option:GetColor("target_id")
	local colorWhite = cw.option:GetColor("white")
	local frequency = self:GetFrequency()

	y = cw.core:DrawInfo("Radio", x, y, colorTargetID, alpha)

	if (frequency == 0) then
		y = cw.core:DrawInfo("This radio has no frequency.", x, y, colorWhite, alpha)
	else
		y = cw.core:DrawInfo(frequency, x, y, colorWhite, alpha)
	end
end

-- Called when the entity should draw.
function ENT:Draw()
	self:DrawModel()

	local r, g, b, a = self:GetColor()
	local glowColor = Color(0, 255, 0, a)
	local position = self:GetPos()
	local forward = self:GetForward() * 9
	local right = self:GetRight() * 5
	local up = self:GetUp() * 8

	if (self:IsOff()) then
		glowColor = Color(255, 0, 0, a)
	end

	cam.Start3D(EyePos(), EyeAngles())
		render.SetMaterial(glowMaterial)
		render.DrawSprite(position + forward + right + up, 16, 16, glowColor)
	cam.End3D()
end
