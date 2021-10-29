local PLUGIN = PLUGIN

-- Called when CW has loaded all of the entities.
function PLUGIN:ClockworkInitPostEntity()
	PLUGIN:LoadEmplacementGuns()
end

-- Called just after data should be saved.
function PLUGIN:PostSaveData()
	PLUGIN:SaveEmplacementGuns()
end