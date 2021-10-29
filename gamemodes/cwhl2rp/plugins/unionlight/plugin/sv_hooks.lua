local PLUGIN = PLUGIN

-- Called when CW has loaded all of the entities.
function PLUGIN:ClockworkInitPostEntity()
	self:LoadUnionLights()
end

-- Called just after data should be saved.
function PLUGIN:PostSaveData()
	self:SaveUnionLights()
end