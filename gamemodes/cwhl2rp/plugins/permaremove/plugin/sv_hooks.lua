--- Server-side hook of the Perma Remove plugin that removes the entities saved as permanently removed once the map
-- entities are loaded.

local PLUGIN = PLUGIN

--- Called after Catwork has loaded all map entities; removes the entities saved as permanently removed.
function PLUGIN:ClockworkInitPostEntity()
  self:LoadRemoves()
end
