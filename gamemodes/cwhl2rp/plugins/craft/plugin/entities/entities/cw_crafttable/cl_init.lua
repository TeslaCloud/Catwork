include("shared.lua")

function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = cw.option:GetColor("target_id")

	y = cw.core:DrawInfo(self.PrintName, x, y, colorTargetID, alpha)
end

function ENT:Draw()
	self:DrawModel()
end