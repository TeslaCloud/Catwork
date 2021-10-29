local PLUGIN = PLUGIN

-- Called when Clockwork has loaded all of the entities.
function PLUGIN:ClockworkInitPostEntity()
	self:LoadCombineLocks()
end

-- Called just after data should be saved.
function PLUGIN:PostSaveData()
	self:SaveCombineLocks()
end