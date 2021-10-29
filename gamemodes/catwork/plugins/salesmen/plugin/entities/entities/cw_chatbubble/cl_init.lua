--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

util.Include("shared.lua")

-- Called when the entity is drawn.
function ENT:Draw()
	self:SetModelScale(0.6, 0)
	self:DrawModel()
end

-- Called every frame.
function ENT:Think()
	local salesman = self:GetNWEntity("salesman")

	if (IsValid(salesman) and salesman:IsValid()) then
		self:SetPos(salesman:GetPos() + Vector(0, 0, 90) + Vector(0, 0, math.sin(UnPredictedCurTime()) * 2.5))

		if (self.cwNextChangeAngle <= UnPredictedCurTime()) then
			self:SetAngles(self:GetAngles() + Angle(0, 0.25, 0))
			self.cwNextChangeAngle = self.cwNextChangeAngle + (1 / 60)
		end
	end
end

-- Called when the entity initializes.
function ENT:Initialize()
	self.cwNextChangeAngle = UnPredictedCurTime()
end
