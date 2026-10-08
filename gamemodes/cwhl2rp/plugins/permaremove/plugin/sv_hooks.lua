local PLUGIN = PLUGIN

--- Called after Catwork has loaded all map entities; removes the entities saved as permanently removed.
function PLUGIN:ClockworkInitPostEntity()
  self:LoadRemoves()
end
