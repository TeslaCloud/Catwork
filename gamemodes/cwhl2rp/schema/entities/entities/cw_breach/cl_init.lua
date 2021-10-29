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

	y = cw.core:DrawInfo("Breach", x, y, colorTargetID, alpha)
	y = cw.core:DrawInfo("It can be directly charged.", x, y, colorWhite, alpha)
end

-- Called when the entity should draw.
function ENT:Draw() self:DrawModel(); end
