--- Server-side hooks of the Dynamic Adverts plugin that load the map's saved adverts on startup and send the advert
-- list to each joining player.

--- Called after Catwork has loaded all of its entities; loads the map's saved adverts.
function cwDynamicAdverts:ClockworkInitPostEntity() self:LoadDynamicAdverts() end

--- Called when a player's data stream info should be sent; sends them every advert.
--
-- @param player [Player The player receiving the data]
function cwDynamicAdverts:PlayerSendDataStreamInfo(player)
  netstream.Start(player, 'DynamicAdverts', self.storedList)
end
