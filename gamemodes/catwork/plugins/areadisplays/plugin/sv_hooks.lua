--- Server-side hooks of the Area Displays plugin that load the map's areas and send them to joining players.

--- Called after Catwork has loaded all map entities; loads the current map's areas.
function cwAreaDisplays:ClockworkInitPostEntity() self:LoadAreaDisplays() end

--- Called when a player's initial data is sent; sends them every stored area.
-- @param player [Player The player receiving the data]
function cwAreaDisplays:PlayerSendDataStreamInfo(player)
  netstream.Start(player, 'AreaDisplays', self.storedList)
end
