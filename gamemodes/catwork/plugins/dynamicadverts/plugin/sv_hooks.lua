--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

--- Called after Catwork has loaded all of its entities; loads the map's saved adverts.
function cwDynamicAdverts:ClockworkInitPostEntity() self:LoadDynamicAdverts() end

--- Called when a player's data stream info should be sent; sends them every advert.
--
-- @param player [Player The player receiving the data]
function cwDynamicAdverts:PlayerSendDataStreamInfo(player)
  netstream.Start(player, 'DynamicAdverts', self.storedList)
end
