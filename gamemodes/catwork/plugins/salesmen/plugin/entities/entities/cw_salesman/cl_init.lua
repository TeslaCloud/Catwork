--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

util.Include("shared.lua")

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	if (hook.Run("SalesmanTargetID", self, x, y, alpha)) then
		local colorTargetID = cw.option:GetColor("target_id")
		local colorWhite = cw.option:GetColor("white")
		local physDesc = self:GetNetworkedString("PhysDesc")
		local name = self:GetNetworkedString("Name")

		y = cw.core:DrawInfo(name, x, y, colorTargetID, alpha)

		if (physDesc != "") then
			y = cw.core:DrawInfo(physDesc, x, y, colorWhite, alpha)
		end
	end
end

-- Called when the entity initializes.
function ENT:Initialize()
	self.AutomaticFrameAdvance = true
end

-- Called every frame.
function ENT:Think()
	self:FrameAdvance(FrameTime())
	self:NextThink(CurTime())
end
