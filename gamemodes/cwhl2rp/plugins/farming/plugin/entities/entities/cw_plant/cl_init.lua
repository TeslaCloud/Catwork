--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = cw.option:GetColor("target_id")
	local colorWhite = cw.option:GetColor("white")
	local itemTable = item.FindByID(self:GetItem())

	y = cw.core:DrawInfo(itemTable.PlantName, x, y, colorTargetID, alpha)

	if (cw.attributes:Fraction(ATB_FARM, 100) > 25) then
		local GrowthPercent = math.Clamp(math.Round((CurTime() - self:GetSpawnTime()) / (self:GetGrowTime() - self:GetSpawnTime()) * 100), 0, 100)
		y = cw.core:DrawInfo("Зрелость: "..GrowthPercent.."%", x, y, Color(255, 255, 255), alpha)
	end
end

include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

function ENT:Initialize()

end

function ENT:Think()

end
