--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- Called when Clockwork has loaded all of the entities.
function cwDoorCmds:ClockworkInitPostEntity()
	self:LoadParentData()
	self:LoadDoorData()

	if (config.Get("doors_save_state"):Get()) then
		self:LoadDoorStates()
	end
end

function cwDoorCmds:PostSaveData()
	if (config.Get("doors_save_state"):Get() and #player.GetAll() > 0) then
		self:SaveDoorStates()
	end
end
