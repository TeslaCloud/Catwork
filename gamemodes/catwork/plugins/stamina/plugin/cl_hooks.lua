--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- Called when the bars are needed.
function cwStamina:GetBars(bars)
	local stamina = cw.client:GetNetVar("Stamina") or 100
	local fatigue = cw.client:GetNetVar("Fatigue") or 0

	if (!self.stamina) then
		self.stamina = stamina
	else
		self.stamina = math.Approach(self.stamina, stamina, 1)
	end

	if (self.stamina < 95) then
		bars:Add("#Bars_Stamina", Color(100, 175, 100, 255), "", self.stamina, 100, self.stamina < 10, nil, 100 - fatigue, "УСТАЛОСТЬ")
	end
end
