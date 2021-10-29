--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

include("shared.lua")

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = cw.option:GetColor("target_id")
	local colorWhite = cw.option:GetColor("white")
	local amount = self:GetDTInt(0)

	y = cw.core:DrawInfo(cw.option:GetKey("name_cash"), x, y, colorTargetID, alpha)
	y = cw.core:DrawInfo(cw.core:FormatCash(amount), x, y, colorWhite, alpha)
end

-- Called when the entity should draw.
function ENT:Draw()
	if (hook.Run("CashEntityDraw", self) != false) then
		self:DrawModel()
	end
end
