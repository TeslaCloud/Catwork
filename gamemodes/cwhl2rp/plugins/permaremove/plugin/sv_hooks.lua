local PLUGIN = PLUGIN

-- Called when Clockwork has loaded all of the entities.
function PLUGIN:ClockworkInitPostEntity()
	self:LoadRemoves()
end