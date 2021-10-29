--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- Called when Clockwork has loaded all of the entities.
function cwSaveCash:ClockworkInitPostEntity()
	if (config.Get("cash_enabled"):Get()) then
		self:LoadCash()
	end
end

-- Called just after data should be saved.
function cwSaveCash:PostSaveData()
	self:SaveCash()
end
