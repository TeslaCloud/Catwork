--- Server-side hooks of the Save Items plugin that respawn the saved shipments and items once the map's entities have
-- loaded and save them whenever Catwork saves its data.

--- Called after Catwork has loaded all of its entities; restores saved shipments and items.
function cwSaveItems:ClockworkInitPostEntity()
  self:LoadShipments() self:LoadItems()
end

--- Called after Catwork saves its data; saves the shipments and items lying on the map.
function cwSaveItems:PostSaveData()
  self:SaveShipments() self:SaveItems()
end
